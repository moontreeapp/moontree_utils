import 'package:moontree_utils/src/transform.dart';
import 'package:moontree_utils/extensions/extensions.dart';

extension IntReadableNumericExtension on int {
  String toCommaString({String comma = ','}) {
    final String str = toString();
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
    return ret;
  }

  double toAmount() => satToAmount(this);
}
