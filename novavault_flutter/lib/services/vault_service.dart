import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vault_item.dart';
import 'auth_sync_service.dart';
import 'google_auth_migration_parser.dart';
import 'security_auth_service.dart';

class VaultService extends ChangeNotifier {
  static final VaultService _instance = VaultService._internal();
  factory VaultService() => _instance;
  VaultService._internal();

  List<VaultItem> _items = [];
  VaultItem? _selectedItem;
  String _activeNav = 'all';
  String? _selectedFolder;
  String _selectedFilterChip = 'All';
  String _searchQuery = '';

  bool _isLocked = true;
  bool _securitySetupDone = false;
  bool _lockEnabled = true;
  bool _biometricEnabled = false;
  bool _hasMasterPassword = false;
  bool _canUseDeviceLock = false;
  String _masterPassword = '';

  List<VaultItem> get items => _items;
  VaultItem? get selectedItem => _selectedItem;
  String get activeNav => _activeNav;
  String? get selectedFolder => _selectedFolder;
  String get selectedFilterChip => _selectedFilterChip;
  String get searchQuery => _searchQuery;
  bool get isLocked => _isLocked;
  bool get securitySetupDone => _securitySetupDone;
  bool get lockEnabled => _lockEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get hasMasterPassword => _hasMasterPassword;
  bool get canUseDeviceLock => _canUseDeviceLock;

  // Counters
  int get totalItems => _items.length;
  int get favouritesCount => _items.where((i) => i.favourite).length;
  int get loginsCount => _items.where((i) => i.category == 'login').length;
  int get cardsCount => _items.where((i) => i.category == 'card').length;
  int get notesCount => _items.where((i) => i.category == 'note').length;
  int get identitiesCount => _items.where((i) => i.category == 'identity').length;
  int get serversCount => _items.where((i) => i.category == 'server').length;

  int countForFolder(String folder) => _items.where((i) => i.folder.toLowerCase() == folder.toLowerCase()).length;

  int get weakPasswordsCount => _items.where((i) => i.category == 'login' && i.strength < 60).length;

  int get vaultHealthScore {
    final logins = _items.where((i) => i.category == 'login').toList();
    if (logins.isEmpty) return 100;
    final totalScore = logins.fold<int>(0, (sum, i) => sum + i.strength);
    return (totalScore / logins.length).round().clamp(0, 100);
  }

