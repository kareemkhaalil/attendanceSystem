import 'dart:convert';
import 'package:crypto/crypto.dart';

String bytesToHex(List<int> bytes) {
  final sb = StringBuffer();
  for (final b in bytes) {
    sb.write(b.toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString();
}

List<int> hexDecode(String hex) {
  final cleaned = hex.length % 2 == 1 ? '0$hex' : hex;
  final bytes = <int>[];
  for (var i = 0; i < cleaned.length; i += 2) {
    bytes.add(int.parse(cleaned.substring(i, i + 2), radix: 16));
  }
  return bytes;
}

String hmacSha256Hex({required String keyHex, required String message}) {
  final key = hexDecode(keyHex);
  final hmac = Hmac(sha256, key);
  final digest = hmac.convert(utf8.encode(message));
  return bytesToHex(digest.bytes);
}
