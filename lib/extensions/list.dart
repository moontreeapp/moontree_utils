import 'dart:math' as math;

extension RandomChoiceExtension on List {
  /// returns a random element from the list
  dynamic get randomChoice => this[math.Random().nextInt(length)];
}
