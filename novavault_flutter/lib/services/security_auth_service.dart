import 'dart:io';
import 'package:flutter/services.dart';

class SecurityAuthService {
  static const _channel = MethodChannel('com.novavault.novavault_flutter/oauth');

  static Future<bool> canAuthenticateDevice() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('canAuthenticate');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticateDevice({
    String title = 'Unlock NovaVault',
    String subtitle = 'Use your fingerprint, pattern, or PIN',
  }) async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('authenticateDevice', {
        'title': title,
        'subtitle': subtitle,
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}
