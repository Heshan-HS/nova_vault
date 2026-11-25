import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vault_item.dart';
import 'vault_service.dart';

class AuthSyncService extends ChangeNotifier {
  static final AuthSyncService _instance = AuthSyncService._internal();
  factory AuthSyncService() => _instance;
  AuthSyncService._internal();

  static const String defaultClientId = '838081552655-6m4uv2okmd2qent7sep0mqrabanc4hpi.apps.googleusercontent.com';
  static const String defaultClientSecret = String.fromEnvironment(
    'GOOGLE_CLIENT_SECRET',
    defaultValue: '',
  );
  static const String androidClientId = '838081552655-d8na33a1eb0kp6sblmeom9mp10if0a98.apps.googleusercontent.com';
  static const String androidRedirectUri = 'com.googleusercontent.apps.838081552655-d8na33a1eb0kp6sblmeom9mp10if0a98:/oauth2redirect';

  bool _isLoggedIn = false;
  String _userEmail = '';
  String _displayName = 'My Vault';
  String? _photoUrl;
  String? _accessToken;
  String? _refreshToken;
  String? _googleDriveFileId;
  String _syncStatus = 'Offline';
  DateTime _lastSyncTime = DateTime.now();
  bool _isSyncing = false;
  String _clientId = defaultClientId;
  String _clientSecret = defaultClientSecret;

  HttpServer? _loopbackServer;
  static const _oauthChannel = MethodChannel('com.novavault.novavault_flutter/oauth');

