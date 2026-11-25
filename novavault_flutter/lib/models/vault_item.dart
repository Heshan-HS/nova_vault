class VaultItem {
  final String id;
  final String name;
  final String category; // 'login', 'card', 'note', 'identity'
  final String username;
  final String password;
  final String url;
  final List<String> tags;
  bool favourite;
  final String folder;
  final int strength;
  final bool hasTotp;
  final String totpSecret;
  final String notes;
  final String updatedAt;
  final String createdAt;

  // Dedicated Card Fields
  final String cardHolder;
  final String cardNumber;
  final String cardExpiry;
  final String cardCvv;
  final String cardPin;
  final String cardBrand;

  // Dedicated Identity Fields
  final String identityName;
  final String identityNumber;
  final String identityPhone;
  final String identityAddress;

  // Dedicated Server / VPS Fields
  final String serverHost;      // server name / hostname
  final String serverPublicIp;  // public IP address
  final String serverDomain;    // domain name
  final String serverSshPort;   // SSH port (default 22)
  final String serverUsername;  // SSH username (root / ubuntu etc.)
  final String serverPassword;  // SSH password
  final String serverSshKey;    // SSH private key / passphrase
  final String panelUrl;        // control panel URL (cPanel, Plesk, Pterodactyl…)
  final String panelUsername;   // panel username
  final String panelPassword;   // panel password
  final String panelPort;       // panel port
  final String serverOs;        // OS label e.g. Ubuntu 22.04
  final String serverProvider;  // e.g. DigitalOcean, Contabo, Hetzner

  VaultItem({
    required this.id,
    required this.name,
    required this.category,
    this.username = '',
    this.password = '',
    this.url = '',
    required this.tags,
    this.favourite = false,
    required this.folder,
    int? strength,
    this.hasTotp = false,
    this.totpSecret = '',
    this.notes = '',
    this.updatedAt = 'today',
    this.createdAt = '14 Mar 2026',
    this.cardHolder = '',
    this.cardNumber = '',
    this.cardExpiry = '',
    this.cardCvv = '',
    this.cardPin = '',
    this.cardBrand = 'Visa',
    this.identityName = '',
    this.identityNumber = '',
    this.identityPhone = '',
    this.identityAddress = '',
    // Server fields
    this.serverHost = '',
    this.serverPublicIp = '',
    this.serverDomain = '',
    this.serverSshPort = '22',
    this.serverUsername = '',
    this.serverPassword = '',
    this.serverSshKey = '',
    this.panelUrl = '',
    this.panelUsername = '',
    this.panelPassword = '',
    this.panelPort = '',
    this.serverOs = '',
    this.serverProvider = '',
  }) : strength = strength ?? (password.isNotEmpty ? calculateStrength(password) : 80);

  bool get isLogin => category == 'login';
  bool get isCard => category == 'card';
  bool get isNote => category == 'note';
  bool get isIdentity => category == 'identity';
  bool get isServer => category == 'server';

  static int calculateStrength(String pwd) {
    if (pwd.isEmpty) return 0;
    int score = 0;
    if (pwd.length >= 8) score += 25;
    if (pwd.length >= 14) score += 25;
    if (pwd.length >= 18) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score += 10;
    if (RegExp(r'[a-z]').hasMatch(pwd)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score += 10;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pwd)) score += 10;
    return score.clamp(0, 100);
  }

  VaultItem copyWith({
    String? id,
    String? name,
    String? category,
    String? username,
    String? password,
    String? url,
    List<String>? tags,
    bool? favourite,
    String? folder,
    int? strength,
    bool? hasTotp,
    String? totpSecret,
    String? notes,
    String? updatedAt,
    String? createdAt,
    String? cardHolder,
    String? cardNumber,
    String? cardExpiry,
    String? cardCvv,
    String? cardPin,
    String? cardBrand,
    String? identityName,
    String? identityNumber,
    String? identityPhone,
    String? identityAddress,
    // Server fields
    String? serverHost,
    String? serverPublicIp,
    String? serverDomain,
    String? serverSshPort,
    String? serverUsername,
    String? serverPassword,
    String? serverSshKey,
    String? panelUrl,
    String? panelUsername,
    String? panelPassword,
    String? panelPort,
    String? serverOs,
    String? serverProvider,
  }) {
    return VaultItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      tags: tags ?? List.from(this.tags),
      favourite: favourite ?? this.favourite,
      folder: folder ?? this.folder,
      strength: strength ?? (password != null ? calculateStrength(password) : this.strength),
      hasTotp: hasTotp ?? this.hasTotp,
      totpSecret: totpSecret ?? this.totpSecret,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      cardHolder: cardHolder ?? this.cardHolder,
      cardNumber: cardNumber ?? this.cardNumber,
      cardExpiry: cardExpiry ?? this.cardExpiry,
      cardCvv: cardCvv ?? this.cardCvv,
      cardPin: cardPin ?? this.cardPin,
      cardBrand: cardBrand ?? this.cardBrand,
      identityName: identityName ?? this.identityName,
      identityNumber: identityNumber ?? this.identityNumber,
      identityPhone: identityPhone ?? this.identityPhone,
      identityAddress: identityAddress ?? this.identityAddress,
      serverHost: serverHost ?? this.serverHost,
      serverPublicIp: serverPublicIp ?? this.serverPublicIp,
      serverDomain: serverDomain ?? this.serverDomain,
      serverSshPort: serverSshPort ?? this.serverSshPort,
      serverUsername: serverUsername ?? this.serverUsername,
      serverPassword: serverPassword ?? this.serverPassword,
      serverSshKey: serverSshKey ?? this.serverSshKey,
      panelUrl: panelUrl ?? this.panelUrl,
      panelUsername: panelUsername ?? this.panelUsername,
      panelPassword: panelPassword ?? this.panelPassword,
      panelPort: panelPort ?? this.panelPort,
      serverOs: serverOs ?? this.serverOs,
      serverProvider: serverProvider ?? this.serverProvider,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'username': username,
        'password': password,
        'url': url,
        'tags': tags,
        'favourite': favourite,
        'folder': folder,
        'strength': strength,
        'hasTotp': hasTotp,
        'totpSecret': totpSecret,
        'notes': notes,
        'updatedAt': updatedAt,
        'createdAt': createdAt,
        'cardHolder': cardHolder,
        'cardNumber': cardNumber,
        'cardExpiry': cardExpiry,
        'cardCvv': cardCvv,
        'cardPin': cardPin,
        'cardBrand': cardBrand,
        'identityName': identityName,
        'identityNumber': identityNumber,
        'identityPhone': identityPhone,
        'identityAddress': identityAddress,
        // Server fields
        'serverHost': serverHost,
        'serverPublicIp': serverPublicIp,
        'serverDomain': serverDomain,
        'serverSshPort': serverSshPort,
        'serverUsername': serverUsername,
        'serverPassword': serverPassword,
        'serverSshKey': serverSshKey,
        'panelUrl': panelUrl,
        'panelUsername': panelUsername,
        'panelPassword': panelPassword,
        'panelPort': panelPort,
        'serverOs': serverOs,
        'serverProvider': serverProvider,
      };

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    return VaultItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Untitled',
      category: json['category'] as String? ?? 'login',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      url: json['url'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['General'],
      favourite: json['favourite'] as bool? ?? false,
      folder: json['folder'] as String? ?? 'Personal',
      strength: json['strength'] as int?,
      hasTotp: json['hasTotp'] as bool? ?? false,
      totpSecret: json['totpSecret'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? 'today',
      createdAt: json['createdAt'] as String? ?? '14 Mar 2026',
      cardHolder: json['cardHolder'] as String? ?? '',
      cardNumber: json['cardNumber'] as String? ?? '',
      cardExpiry: json['cardExpiry'] as String? ?? '',
      cardCvv: json['cardCvv'] as String? ?? '',
      cardPin: json['cardPin'] as String? ?? '',
      cardBrand: json['cardBrand'] as String? ?? 'Visa',
      identityName: json['identityName'] as String? ?? '',
      identityNumber: json['identityNumber'] as String? ?? '',
      identityPhone: json['identityPhone'] as String? ?? '',
      identityAddress: json['identityAddress'] as String? ?? '',
      serverHost: json['serverHost'] as String? ?? '',
      serverPublicIp: json['serverPublicIp'] as String? ?? '',
      serverDomain: json['serverDomain'] as String? ?? '',
      serverSshPort: json['serverSshPort'] as String? ?? '22',
      serverUsername: json['serverUsername'] as String? ?? '',
      serverPassword: json['serverPassword'] as String? ?? '',
      serverSshKey: json['serverSshKey'] as String? ?? '',
      panelUrl: json['panelUrl'] as String? ?? '',
      panelUsername: json['panelUsername'] as String? ?? '',
      panelPassword: json['panelPassword'] as String? ?? '',
      panelPort: json['panelPort'] as String? ?? '',
      serverOs: json['serverOs'] as String? ?? '',
      serverProvider: json['serverProvider'] as String? ?? '',
    );
  }
}

