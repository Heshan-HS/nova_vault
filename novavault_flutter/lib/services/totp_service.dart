import 'dart:math' as math;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class TotpService {
  /// Base32 alphabet used in RFC 3548 / RFC 4648
  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// Encodes raw bytes to a standard Base32 string (RFC 3548 / RFC 4648)
  static String base32Encode(List<int> bytes) {
    if (bytes.isEmpty) return '';
    final buffer = StringBuffer();
    int currentByte = 0;
    int bitsLeft = 0;

    for (final b in bytes) {
      currentByte = (currentByte << 8) | (b & 0xFF);
      bitsLeft += 8;
      while (bitsLeft >= 5) {
        bitsLeft -= 5;
        final index = (currentByte >> bitsLeft) & 0x1F;
        buffer.write(_base32Chars[index]);
      }
    }

    if (bitsLeft > 0) {
      final index = (currentByte << (5 - bitsLeft)) & 0x1F;
      buffer.write(_base32Chars[index]);
    }

    return buffer.toString();
  }

  /// Decodes a Base32 string into a byte list
  static Uint8List? _base32Decode(String input) {
    final cleaned = input.replaceAll(' ', '').replaceAll('-', '').toUpperCase();
    if (cleaned.isEmpty) return null;

    final output = <int>[];
    int buffer = 0;
    int bitsLeft = 0;

    for (int i = 0; i < cleaned.length; i++) {
      final char = cleaned[i];
      if (char == '=') break; // padding
      final val = _base32Chars.indexOf(char);
      if (val < 0) return null; // invalid char

      buffer = (buffer << 5) | val;
      bitsLeft += 5;

      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        output.add((buffer >> bitsLeft) & 0xFF);
      }
    }

    return Uint8List.fromList(output);
  }

  /// Calculates RFC 6238 TOTP code for a secret and period (default 30s)
  static String generateTotp({
    String secret = 'JBSWY3DPEHPK3PXP', // Default RFC test secret
    int period = 30,
    int digits = 6,
    int? timestampMs,
  }) {
    final now = timestampMs ?? DateTime.now().millisecondsSinceEpoch;
    final counter = (now ~/ 1000) ~/ period;

    Uint8List? key = _base32Decode(secret);
    if (key == null || key.isEmpty) {
      // Fallback key if invalid base32
      key = Uint8List.fromList('NovaVaultSecretKey'.codeUnits);
    }

    // Convert counter to 8-byte big-endian
    final msg = Uint8List(8);
    int temp = counter;
    for (int i = 7; i >= 0; i--) {
      msg[i] = temp & 0xFF;
      temp >>= 8;
    }

    // HMAC-SHA1
    final hmac = Hmac(sha1, key);
    final hash = hmac.convert(msg).bytes;

    // Dynamic Truncation (RFC 4226)
    final offset = hash[hash.length - 1] & 0x0F;
    final binaryCode = ((hash[offset] & 0x7F) << 24) |
        ((hash[offset + 1] & 0xFF) << 16) |
        ((hash[offset + 2] & 0xFF) << 8) |
        (hash[offset + 3] & 0xFF);

    final otp = binaryCode % math.pow(10, digits).toInt();
    final otpStr = otp.toString().padLeft(digits, '0');

    // Group as "123 456"
    if (digits == 6) {
      return '${otpStr.substring(0, 3)} ${otpStr.substring(3)}';
    }
    return otpStr;
  }

  /// Calculates seconds remaining in the current 30s window (1 to 30)
  static int getRemainingSeconds({int period = 30}) {
    final currentSecond = (DateTime.now().millisecondsSinceEpoch ~/ 1000) % period;
    final remaining = period - currentSecond;
    return remaining == 0 ? period : remaining;
  }
}
