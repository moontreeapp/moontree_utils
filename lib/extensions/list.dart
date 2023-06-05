import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:quiver/iterables.dart';
import 'package:tuple/tuple.dart';

extension RandomChoiceExtension on List<dynamic> {
  /// returns a random element from the list
  dynamic get randomChoice => this[math.Random().nextInt(length)];
}

extension EnumeratedList on List<dynamic> {
  Iterable<Tuple2<int, T>> enumeratedTuple<T>() => <Tuple2<int, T>>[
        for (List<dynamic> x in zip(<Iterable<dynamic>>[
          mapIndexed<int>((int index, dynamic element) => index),
          this as List<T?>
        ]))
          Tuple2<int, T>(x[0] as int, x[1] as T)
      ];
}
