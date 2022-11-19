import 'package:moontree_utils/extensions/extensions.dart';

extension DoubleReadableNumericExtension on double {
  String toCommaString() =>
      toString().split('.').first.toInt().toCommaString() +
      (toString().split('.').last == '0'
          ? ''
          : '.' + toString().split('.').last);
}
