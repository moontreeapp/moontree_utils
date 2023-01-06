import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:bs58/bs58.dart' as bs58;

extension ByteDataEquality on ByteData {
  String toBs58() => bs58.base58.encode(buffer.asUint8List());
  String toHex() => hex.encode(buffer.asUint8List());
  // Attempt to copy only relevant portion
  ByteData clone() =>
      Uint8List.fromList(buffer.asUint8List()).buffer.asByteData();

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
