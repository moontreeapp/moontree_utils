import 'dart:math' as math;

extension RandomChoiceOnSetExtension on Set<dynamic> {
  /// returns a random element from the set
  dynamic get randomChoice => elementAt(math.Random().nextInt(length));

  /// returns a number from the set that is in the bottom half
  dynamic get randomChoiceBottomHalf {
    final List<dynamic> x = toList();
    x.sort();
    return x[math.Random().nextInt(length ~/ 2)];
  }
}

extension MinMaxExtension on Set<int> {
  /// returns the lowest int in the set
  int get min => reduce(math.min);
}

extension CombineAliasSetsExtension<T> on Set<T> {
  Set<T> operator +(Set<T> other) => union(other);
  Set<T> operator -(Set<T> other) => difference(other);
}
