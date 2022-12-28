import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';

extension ByteDataEquality on ByteData {
  String toHex() {
    return hex.encode(buffer.asUint8List());
  }

  // Attempt to copy only relevant portion
  ByteData clone() {
    return Uint8List.fromList(buffer.asUint8List()).buffer.asByteData();
  }

  bool equals(Object? other) {
    final thisList = buffer.asUint8List();
    Uint8List otherList;
    if (other is ByteData) {
      otherList = other.buffer.asUint8List();
    } else if (other is List<int>) {
      otherList = Uint8List.fromList(other);
    } else {
      return false;
    }
    if (thisList.length != otherList.length) return false;
    return !IterableZip([thisList, otherList])
        .any((element) => element[0] != element[1]);
  }
}
