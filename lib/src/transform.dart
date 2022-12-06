/// divisibility of 0 is no decimal places, 1 is one.

import 'package:moontree_utils/extensions/string.dart';
import 'package:moontree_utils/src/string.dart';

int invertDivisibility(int divisibility) => (16 + 1) % (divisibility + 8 + 1);

double satToAmount(int x) => x / 100000000;
int amountToSat(double x) => (x * 100000000).floor();

String removeChars(
  String text, {
  String? chars,
}) {
  chars = chars ?? punctuationProblematic;
  for (final String char in chars.characters) {
    text = text.replaceAll(char, '');
  }
  return text;
}

List<int> enumerate(String text) =>
    List<int>.generate(text.length, (int i) => (i + 1) - 1);

String removeCharsOtherThan(
  String text, {
  String? chars,
}) {
  chars = chars ?? alphanumeric;
  String ret = '';
  for (final String char in text.characters) {
    if (chars.contains(char)) {
      ret = '$ret$char';
    }
  }
  return ret;
}
