import 'dart:convert';

import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:bs58/bs58.dart' as bs58;

import 'package:moontree_utils/src/hex.dart' as hexx;
import 'package:moontree_utils/src/string.dart' as strings;
import 'package:moontree_utils/src/transform.dart';

extension StringCapitalizationExtension on String {
  String toCapitalizedWord() => 1 < length
      ? substring(0, 1).toUpperCase() + substring(1).toLowerCase()
      : toUpperCase();

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
    String tempString = this;
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
      return '${substring(0, length)}...${substring(this.length - length, this.length)}';
    }
    return this;
  }
}

extension StringBytesExtension on String {
  List<int> get bytes => utf8.encode(this);
  Uint8List get bytesUint8 => Uint8List.fromList(bytes);
  Uint8List get hexBytes => Uint8List.fromList(hex.decode(this));
  Uint8List get hexBytesForScript =>
      Uint8List.fromList(<int>[0x54, 0x20] + hex.decode(this));
  String get hexToUTF8 => utf8.decode(hexBytes);
  String get hexToAscii => List<String>.generate(
        length ~/ 2,
        (int i) => String.fromCharCode(
            int.parse(substring(i * 2, (i * 2) + 2), radix: 16)),
      ).join();
  Uint8List get base58Decode => bs58.base58.decode(this);
  Uint8List get hexDecode => hexx.decode(this);
  ByteData get addressToH160 =>
      Uint8List.fromList(hex.decode(this)).buffer.asByteData(1, 0x14);

  ///
  //ByteData get asByteData => Uint8List.fromList(this List<int>).buffer.asByteData();
  //ByteData get addressToH160 => Uint8List.fromList(this List<int>).buffer.asByteData();
  //String get h160ToAddress => Uint8List.fromList(this ByteData).buffer.asByteData();
}

extension StringCharactersExtension on String {
  List<String> get characters => split('');
}

extension StringNumericExtension on String {
  /// assumes the string is an amount
  int toSats([int divisibility = 8]) {
    String x = trim();
    if (x == '' || x == '.') {
      return 0;
    }
    if (!x.contains('.')) {
      x = '$x.';
    }
    final List<String> s = x.split('.');
    if (s.length > 2) {
      return 0;
    }
    if (s.last.length > divisibility) {
      s[1] = s[1].substring(0, divisibility);
    } else if (s.last.length < divisibility) {
      s[1] = s[1] + '0' * (divisibility - s.last.length);
    }
    final String textSats = '${s.first}${s.last}';
    if (textSats.length > 19) {
      return int.parse(textSats.substring(0, 19));
    }
    return int.parse(textSats);
  }

  /// assumes the string is already in sats.
  int asSatsInt() {
    String text = removeChars(
      split('.').first,
      chars: strings.punctuation + strings.whiteSapce,
    );
    if (text.length > 19) {
      text = text.substring(0, 19);
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
    return double.parse(trim().split(',').join());
  }
}