  Future<({int statusCode, String body})> _httpRequest(
    String url, {
    String method = 'GET',
    Map<String, String> headers = const {},
    String? body,
  }) async {
    if (Platform.isAndroid) {
      final res = await _oauthChannel.invokeMapMethod<String, dynamic>('nativeHttp', {
        'url': url,
        'method': method,
        'headers': headers,
        if (body != null) 'body': body,
      });
      return (
        statusCode: (res?['statusCode'] as int?) ?? 0,
        body: (res?['body'] as String?) ?? '',
      );
    }
    for (var attempt = 0; attempt < 2; attempt++) {
      final client = _createClient();
      try {
        final uri = Uri.parse(url);
        late http.Response r;
        if (method == 'POST') {
          r = await client.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 15));
        } else if (method == 'PATCH') {
          r = await client.patch(uri, headers: headers, body: body).timeout(const Duration(seconds: 15));
        } else {
          r = await client.get(uri, headers: headers).timeout(const Duration(seconds: 15));
        }
        return (statusCode: r.statusCode, body: r.body);
      } catch (e) {
        if (attempt == 1) rethrow;
        await Future.delayed(const Duration(milliseconds: 350));
      } finally {
        client.close();
      }
    }
    return (statusCode: 0, body: '');
  }

  /// Creates a standard HTTP client with timeout (Android uses nativeHttp).
  http.Client _createClient() {
    final ioClient = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    return IOClient(ioClient);
  }

  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  String get displayName => _displayName;
  String? get photoUrl => _photoUrl;
  String? get accessToken => _accessToken;
  String get syncStatus => _syncStatus;
  DateTime get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;
  String get clientId => _clientId;
  String get clientSecret => _clientSecret;
  bool get hasCustomClientId => _clientId.trim().isNotEmpty;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('nv_is_logged_in') ?? false;
      _userEmail = prefs.getString('nv_user_email') ?? '';
      _displayName = prefs.getString('nv_display_name') ?? (_isLoggedIn ? 'Google User' : 'My Vault');
      _photoUrl = prefs.getString('nv_photo_url');
      _accessToken = prefs.getString('nv_access_token');
      _refreshToken = prefs.getString('nv_refresh_token');
      _googleDriveFileId = prefs.getString('nv_drive_file_id');
      final savedId = prefs.getString('nv_google_client_id');
      _clientId = (savedId != null && savedId.isNotEmpty) ? savedId : defaultClientId;
      final savedSecret = prefs.getString('nv_google_client_secret');
      _clientSecret = (savedSecret != null && savedSecret.isNotEmpty) ? savedSecret : defaultClientSecret;

      final lastSyncStr = prefs.getString('nv_last_sync');
      if (lastSyncStr != null) {
        _lastSyncTime = DateTime.tryParse(lastSyncStr) ?? DateTime.now();
        _syncStatus = _isLoggedIn ? 'Synced' : 'Offline';
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setGoogleCredentials({required String clientId, String clientSecret = ''}) async {
    _clientId = clientId.trim().isNotEmpty ? clientId.trim() : defaultClientId;
    _clientSecret = clientSecret.trim().isNotEmpty ? clientSecret.trim() : defaultClientSecret;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nv_google_client_id', _clientId);
      await prefs.setString('nv_google_client_secret', _clientSecret);
    } catch (_) {}
    notifyListeners();
  }

  /// 100% Real Production Google OAuth 2.0 with PKCE & Loopback Receiver
  Future<bool> startProductionGoogleOAuth({String? customClientId}) async {
    final activeClientId = (customClientId != null && customClientId.trim().isNotEmpty)
        ? customClientId.trim()
        : _clientId.trim();

    if (activeClientId.isEmpty) {
      _syncStatus = 'Google Client ID required';
      notifyListeners();
      return false;
    }

    _isSyncing = true;
    _syncStatus = 'Opening Google Sign-in...';
    notifyListeners();

    try {
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      if (Platform.isAndroid) {
        final completer = Completer<Map<String, String?>>();
        _oauthChannel.setMethodCallHandler((call) async {
          if (call.method == 'onOAuthCallback' && !completer.isCompleted) {
            final args = Map<String, dynamic>.from(call.arguments as Map);
            completer.complete({
              'code': args['code'] as String?,
              'error': args['error'] as String?,
            });
          }
        });

        final authUri = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
          'client_id': androidClientId,
          'redirect_uri': androidRedirectUri,
          'response_type': 'code',
          'scope': 'openid email profile https://www.googleapis.com/auth/drive.appdata',
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'prompt': 'select_account',
          'access_type': 'offline',
        });

        print('NV_OAUTH: launching default browser for Android OAuth');
        if (await canLaunchUrl(authUri)) {
          await launchUrl(authUri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(authUri, mode: LaunchMode.platformDefault);
        }

        final callback = await completer.future.timeout(
          const Duration(minutes: 3),
          onTimeout: () => {'error': 'Sign-in timed out'},
        );

        final code = callback['code'];
        final error = callback['error'];
        if (error != null || code == null) {
          _isSyncing = false;
          _syncStatus = 'Google Sign-in failed: ${error ?? 'Cancelled'}';
          notifyListeners();
          return false;
        }

        return await _exchangeCodeAndSignIn(
          code: code,
          activeClientId: androidClientId,
          codeVerifier: codeVerifier,
          redirectUri: androidRedirectUri,
          includeSecret: false,
        );
      }

      // Desktop loopback server
      await _loopbackServer?.close(force: true);
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _loopbackServer = server;
      final port = server.port;
      final redirectUri = 'http://127.0.0.1:$port/oauth2callback';

      final authUri = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        'client_id': activeClientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': 'openid email profile https://www.googleapis.com/auth/drive.appdata',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
        'prompt': 'select_account',
        'access_type': 'offline',
      });

      print('NV_OAUTH: listening on 127.0.0.1:$port');
      if (await canLaunchUrl(authUri)) {
        await launchUrl(authUri, mode: LaunchMode.externalApplication);
      } else {
        _isSyncing = false;
        _syncStatus = 'Could not open browser';
        notifyListeners();
        return false;
      }

      await for (final HttpRequest request in server) {
        final uri = request.uri;
        print('NV_OAUTH: incoming request ${uri.path}');

        if (uri.path == '/oauth2callback') {
          final code = uri.queryParameters['code'];
          final error = uri.queryParameters['error'];

          if (error != null || code == null) {
            request.response
              ..statusCode = HttpStatus.badRequest
              ..headers.contentType = ContentType.html
              ..write(_errorHtml(error ?? 'No authorization code returned'));
            await request.response.close();
            _isSyncing = false;
            _syncStatus = 'Google Sign-in failed: $error';
            notifyListeners();
            await server.close(force: true);
            return false;
          }

          final ok = await _exchangeCodeAndSignIn(
            code: code,
            activeClientId: activeClientId,
            codeVerifier: codeVerifier,
            redirectUri: redirectUri,
          );

          try {
            request.response
              ..statusCode = ok ? HttpStatus.ok : HttpStatus.badRequest
              ..headers.contentType = ContentType.html
              ..write(ok ? _successHtml(_displayName, _userEmail) : _errorHtml(_syncStatus));
            await request.response.close();
          } catch (_) {}

          await server.close(force: true);
          return ok;
        }
      }
      return false;
    } catch (e) {
      print('NV_OAUTH: error $e');
      _isSyncing = false;
      _syncStatus = 'Auth error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> _exchangeCodeAndSignIn({
    required String code,
    required String activeClientId,
    required String codeVerifier,
    required String redirectUri,
    bool includeSecret = true,
  }) async {
    print('NV_OAUTH: exchanging code for token...');
    final activeSecret = _clientSecret.isNotEmpty ? _clientSecret : defaultClientSecret;
    final formBody = Uri(queryParameters: {
      'client_id': activeClientId,
      if (includeSecret && activeSecret.isNotEmpty) 'client_secret': activeSecret,
      'code': code,
      'code_verifier': codeVerifier,
      'grant_type': 'authorization_code',
      'redirect_uri': redirectUri,
    }).query;

    final tokenResponse = await _httpRequest(
      'https://oauth2.googleapis.com/token',
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: formBody,
    );
    print('NV_OAUTH: token response ${tokenResponse.statusCode}');

    if (tokenResponse.statusCode == 200) {
      final tokenData = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
      final newAccessToken = tokenData['access_token'] as String;
      final newRefreshToken = tokenData['refresh_token'] as String?;

      final userinfoResponse = await _httpRequest(
        'https://www.googleapis.com/oauth2/v3/userinfo',
        headers: {'Authorization': 'Bearer $newAccessToken'},
      );

      String userEmail = 'user@gmail.com';
      String userName = 'Google User';
      String? photoUrl;

      if (userinfoResponse.statusCode == 200) {
        final userInfo = jsonDecode(userinfoResponse.body) as Map<String, dynamic>;
        userEmail = userInfo['email'] ?? userEmail;
        userName = userInfo['name'] ?? userName;
        photoUrl = userInfo['picture'];
      }

      _isLoggedIn = true;
      _userEmail = userEmail;
      _displayName = userName;
      _photoUrl = photoUrl;
      _accessToken = newAccessToken;
      _googleDriveFileId = null;
      if (newRefreshToken != null) _refreshToken = newRefreshToken;
      _lastSyncTime = DateTime.now();
      _syncStatus = 'Connected to Google Drive';
      _isSyncing = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('nv_is_logged_in', true);
      await prefs.setString('nv_user_email', _userEmail);
      await prefs.setString('nv_display_name', _displayName);
      if (_photoUrl != null) await prefs.setString('nv_photo_url', _photoUrl!);
      await prefs.setString('nv_access_token', newAccessToken);
      if (newRefreshToken != null) await prefs.setString('nv_refresh_token', newRefreshToken);
      _googleDriveFileId = prefs.getString('nv_drive_file_id_${_userEmail.trim().toLowerCase()}');

      await VaultService().loadForUser(_userEmail);
      await syncWithGoogleDrive(VaultService().items);

      notifyListeners();
      return true;
    } else {
      _isSyncing = false;
      _syncStatus = 'Token exchange failed (${tokenResponse.statusCode})';
      notifyListeners();
      return false;
    }
  }

  /// Triggers Cloud Sync between PC & Mobile after local changes
  Future<void> syncNow(List<VaultItem> items) async {
    await syncWithGoogleDrive(items, pushLocalChanges: true);
  }

  /// Helper that adds Authorization header and automatically refreshes on 401
  Future<({int statusCode, String body})> _httpWithAuthRetry(
    String url, {
    String method = 'GET',
    Map<String, String>? extraHeaders,
    String? body,
  }) async {
    var headers = <String, String>{
      'Authorization': 'Bearer $_accessToken',
      ...?extraHeaders,
    };
    var res = await _httpRequest(url, method: method, headers: headers, body: body);
    if (res.statusCode == 401 && await _refreshAccessToken()) {
      headers = <String, String>{
        'Authorization': 'Bearer $_accessToken',
        ...?extraHeaders,
      };
      res = await _httpRequest(url, method: method, headers: headers, body: body);
    }
    return res;
  }

  /// Refreshes expired OAuth access token using stored refresh token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) return false;
    final activeClientId = Platform.isAndroid
        ? androidClientId
        : (_clientId.isNotEmpty ? _clientId : defaultClientId);
    final activeSecret = Platform.isAndroid
        ? ''
        : (_clientSecret.isNotEmpty ? _clientSecret : defaultClientSecret);
    try {
      final body = Uri(queryParameters: {
        'client_id': activeClientId,
        if (activeSecret.isNotEmpty) 'client_secret': activeSecret,
        'refresh_token': _refreshToken!,
        'grant_type': 'refresh_token',
      }).query;
      final res = await _httpRequest(
        'https://oauth2.googleapis.com/token',
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final newToken = data['access_token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          _accessToken = newToken;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('nv_access_token', newToken);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Real Google Drive AppData Sync (2-Way Encrypted Vault Upload & Download)
  Future<void> syncWithGoogleDrive(
    List<VaultItem> items, {
    bool pushLocalChanges = false,
  }) async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      _syncStatus = 'Not signed in';
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _syncStatus = 'Syncing with Google Drive AppData...';
    notifyListeners();

    try {
      var workingItems = List<VaultItem>.from(items);

      // 1. If local items is empty, try to restore from this user's local cache first
      if (workingItems.isEmpty && _userEmail.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final userKey = 'nv_vault_items_${_userEmail.trim().toLowerCase()}';
        final localCache = prefs.getString(userKey);
        if (localCache != null && localCache.isNotEmpty && localCache != '[]') {
          final List<dynamic> list = jsonDecode(localCache);
          final restored = list.map((e) => VaultItem.fromJson(e as Map<String, dynamic>)).toList();
          if (restored.isNotEmpty) {
            await VaultService().setAllItems(restored, syncToCloud: false);
            workingItems = restored;
          }
        }
      }

      // 2. Check if backup file already exists in user's private Google Drive appDataFolder
      String? fileId = _googleDriveFileId;
      if (fileId == null || fileId.isEmpty) {
        final listResponse = await _httpWithAuthRetry(
          'https://www.googleapis.com/drive/v3/files?spaces=appDataFolder&q=name=%27novavault_vault.enc%27&fields=files(id,name)',
        );

        if (listResponse.statusCode == 200) {
          final listData = jsonDecode(listResponse.body);
          final files = listData['files'] as List<dynamic>?;
          if (files != null && files.isNotEmpty) {
            fileId = files.first['id'] as String;
            _googleDriveFileId = fileId;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('nv_drive_file_id_${_userEmail.trim().toLowerCase()}', fileId);
          }
        } else if (listResponse.statusCode == 403) {
          _isSyncing = false;
          _syncStatus = 'Google Drive API disabled (403) — enable in Cloud Console';
          notifyListeners();
          return;
        } else if (listResponse.statusCode == 401) {
          _isSyncing = false;
          _syncStatus = 'Session expired (401) — please reconnect Google';
          notifyListeners();
          return;
        }
      }

      // 3. Always download existing Drive backup to pull updates from other devices
      final hasPending = pushLocalChanges || VaultService().hasPendingSync;
      if (fileId != null && fileId.isNotEmpty) {
        final downloadResponse = await _httpWithAuthRetry(
          'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
        );
        if (downloadResponse.statusCode == 200 &&
            downloadResponse.body.isNotEmpty &&
            downloadResponse.body != '[]') {
          final List<dynamic> downloadedList = jsonDecode(downloadResponse.body);
          final driveItems = downloadedList
              .map((e) => VaultItem.fromJson(e as Map<String, dynamic>))
              .toList();

          if (!hasPending && driveItems.isNotEmpty) {
            // No unpushed local edits: Drive copy is authoritative!
            await VaultService().setAllItems(driveItems, syncToCloud: false);
            await VaultService().markSynced();
            final prefs = await SharedPreferences.getInstance();
            if (_userEmail.isNotEmpty) {
              await prefs.setString(
                'nv_vault_items_${_userEmail.trim().toLowerCase()}',
                downloadResponse.body,
              );
              await prefs.setString('nv_last_sync', DateTime.now().toIso8601String());
            }
            _lastSyncTime = DateTime.now();
            _syncStatus = 'Synced with Google Drive (${driveItems.length} items)';
            notifyListeners();
            return;
          }

          if (hasPending && driveItems.isNotEmpty) {
            // Local device has unpushed edits: merge any new items added on other devices
            final localIds = workingItems.map((i) => i.id).toSet();
            final deletedIds = VaultService().deletedIds.toSet();
            final toMerge = driveItems
                .where((d) => !localIds.contains(d.id) && !deletedIds.contains(d.id))
                .toList();
            if (toMerge.isNotEmpty) {
              workingItems = [...workingItems, ...toMerge];
              await VaultService().setAllItems(workingItems, syncToCloud: false);
            }
          }
        }
      }

      final jsonPayload = jsonEncode(workingItems.map((i) => i.toJson()).toList());

      // Only cache under current user's scoped key
      if (workingItems.isNotEmpty && _userEmail.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nv_vault_items_${_userEmail.trim().toLowerCase()}', jsonPayload);
      }

      if (fileId != null && fileId.isNotEmpty) {
        // Update existing backup in Google Drive
        final updateResponse = await _httpWithAuthRetry(
          'https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=media',
          method: 'PATCH',
          extraHeaders: {'Content-Type': 'application/json'},
          body: jsonPayload,
        );
        if (updateResponse.statusCode == 200) {
          await VaultService().markSynced();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('nv_last_sync', DateTime.now().toIso8601String());
          _lastSyncTime = DateTime.now();
          _syncStatus = 'Synced with Google Drive (${workingItems.length} items)';
        } else {
          _syncStatus = 'Drive update failed (${updateResponse.statusCode})';
        }
      } else {
        // Create new backup file in Google Drive AppData folder
        final createUri = Uri.parse('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');
        final boundary = '-------NovaVaultBoundary${DateTime.now().millisecondsSinceEpoch}';
        final metadata = jsonEncode({
          'name': 'novavault_vault.enc',
          'parents': ['appDataFolder'],
          'mimeType': 'application/json',
        });

        final body = StringBuffer()
          ..write('--$boundary\r\n')
          ..write('Content-Type: application/json; charset=UTF-8\r\n\r\n')
          ..write('$metadata\r\n')
          ..write('--$boundary\r\n')
          ..write('Content-Type: application/json\r\n\r\n')
          ..write('$jsonPayload\r\n')
          ..write('--$boundary--\r\n');

        final createResponse = await _httpWithAuthRetry(
          createUri.toString(),
          method: 'POST',
          extraHeaders: {'Content-Type': 'multipart/related; boundary=$boundary'},
          body: body.toString(),
        );

        if (createResponse.statusCode == 200) {
          final resData = jsonDecode(createResponse.body);
          _googleDriveFileId = resData['id'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('nv_drive_file_id_${_userEmail.trim().toLowerCase()}', _googleDriveFileId!);
          await prefs.setString('nv_last_sync', DateTime.now().toIso8601String());
          await VaultService().markSynced();
          _lastSyncTime = DateTime.now();
          _syncStatus = 'Synced with Google Drive (${workingItems.length} items)';
        } else {
          _syncStatus = 'Drive upload failed (${createResponse.statusCode})';
        }
      }
    } catch (e) {
      _syncStatus = 'Sync error: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sign out from Google Account
  Future<void> signOut() async {
    // 1. Safely archive items under user-scoped key before signing out
    try {
      if (_userEmail.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final jsonList = VaultService().items.map((e) => e.toJson()).toList();
        final jsonString = jsonEncode(jsonList);
        await prefs.setString('nv_vault_items_${_userEmail.trim().toLowerCase()}', jsonString);
      }
    } catch (_) {}

    _isLoggedIn = false;
    _userEmail = '';
    _displayName = 'My Vault';
    _photoUrl = null;
    _accessToken = null;
    _refreshToken = null;
    _googleDriveFileId = null;
    _syncStatus = 'Offline';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('nv_is_logged_in', false);
      await prefs.remove('nv_user_email');
      await prefs.remove('nv_display_name');
      await prefs.remove('nv_photo_url');
      await prefs.remove('nv_access_token');
      await prefs.remove('nv_refresh_token');
      await prefs.remove('nv_drive_file_id');
      await prefs.remove('nv_vault_items'); // Remove active items on logout
      await prefs.remove('nv_cloud_sync_cache');
    } catch (_) {}

    // 2. Clear vault in memory so all items disappear on logout!
    VaultService().clearVault();

    notifyListeners();
  }

  // PKCE Code Verifier Generator (RFC 7636)
  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  // PKCE Code Challenge Generator (SHA-256 base64url)
  String _generateCodeChallenge(String verifier) {
    final bytes = ascii.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  String _successHtml(String name, String email) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Google Sign-in Successful - NovaVault</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #f8fafd; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    .card { background: white; border-radius: 24px; padding: 40px; text-align: center; max-width: 420px; box-shadow: 0 4px 24px rgba(0,0,0,0.06); border: 1px solid #e0e2ec; }
    .check { width: 56px; height: 56px; background: #e6f4ea; color: #137333; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 28px; margin: 0 auto 16px; }
    h1 { font-size: 20px; color: #1f1f1f; margin-bottom: 6px; }
    p { font-size: 14px; color: #444746; line-height: 1.5; margin-bottom: 20px; }
    .email { background: #f1f3f4; padding: 8px 16px; border-radius: 20px; font-weight: 600; font-size: 13px; color: #1a73e8; display: inline-block; }
  </style>
</head>
<body>
  <div class="card">
    <div class="check">✓</div>
    <h1>Google Account Connected!</h1>
    <p>Welcome, <strong>$name</strong></p>
    <div class="email">$email</div>
    <p style="margin-top: 20px;">NovaVault is now syncing your encrypted vault via Google Drive AppData. You can safely close this browser window and return to NovaVault.</p>
  </div>
</body>
</html>
''';
  }

  String _errorHtml(String error) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Sign-in Error - NovaVault</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #fdf2f2; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    .card { background: white; border-radius: 24px; padding: 40px; text-align: center; max-width: 420px; box-shadow: 0 4px 24px rgba(0,0,0,0.06); border: 1px solid #fecaca; }
    .cross { width: 56px; height: 56px; background: #fde8e8; color: #c5221f; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 28px; margin: 0 auto 16px; }
    h1 { font-size: 20px; color: #1f1f1f; margin-bottom: 6px; }
    p { font-size: 14px; color: #c5221f; line-height: 1.5; }
  </style>
</head>
<body>
  <div class="card">
    <div class="cross">✕</div>
    <h1>Authentication Failed</h1>
    <p>$error</p>
  </div>
</body>
</html>
''';
  }
}
