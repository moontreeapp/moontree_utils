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
}
