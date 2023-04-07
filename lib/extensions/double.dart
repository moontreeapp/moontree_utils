import 'package:moontree_utils/extensions/extensions.dart';

removeTrailingZeros(String n) {
  return n.replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
}

extension DoubleReadableNumericExtension on double {
  String toSatsCommaString() =>
      toString().split('.').first.asSatsInt().toCommaString() +
      (toString().split('.').last == '0'
          ? ''
          : removeTrailingZeros('.${toStringAsFixed(8).split('.').last}'));

  /// I made this thinking toSatsCommaString did something else. but it is a
  /// solution for this.
  String toCommaString({String comma = ','}) {
    final String fullStr = toString();
    final List strs = fullStr.split('.');
    final String str = strs[0];
    int i = 0;
    String ret = '';
    for (final String c in str.characters.reversed) {
      if (i == 3) {
        ret = '$c$comma$ret';
        i = 1;
      } else {
        ret = '$c$ret';
        i += 1;
      }
    }
    if (fullStr.contains('.')) {
      return '${ret}.${strs.last}';
    } else {
      return ret;
    }
  }
}
