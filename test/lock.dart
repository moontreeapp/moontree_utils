// dart test test/unit/utils/random.dart
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:moontree_utils/src/lock.dart';
import 'package:test/test.dart';

void main() {
  test('Test Lock', () async {
    final ReaderWriterLock lock = ReaderWriterLock();
    final Random rand = Random();

    read_1() async {
      await lock.enterRead();
      print('1 Enter Read');
      await Future<void>.delayed(
          Duration(milliseconds: 500 + rand.nextInt(2500)));
      print('1 Exit Read');
      await lock.exitRead();
    }

    read_2() async {
      await lock.enterRead();
      print('2 Enter Read');
      await Future<void>.delayed(
          Duration(milliseconds: 500 + rand.nextInt(2500)));
      print('2 Exit Read');
      await lock.exitRead();
    }

    write_1() async {
      await lock.enterWrite();
      print('1 Enter Write');
      await Future<void>.delayed(
          Duration(milliseconds: 500 + rand.nextInt(2500)));
      print('1 Exit Write');
      await lock.exitWrite();
    }

    write_2() async {
      await lock.enterWrite();
      print('2 Enter Write');
      await Future<void>.delayed(
          Duration(milliseconds: 500 + rand.nextInt(2500)));
      print('2 Exit Write');
      await lock.exitWrite();
    }

    Future<void> w_1 = write_1();
    Future<void> r_1 = read_1();
    Future<void> w_2 = write_2();
    Future<void> r_2 = read_2();

    await Future.wait([r_1, r_2, w_1, w_2]);
  });
}
