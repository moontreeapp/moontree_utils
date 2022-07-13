import 'dart:convert';

import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:bs58/bs58.dart';

import 'package:utils/string.dart' as strings;
import 'package:utils/transform.dart';

extension StringCapitalizationExtension on String {
  String toCapitalizedWord() =>
      1 < length ? substring(0, 1).toUpperCase() + substring(1) : toUpperCase();

  String toTitleCase({bool underscoresAsSpace = false}) =>
      replaceAll(RegExp(' +'), ' ')
          // for enums especially:
          .replaceAll(underscoresAsSpace ? RegExp('_+') : ' ', ' ')
          .split(' ')
          .map((String str) => str.toCapitalizedWord())
          .join(' ');
}

extension StringTrimExtension on String {
  String trimPattern(String pattern) {
    var tempString = this;
    if (startsWith(pattern)) {
      tempString = substring(pattern.length, tempString.length);
    }
    if (endsWith(pattern)) {
      tempString = substring(0, tempString.length - pattern.length);
    }
    return tempString;
  }

  String cutOutMiddle({int length = 6}) {
    if (this.length > length * 2) {
      return substring(0, length) +
          '...' +
          substring(this.length - length, this.length);
    }
    return this;
  }
}

extension StringBytesExtension on String {
  List<int> get bytes => utf8.encode(this);
  Uint8List get bytesUint8 => Uint8List.fromList(bytes);
  Uint8List get hexBytes => Uint8List.fromList(hex.decode(this));
  Uint8List get hexBytesForScript =>
      Uint8List.fromList([0x54, 0x20] + hex.decode(this));
  String get hexToUTF8 => utf8.decode(hexBytes);
  String get hexToAscii => List.generate(
        length ~/ 2,
        (i) => String.fromCharCode(
            int.parse(substring(i * 2, (i * 2) + 2), radix: 16)),
      ).join();
  Uint8List get base58Decode => base58.decode(this);
}

extension StringCharactersExtension on String {
  List get characters => split('');
}

extension StringNumericExtension on String {
  int toInt() {
    var text = removeChars(
      split('.').first,
      chars: strings.punctuation + strings.whiteSapce,
    );
    if (text.length > 15) {
      text = text.substring(0, 15);
    }
    if (text == '') {
      return 0;
    }
    //if (int.parse(text) > 21000000000) {
    //  return 21000000000;
    //}
    return text.asInt();
  }

  int asInt() {
    try {
      return int.parse(this);
    } catch (e) {
      return 0;
    }
  }

  double toDouble() {
    print(this);
    return double.parse(trim().split(',').join(''));
  }
}