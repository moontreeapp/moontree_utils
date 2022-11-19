// ignore_for_file: depend_on_referenced_packages

import 'dart:typed_data';

import 'package:convert/convert.dart' show hex;

Uint8List decode(String encoded) => Uint8List.fromList(hex.decode(encoded));
String encode(Uint8List decoded) => hex.encode(decoded);

String toHexString(String string) => hex.encode(string.codeUnits);

String hexToAscii(String hexString) => List.generate(
      hexString.length ~/ 2,
      (i) => String.fromCharCode(
          int.parse(hexString.substring(i * 2, (i * 2) + 2), radix: 16)),
    ).join();


/*
String encrypt(String hexString, CipherBase cipher) =>
    encode(cipher.encrypt(decode(hexString)));

String decrypt(String hexString, CipherBase cipher) =>
    encode(cipher.decrypt(decode(hexString)));
*/

