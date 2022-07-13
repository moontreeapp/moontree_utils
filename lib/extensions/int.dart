import 'package:utils/transform.dart';
import 'package:utils/extensions/extensions.dart';

extension IntReadableNumericExtension on int {
  String toCommaString({String comma = ','}) {
    var str = toString();
    var i = 0;
    var ret = '';
    for (var c in str.characters.reversed) {
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