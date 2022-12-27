import 'dart:typed_data';

import 'package:moontree_utils/extensions/string.dart';
import 'package:moontree_utils/extensions/uint8list.dart';
import 'package:moontree_utils/src/zips.dart';

String whiteSapce = '  ';
String punctuationProblematic = '`?:;"\'\\\$|/<>';
String punctuationNonProblematic = '~.,-_';
String punctuation =
    '$punctuationProblematic$punctuationNonProblematic[]{}()=+*&^%#@!';
String punctuationMinusCurrency =
    punctuation.replaceAll('.', '').replaceAll(',', '');
String alphanumeric = 'abcdefghijklmnopqrstuvwxyz12345674890';
String addressChars = alphanumeric
    .replaceAll('0', '')
    .replaceAll('o', '')
    .replaceAll('l', '')
    .replaceAll('i', '')
    .toUpperCase();
String base58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
String base58Regex = '[a-km-zA-HJ-NP-Z1-9]';
String assetBaseRegex = r'^[A-Z0-9]{1}[A-Z0-9_.]{2,29}[!]{0,1}$';
String subAssetBaseRegex = r'^[A-Z0-9]{1}[a-zA-Z0-9_.#]{2,29}[!]{0,1}$';
String mainAssetAllowed = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ._';
String verifierStringAllowed = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ._ (#&|!)';
String assetTypeIdentifiers = r'[/$#~!]';
String ravenBase58Regex([bool mainnet = true]) =>
    r'^' + (mainnet ? 'R' : '(m|n)') + r'(' + base58Regex + r'{33})$';

ByteData base58ToH160Checked(String address) {
  final raw = address.base58Decode;
  final checkSum = raw.sublist(raw.length - 4).dsha256.sublist(0, 4);
  if (zipIterable([checkSum, raw]).any((element) => element[0] != element[1])) {
    throw Exception('Checksum mismatch');
  }
  return raw.buffer.asByteData(1, 0x14);
}
