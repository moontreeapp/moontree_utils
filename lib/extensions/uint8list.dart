import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:collection/collection.dart';
import 'package:bs58/bs58.dart' as bs58;

extension StringExtension on Uint8List {
  String get toEncodedString => hex.encode(this);
  String h160ToAddress(int addrType) {
    if (length != 0x14) {
      throw Exception('Invalid h160 length');
    }
    List<int> x = [];
    x.add(addrType);
    x.addAll(this);
    x.addAll(Uint8List.fromList(x).dsha256.sublist(0, 4));
    return bs58.base58.encode(Uint8List.fromList(x));
  }
}

extension Uint8ListExtension on Uint8List {
  Uint8List get dsha256 =>
      Uint8List.fromList(sha256.convert(sha256.convert(this).bytes).bytes);

  String toHex() => hex.encode(this);

  bool equals(Object? other) {
    Uint8List otherList;
    if (other is ByteData) {
      otherList = other.buffer.asUint8List();
    } else if (other is List<int>) {
      otherList = Uint8List.fromList(other);
    } else {
      return false;
    }
    if (length != otherList.length) return false;
    return !IterableZip([this, otherList])
        .any((element) => element[0] != element[1]);
  }
}