  /// Filtered items list with Starred (Favorite) items prioritized at the top
  List<VaultItem> get filteredItems {
    final list = _items.where((item) {
      // 1. Navigation category
      if (_selectedFolder != null) {
        if (item.folder.toLowerCase() != _selectedFolder!.toLowerCase()) return false;
      } else {
        if (_activeNav == 'favorites' && !item.favourite) return false;
        if (_activeNav == 'logins' && item.category != 'login') return false;
        if (_activeNav == 'cards' && item.category != 'card') return false;
        if (_activeNav == 'notes' && item.category != 'note') return false;
        if (_activeNav == 'identities' && item.category != 'identity') return false;
        if (_activeNav == 'servers' && item.category != 'server') return false;
      }

      // 2. Chip filter
      if (_selectedFilterChip == 'Logins' && item.category != 'login') return false;
      if (_selectedFilterChip == 'Cards' && item.category != 'card') return false;
      if (_selectedFilterChip == 'Weak' && item.strength >= 60) return false;

      // 3. Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = item.name.toLowerCase().contains(q);
        final matchUser = item.username.toLowerCase().contains(q);
        final matchUrl = item.url.toLowerCase().contains(q);
        final matchTags = item.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchName && !matchUser && !matchUrl && !matchTags) return false;
      }

      return true;
    }).toList();

    // Prioritize Starred (Favorite) items to the very top
    list.sort((a, b) {
      if (a.favourite && !b.favourite) return -1;
      if (!a.favourite && b.favourite) return 1;
      return 0;
    });

    return list;
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _canUseDeviceLock = await SecurityAuthService.canAuthenticateDevice();

      final savedMaster = prefs.getString('nv_master_password');
      if (savedMaster != null && savedMaster.isNotEmpty) {
        _masterPassword = savedMaster;
      }

      if (prefs.containsKey('nv_security_setup_done')) {
        _securitySetupDone = prefs.getBool('nv_security_setup_done') ?? true;
      } else {
        // Existing installs already have a password or logged-in account
        final isExisting = prefs.containsKey('nv_master_password') ||
            (prefs.getBool('nv_is_logged_in') ?? false);
        _securitySetupDone = isExisting;
      }

      _lockEnabled = prefs.getBool('nv_lock_enabled') ?? true;
      _biometricEnabled = prefs.getBool('nv_biometric_enabled') ?? false;
      _hasMasterPassword =
          prefs.getBool('nv_has_master_password') ?? _masterPassword.isNotEmpty;
      _isLocked = _lockEnabled;

      final isLoggedIn = prefs.getBool('nv_is_logged_in') ?? false;
      final userEmail = prefs.getString('nv_user_email') ?? '';

      if (isLoggedIn && userEmail.isNotEmpty) {
        await loadForUser(userEmail);
      } else {
        // Vault is logged out: start with empty secure state
        _items = [];
        _selectedItem = null;
        notifyListeners();
      }
    } catch (_) {
      _items = [];
      _selectedItem = null;
      notifyListeners();
    }
  }

  /// Clears in-memory vault immediately on logout to protect user privacy
  void clearVault() {
    _items = [];
    _selectedItem = null;
    notifyListeners();
  }

  /// Loads vault items specifically for an authenticated user
  Future<void> loadForUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final normalized = email.trim().toLowerCase();
      final userKey = 'nv_vault_items_$normalized';
      final savedData = prefs.getString(userKey);

      if (savedData != null && savedData.isNotEmpty && savedData != '[]') {
        final List<dynamic> jsonList = jsonDecode(savedData);
        _items = jsonList.map((e) {
          final item = VaultItem.fromJson(e as Map<String, dynamic>);
          final cleanedTags = item.tags.where((t) => t.toLowerCase() != 'imported').toList();
          final cleanedCreated = item.createdAt.toLowerCase() == 'imported' ? 'Recently' : item.createdAt;
          return item.copyWith(tags: cleanedTags, createdAt: cleanedCreated);
        }).toList();
      } else {
        _items = [];
      }

      final visibleList = filteredItems;
      if (visibleList.isNotEmpty) {
        _selectedItem = visibleList.first;
      } else {
        _selectedItem = null;
      }
      notifyListeners();
    } catch (_) {
      _items = [];
      _selectedItem = null;
      notifyListeners();
    }
  }

  Future<void> setAllItems(List<VaultItem> newItems) async {
    _items = newItems;
    final visibleList = filteredItems;
    _selectedItem = visibleList.isNotEmpty ? visibleList.first : null;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _items.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      final userEmail = AuthSyncService().userEmail;
      if (userEmail.isNotEmpty) {
        final userKey = 'nv_vault_items_${userEmail.trim().toLowerCase()}';
        await prefs.setString(userKey, jsonString);
      }

      AuthSyncService().syncNow(_items);
    } catch (_) {}
  }

  void selectItem(VaultItem item) {
    _selectedItem = item;
    notifyListeners();
  }

  void setActiveNav(String nav) {
    _activeNav = nav;
    _selectedFolder = null;
    final list = filteredItems;
    if (list.isNotEmpty && (_selectedItem == null || !list.contains(_selectedItem))) {
      _selectedItem = list.first;
    }
    notifyListeners();
  }

  void setSelectedFolder(String? folder) {
    _selectedFolder = folder;
    final list = filteredItems;
    if (list.isNotEmpty && (_selectedItem == null || !list.contains(_selectedItem))) {
      _selectedItem = list.first;
    }
    notifyListeners();
  }

  void setFilterChip(String chip) {
    _selectedFilterChip = chip;
    final list = filteredItems;
    if (list.isNotEmpty && (_selectedItem == null || !list.contains(_selectedItem))) {
      _selectedItem = list.first;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    final list = filteredItems;
    if (list.isNotEmpty && (_selectedItem == null || !list.contains(_selectedItem))) {
      _selectedItem = list.first;
    }
    notifyListeners();
  }

  Future<void> addItem(VaultItem item) async {
    _items.insert(0, item);
    _selectedItem = item;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> updateItem(VaultItem updated) async {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      if (_selectedItem?.id == updated.id) {
        _selectedItem = updated;
      }
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    if (_selectedItem?.id == id) {
      _selectedItem = _items.isNotEmpty ? _items.first : null;
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> toggleFavourite(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      final current = _items[idx];
      final updated = current.copyWith(favourite: !current.favourite);
      _items[idx] = updated;
      if (_selectedItem?.id == id) {
        _selectedItem = updated;
      }
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> clearAllItems() async {
    _items.clear();
    _selectedItem = null;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> resetToDemoItems() async {
    _items = MockVaultData.getInitialItems();
    _selectedItem = _items.first;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> setTotpSecret(String id, String secret) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      final updated = _items[idx].copyWith(hasTotp: true, totpSecret: secret.trim());
      _items[idx] = updated;
      if (_selectedItem?.id == id) {
        _selectedItem = updated;
      }
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> removeTotp(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      final updated = _items[idx].copyWith(hasTotp: false, totpSecret: '');
      _items[idx] = updated;
      if (_selectedItem?.id == id) {
        _selectedItem = updated;
      }
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Batch imports 2FA accounts from Google Authenticator export.
  /// Matches against existing vault items by username / email or issuer name.
  /// If no match is found, creates a new vault item for the 2FA account.
  Future<int> batchApplyTotp(List<GoogleAuthAccount> accounts) async {
    int count = 0;
    for (final acc in accounts) {
      final accNameClean = acc.name.toLowerCase().trim();
      final accIssuerClean = acc.issuer.toLowerCase().trim();
      final cleanAcc = acc.cleanAccountName.toLowerCase().trim();

      int targetIdx = _items.indexWhere((item) {
        final user = item.username.toLowerCase().trim();
        final name = item.name.toLowerCase().trim();
        if (cleanAcc.isNotEmpty && (user == cleanAcc || name == cleanAcc)) return true;
        if (accNameClean.isNotEmpty && (user == accNameClean || name == accNameClean)) return true;
        if (accIssuerClean.isNotEmpty && (name.contains(accIssuerClean) || user.contains(accIssuerClean))) return true;
        if (user.isNotEmpty && (cleanAcc.contains(user) || accNameClean.contains(user))) return true;
        return false;
      });

      if (targetIdx != -1) {
        _items[targetIdx] = _items[targetIdx].copyWith(hasTotp: true, totpSecret: acc.secret);
        count++;
      } else {
        // Create new item for this 2FA account
        final newItem = VaultItem(
          id: 'nv_totp_${DateTime.now().millisecondsSinceEpoch}_$count',
          name: acc.displayTitle,
          category: 'login',
          username: acc.cleanAccountName,
          password: '',
          folder: 'Personal',
          tags: ['2FA', 'Google-Auth'],
          hasTotp: true,
          totpSecret: acc.secret,
          createdAt: 'Imported 2FA',
        );
        _items.add(newItem);
        count++;
      }
    }
    if (_selectedItem != null) {
      final idx = _items.indexWhere((i) => i.id == _selectedItem!.id);
      if (idx != -1) _selectedItem = _items[idx];
    }
    await _saveToStorage();
    notifyListeners();
    return count;
  }

  // Lock / Unlock & Security Setup
  void lock() {
    if (!_lockEnabled) return;
    _isLocked = true;
    notifyListeners();
  }

  bool unlock(String password) {
    if (!_hasMasterPassword) return false;
    if (password == _masterPassword) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  void unlockWithBiometrics() {
    _isLocked = false;
    notifyListeners();
  }

  Future<void> completeSecuritySetup({
    required bool lockEnabled,
    required bool biometricEnabled,
    String? masterPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _securitySetupDone = true;
    _lockEnabled = lockEnabled;
    _biometricEnabled = lockEnabled && biometricEnabled;
    _hasMasterPassword = lockEnabled && masterPassword != null && masterPassword.isNotEmpty;

    if (_hasMasterPassword) {
      _masterPassword = masterPassword!;
      await prefs.setString('nv_master_password', masterPassword);
    } else {
      await prefs.remove('nv_master_password');
    }

    await prefs.setBool('nv_security_setup_done', true);
    await prefs.setBool('nv_lock_enabled', _lockEnabled);
    await prefs.setBool('nv_biometric_enabled', _biometricEnabled);
    await prefs.setBool('nv_has_master_password', _hasMasterPassword);
    _isLocked = false;
    notifyListeners();
  }

  Future<void> setLockEnabled(bool enabled) async {
    _lockEnabled = enabled;
    if (!enabled) {
      _biometricEnabled = false;
      _isLocked = false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nv_lock_enabled', _lockEnabled);
    if (!enabled) {
      await prefs.setBool('nv_biometric_enabled', false);
    }
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    if (enabled && !_lockEnabled) {
      _lockEnabled = true;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nv_biometric_enabled', _biometricEnabled);
    await prefs.setBool('nv_lock_enabled', _lockEnabled);
    notifyListeners();
  }

  Future<bool> changeMasterPassword(String oldPwd, String newPwd) async {
    if (_hasMasterPassword && oldPwd != _masterPassword) return false;
    _masterPassword = newPwd;
    _hasMasterPassword = true;
    _lockEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nv_master_password', newPwd);
    await prefs.setBool('nv_has_master_password', true);
    await prefs.setBool('nv_lock_enabled', true);
    notifyListeners();
    return true;
  }
}
