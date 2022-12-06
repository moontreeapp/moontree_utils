// dart test test/unit/utils/random.dart
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:moontree_utils/src/random.dart';

void main() {
  test('random works as expected', () {
    final Uint8List bytes = randomBytes(2);
    expect(bytes.length, 2);

    expect(randomInRange(0, 1), 0);

    final int choice = chooseAtRandom<int>(<int>[1, 2]);
    expect([1, 2].contains(choice), true);
  });
}
