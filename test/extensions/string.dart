// ignore_for_file: avoid_print

//import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart';
import 'package:moontree_utils/extensions/string.dart';

void main() {
  group('case', () {
    setUp(() {});
    test('first letter case', () async {
      expect('MOONTREE'.toCapitalizedWord(), 'Moontree');
      expect('moontree'.toCapitalizedWord(), 'Moontree');
    });
    test('titlecase', () async {
      expect('MOONTREE IS Awesome'.toTitleCase(), 'Moontree Is Awesome');
    });
  });
}
