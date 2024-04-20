import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';

const String oauthConsumerKey = '3nVuSoBZnx6U4vzUxf5w';
const String oauthConsumerSecret = 'Bcs59EFbbsdF6Sl9Ng71smgStWEGwXXKSjYvPVt7qys';

Future<String> hmacSHA1(String key, String text) async {
  final hmac = Hmac.sha1();
  final mac = await hmac.calculateMac(
    utf8.encode(text),
    secretKey: SecretKey(utf8.encode(key)),
  );
  return base64.encode(mac.bytes);
}

String nonce() {
  Random rnd = Random();
  List<int> values = List<int>.generate(32, (i) => rnd.nextInt(256));
  return base64.encode(values).replaceAll(RegExp('[=/+]'), '');
}

Future<String> aesGcm256Encrypt(String key, String text) async {
  final algorithm = AesGcm.with256bits();
  final keyAlgorithm = Sha256();
  final hash = await keyAlgorithm.hash(utf8.encode(key));
  final secretKey = SecretKey(hash.bytes);
  final nonce = algorithm.newNonce();

  final secretBox = await algorithm.encrypt(
    utf8.encode(text),
    secretKey: secretKey,
    nonce: nonce,
  );
  return base64.encode(secretBox.concatenation());
}

Future<String> aesGcm256Decrypt(String key, String encryptedText) async {
  final algorithm = AesGcm.with256bits();
  final keyAlgorithm = Sha256();
  final hash = await keyAlgorithm.hash(utf8.encode(key));
  final secretKey = SecretKey(hash.bytes);

  final secretBox = SecretBox.fromConcatenation(
    base64.decode(encryptedText),
    nonceLength: algorithm.nonceLength,
    macLength: algorithm.macAlgorithm.macLength
  );
  final decryptedText = await algorithm.decrypt(secretBox, secretKey: secretKey);
  return utf8.decode(decryptedText);
}

Future<String> sha1Hash(String text) async {
  final algorithm = Sha1();
  final hash = await algorithm.hash(text.codeUnits);
  return HEX.encode(hash.bytes);
}
