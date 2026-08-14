import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted SHA-256 for profile PINs, stored as "salt:hash".
String hashPin(String pin) {
  final salt = base64Url
      .encode(List<int>.generate(16, (_) => Random.secure().nextInt(256)));
  final digest = sha256.convert(utf8.encode('$salt:$pin')).toString();
  return '$salt:$digest';
}

bool verifyPin(String pin, String stored) {
  final i = stored.indexOf(':');
  if (i < 0) return false;
  final salt = stored.substring(0, i);
  final digest = sha256.convert(utf8.encode('$salt:$pin')).toString();
  return digest == stored.substring(i + 1);
}
