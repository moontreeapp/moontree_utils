import 'package:decimal/decimal.dart';
import 'package:moontree_utils/extensions/extensions.dart';

extension DoubleReadableNumericExtension on double {
  String toSatsCommaString() =>
      toString().split('.').first.asSatsInt().toCommaString() +
      (toString().split('.').last == '0'
          ? ''
          : '.' +
              Decimal.parse('.${toString().split('.').last}')
                  .toString()
                  .split('.')
                  .last);
}
