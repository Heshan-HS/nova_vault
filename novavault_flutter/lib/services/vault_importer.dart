import 'dart:convert';
import '../models/vault_item.dart';
import 'vault_service.dart';

class VaultImporter {
  /// Parses and imports Bitwarden JSON export text
  static int importBitwardenJson(String jsonText) {
    try {
      final decoded = jsonDecode(jsonText);
      final List<dynamic> rawItems = decoded['items'] ?? [];
      final List<VaultItem> newItems = [];

      for (final raw in rawItems) {
        final name = raw['name'] ?? 'Imported Item';
        final type = raw['type'] ?? 1; // 1: Login, 2: Secure Note, 3: Card, 4: Identity
        final login = raw['login'] ?? {};
        final card = raw['card'] ?? {};
        final notes = raw['notes'] ?? '';
        final favourite = raw['favorite'] == true;

        String category = 'login';
        if (type == 2) category = 'note';
        if (type == 3) category = 'card';
        if (type == 4) category = 'identity';

        final username = login['username'] ?? '';
        final password = login['password'] ?? '';
        final totp = login['totp'] ?? '';
        final uris = login['uris'] as List<dynamic>?;
        final url = uris != null && uris.isNotEmpty ? (uris.first['uri'] ?? '') : '';

        newItems.add(
          VaultItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + (newItems.length).toString(),
            name: name,
            category: category,
            username: username,
            password: password,
            url: url,
            hasTotp: totp.toString().isNotEmpty,
            totpSecret: totp.toString().replaceAll(' ', ''),
            notes: notes,
            cardHolder: card['cardholderName'] ?? '',
            cardNumber: card['number'] ?? '',
            cardExpiry: '${card['expMonth'] ?? ''}/${card['expYear'] ?? ''}',
            cardCvv: card['code'] ?? '',
            cardBrand: card['brand'] ?? 'Visa',
            tags: ['Imported'],
            folder: 'Personal',
            favourite: favourite,
            updatedAt: 'today',
            createdAt: 'Imported',
          ),
        );
      }

      if (newItems.isNotEmpty) {
        for (final item in newItems) {
          VaultService().addItem(item);
        }
      }
      return newItems.length;
    } catch (_) {
      return 0;
    }
  }

  /// Parses Bitwarden or Google Chrome CSV export text
  static int importCsv(String csvText) {
    try {
      final lines = csvText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.length <= 1) return 0;

      final header = lines.first.toLowerCase();
      final isChrome = header.contains('name') && header.contains('url') && header.contains('password');
      final isBitwarden = header.contains('login_username') || header.contains('login_password');

      final List<VaultItem> newItems = [];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i];
        final parts = _parseCsvLine(line);
        if (parts.length < 3) continue;

        if (isBitwarden) {
          // folder,favorite,type,name,notes,fields,reprompt,login_uri,login_username,login_password,login_totp
          final name = parts.length > 3 ? parts[3] : 'Imported';
          final notes = parts.length > 4 ? parts[4] : '';
          final url = parts.length > 7 ? parts[7] : '';
          final username = parts.length > 8 ? parts[8] : '';
          final password = parts.length > 9 ? parts[9] : '';
          final totp = parts.length > 10 ? parts[10] : '';

          newItems.add(
            VaultItem(
              id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
              name: name.isNotEmpty ? name : 'Item $i',
              category: 'login',
              username: username,
              password: password,
              url: url,
              notes: notes,
              hasTotp: totp.isNotEmpty,
              totpSecret: totp,
              tags: ['Bitwarden'],
              folder: 'Personal',
              updatedAt: 'today',
              createdAt: 'Imported',
            ),
          );
        } else if (isChrome) {
          // name,url,username,password
          final name = parts[0];
          final url = parts.length > 1 ? parts[1] : '';
          final username = parts.length > 2 ? parts[2] : '';
          final password = parts.length > 3 ? parts[3] : '';

          newItems.add(
            VaultItem(
              id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
              name: name.isNotEmpty ? name : 'Login $i',
              category: 'login',
              username: username,
              password: password,
              url: url,
              tags: ['Chrome'],
              folder: 'Personal',
              updatedAt: 'today',
              createdAt: 'Imported',
            ),
          );
        }
      }

      for (final item in newItems) {
        VaultService().addItem(item);
      }
      return newItems.length;
    } catch (_) {
      return 0;
    }
  }

  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }
}
