import 'dart:convert';
import 'dart:typed_data';
import 'totp_service.dart';

class GoogleAuthAccount {
  final String name;
  final String issuer;
  final String secret;
  final int algorithm;
  final int digits;
  final int type;

  const GoogleAuthAccount({
    required this.name,
    required this.issuer,
    required this.secret,
    this.algorithm = 1,
    this.digits = 6,
    this.type = 2,
  });

  /// Account name without issuer prefix if it was formatted as "Issuer:account"
  String get cleanAccountName {
    if (name.contains(':')) {
      final parts = name.split(':');
      if (parts.length > 1) {
        return parts.sublist(1).join(':').trim();
      }
    }
    return name;
  }

  /// Best display title
  String get displayTitle {
    if (issuer.isNotEmpty) return issuer;
    if (name.contains(':')) {
      return name.split(':').first.trim();
    }
    return name;
  }

  /// Live TOTP 6-digit code for instant verification
  String get liveCode {
    try {
      return TotpService.generateTotp(secret: secret, digits: digits == 2 ? 8 : 6);
    } catch (_) {
      return '------';
    }
  }
}

class GoogleAuthMigrationParser {
  /// Parses one or multiple `otpauth-migration://offline?data=...` links
  /// (e.g. if the user exports many accounts across multiple QR codes).
  static List<GoogleAuthAccount> parse(String input) {
    String trimmed = input.trim();
    if (trimmed.isEmpty) return [];

    final allAccounts = <GoogleAuthAccount>[];
    final seenSecrets = <String>{};

    // 1. Try finding all otpauth-migration URIs in the text
    final matches = RegExp(r'otpauth-migration:\/\/offline\?[^\s]+').allMatches(trimmed);
    if (matches.isNotEmpty) {
      for (final m in matches) {
        final chunk = m.group(0)!;
        final accs = _parseSingle(chunk);
        for (final a in accs) {
          if (!seenSecrets.contains(a.secret)) {
            seenSecrets.add(a.secret);
            allAccounts.add(a);
          }
        }
      }
      return allAccounts;
    }

    // 2. Fallback: split by lines
    final lines = trimmed.split(RegExp(r'[\r\n]+'));
    for (final line in lines) {
      final l = line.trim();
      if (l.isEmpty) continue;
      final accs = _parseSingle(l);
      for (final a in accs) {
        if (!seenSecrets.contains(a.secret)) {
          seenSecrets.add(a.secret);
          allAccounts.add(a);
        }
      }
    }
    return allAccounts;
  }

  static List<GoogleAuthAccount> _parseSingle(String input) {
    String rawBase64 = input.trim();
    if (rawBase64.startsWith('otpauth-migration:')) {
      final uri = Uri.tryParse(rawBase64);
      if (uri != null && uri.queryParameters.containsKey('data')) {
        rawBase64 = uri.queryParameters['data']!;
      } else {
        final qIndex = rawBase64.indexOf('data=');
        if (qIndex != -1) {
          rawBase64 = rawBase64.substring(qIndex + 5);
          final ampIndex = rawBase64.indexOf('&');
          if (ampIndex != -1) {
            rawBase64 = rawBase64.substring(0, ampIndex);
          }
        }
      }
    }

    // URL decode if needed
    try {
      rawBase64 = Uri.decodeComponent(rawBase64);
    } catch (_) {}

    // Normalize base64 padding
    final remainder = rawBase64.length % 4;
    if (remainder > 0) {
      rawBase64 = rawBase64.padRight(rawBase64.length + (4 - remainder), '=');
    }

    Uint8List payloadBytes;
    try {
      payloadBytes = base64.decode(rawBase64);
    } catch (_) {
      return [];
    }

    return _decodeProtobuf(payloadBytes);
  }

  static List<GoogleAuthAccount> _decodeProtobuf(Uint8List data) {
    final accounts = <GoogleAuthAccount>[];
    final reader = _ProtoReader(data);

    while (reader.hasMore) {
      final key = reader.readVarint();
      final tag = key >> 3;
      final wireType = key & 0x07;

      if (tag == 1 && wireType == 2) {
        // Repeated OtpParameters message
        final paramBytes = reader.readLengthDelimited();
        final acc = _parseOtpParameters(paramBytes);
        if (acc != null && acc.secret.isNotEmpty) {
          accounts.add(acc);
        }
      } else {
        reader.skipField(wireType);
      }
    }

    return accounts;
  }

  static GoogleAuthAccount? _parseOtpParameters(Uint8List bytes) {
    final reader = _ProtoReader(bytes);
    Uint8List? rawSecret;
    String name = '';
    String issuer = '';
    int algorithm = 1; // SHA1
    int digits = 1;    // 6 digits (1 in protobuf enum)
    int type = 2;      // TOTP (2 in protobuf enum)

    while (reader.hasMore) {
      final key = reader.readVarint();
      final tag = key >> 3;
      final wireType = key & 0x07;

      switch (tag) {
        case 1: // secret (bytes)
          if (wireType == 2) {
            rawSecret = reader.readLengthDelimited();
          } else {
            reader.skipField(wireType);
          }
          break;
        case 2: // name (string)
          if (wireType == 2) {
            name = utf8.decode(reader.readLengthDelimited(), allowMalformed: true);
          } else {
            reader.skipField(wireType);
          }
          break;
        case 3: // issuer (string)
          if (wireType == 2) {
            issuer = utf8.decode(reader.readLengthDelimited(), allowMalformed: true);
          } else {
            reader.skipField(wireType);
          }
          break;
        case 4: // algorithm (enum varint)
          if (wireType == 0) {
            algorithm = reader.readVarint();
          } else {
            reader.skipField(wireType);
          }
          break;
        case 5: // digits (enum varint)
          if (wireType == 0) {
            digits = reader.readVarint();
          } else {
            reader.skipField(wireType);
          }
          break;
        case 6: // type (enum varint)
          if (wireType == 0) {
            type = reader.readVarint();
          } else {
            reader.skipField(wireType);
          }
          break;
        default:
          reader.skipField(wireType);
      }
    }

    if (rawSecret == null || rawSecret.isEmpty) return null;

    final base32Secret = TotpService.base32Encode(rawSecret);
    if (issuer.isEmpty && name.contains(':')) {
      issuer = name.split(':').first.trim();
    }

    return GoogleAuthAccount(
      name: name,
      issuer: issuer,
      secret: base32Secret,
      algorithm: algorithm,
      digits: digits == 2 ? 8 : 6,
      type: type,
    );
  }
}

class _ProtoReader {
  final Uint8List data;
  int pos = 0;

  _ProtoReader(this.data);

  bool get hasMore => pos < data.length;

  int readVarint() {
    int res = 0;
    int shift = 0;
    while (pos < data.length) {
      final b = data[pos++];
      res |= (b & 0x7F) << shift;
      if ((b & 0x80) == 0) break;
      shift += 7;
      if (shift >= 64) break;
    }
    return res;
  }

  void skipField(int wireType) {
    switch (wireType) {
      case 0: // Varint
        readVarint();
        break;
      case 1: // 64-bit
        pos += 8;
        break;
      case 2: // Length-delimited
        final len = readVarint();
        pos += len;
        break;
      case 5: // 32-bit
        pos += 4;
        break;
      default:
        pos = data.length; // unknown, advance to end
    }
  }

  Uint8List readLengthDelimited() {
    final len = readVarint();
    if (pos + len > data.length) {
      final remaining = data.sublist(pos);
      pos = data.length;
      return remaining;
    }
    final sub = data.sublist(pos, pos + len);
    pos += len;
    return sub;
  }
}