class MockVaultData {
  static List<VaultItem> getInitialItems() => [
        VaultItem(
          id: '1',
          name: 'GitHub',
          category: 'login',
          username: 'dev@example.com',
          password: 'ghp_NovaVaultKey991482913_UltraSecure',
          url: 'github.com',
          tags: ['Work'],
          favourite: true,
          folder: 'Work',
          strength: 96,
          hasTotp: true,
          totpSecret: 'JBSWY3DPEHPK3PXP', // Valid test TOTP key
          updatedAt: 'today',
          createdAt: '14 Mar 2026',
        ),
        VaultItem(
          id: '2',
          name: 'DigitalOcean',
          category: 'login',
          username: 'admin@example.com',
          password: 'dop_v1_88192a8f9c104e76a91d29381',
          url: 'digitalocean.com',
          tags: ['Server'],
          favourite: false,
          folder: 'Servers',
          strength: 92,
          hasTotp: false, // No 2FA -> prompts "+ Set up 2FA"
          totpSecret: '',
          updatedAt: '2 days ago',
          createdAt: '10 Jan 2026',
        ),
        VaultItem(
          id: '3',
          name: 'Gmail',
          category: 'login',
          username: 'family@example.com',
          password: 'Google_Pass#2026!Fam',
          url: 'gmail.com',
          tags: ['Personal'],
          favourite: false,
          folder: 'Personal',
          strength: 84,
          hasTotp: true,
          totpSecret: 'HXDMVJECJJWSRB3H', // Valid Google TOTP test key
          updatedAt: '1 week ago',
          createdAt: '5 Feb 2026',
        ),
        VaultItem(
          id: '4',
          name: 'Netflix',
          category: 'login',
          username: 'family@example.com',
          password: 'netflix123',
          url: 'netflix.com',
          tags: ['Personal'],
          favourite: false,
          folder: 'Personal',
          strength: 42,
          hasTotp: false,
          totpSecret: '',
          updatedAt: '2 weeks ago',
          createdAt: '20 Nov 2025',
        ),
        VaultItem(
          id: '5',
          name: 'Bank Card',
          category: 'card',
          username: 'Visa ···· 4417',
          cardHolder: 'HESHAN SATHYANGA',
          cardNumber: '4532 8910 2341 4417',
          cardExpiry: '09/28',
          cardCvv: '829',
          cardPin: '4412',
          cardBrand: 'Visa',
          tags: ['Finance'],
          favourite: false,
          folder: 'Personal',
          hasTotp: false, // Absolutely NO TOTP for cards!
          totpSecret: '',
          notes: 'Commercial Bank Visa Platinum. Primary daily usage card.',
          updatedAt: '1 month ago',
          createdAt: '1 Oct 2025',
        ),
        VaultItem(
          id: '6',
          name: 'V2Ray Panel',
          category: 'login',
          username: 'root@vp-xp',
          password: 'V2Ray_Super#S3cret99!',
          url: 'https://vps.network.internal',
          tags: ['Server'],
          favourite: false,
          folder: 'Servers',
          strength: 94,
          hasTotp: false,
          totpSecret: '',
          updatedAt: '3 days ago',
          createdAt: '15 Mar 2026',
        ),
        VaultItem(
          id: '7',
          name: 'Spotify',
          category: 'login',
          username: 'me@example.com',
          password: 'spotifypass',
          url: 'spotify.com',
          tags: ['Personal'],
          favourite: false,
          folder: 'Personal',
          strength: 48,
          hasTotp: false,
          totpSecret: '',
          updatedAt: '5 days ago',
          createdAt: '1 Jan 2026',
        ),
      ];
}
