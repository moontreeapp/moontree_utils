import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:quiver/iterables.dart';
import 'package:tuple/tuple.dart';

extension EnumeratedIntIteratable on Iterable<int> {
  Iterable<List<int>> enumerated() => zip(
      <Iterable<int>>[mapIndexed((int index, dynamic element) => index), this]);
}

extension EnumeratedIteratable on Iterable<dynamic> {
  Iterable<List<dynamic>> enumerated() => zip(<Iterable<dynamic>>[
        mapIndexed((int index, dynamic element) => index),
        this
      ]);

  Iterable<Tuple2<int, T>> enumeratedTuple<T>() => <Tuple2<int, T>>[
        for (List<dynamic> x in zip(<Iterable<dynamic>>[
          mapIndexed<int>((int index, dynamic element) => index),
          this as Iterable<T>
        ]))
          Tuple2<int, T>(x[0] as int, x[1] as T)
      ];
}

extension MinMaxOfAIteratableInt on Iterable<int> {
  int get max => reduce(math.max);
  int get min => reduce(math.min);
}

extension MinMaxOfAIteratableDouble on Iterable<double> {
  double get max => reduce(math.max);
  double get min => reduce(math.min);
}

extension SumAList on Iterable<dynamic> {
  num sum() => fold(
      0,
      (num previousValue, dynamic element) =>
          previousValue + (element is num ? element : 0));
  int sumInt({bool truncate = true}) =>
      truncate ? sum().toInt() : sum().round();
  double sumDouble() => sum().toDouble();
}

extension CompareIteratable on Iterable<dynamic> {
  bool equals(Iterable<dynamic> y, [bool compareOrder = true]) {
    if (length != y.length) {
      return false;
    }
    final List<dynamic> x = toList();
    final List<dynamic> yList = y.toList();
    if (compareOrder) {
      for (int i = 0; i < length; i++) {
        if (x[i] != yList[i]) {
          return false;
        }
      }
      return true;
    }
    for (int i = 0; i < length; i++) {
      for (int j = 0; j < yList.length; j++) {
        if (x[i] == yList[j]) {
          yList.removeAt(j);
          break;
        }
      }
    }
    if (yList.isEmpty) {
      return true;
    }
    return false;
  }
}
