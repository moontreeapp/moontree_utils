// ignore_for_file: avoid_print

//import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart';
import 'package:moontree_utils/extensions/string.dart';

removeTrailingZeros(String n) {
  return n.replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
}

void main() {
  group('case', () {
    setUp(() {});
    test('double new ', () async {
      print(removeTrailingZeros('.00000010'));
    });
    
  });
}
