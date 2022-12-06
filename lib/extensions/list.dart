import 'dart:math' as math;

extension RandomChoiceExtension on List<dynamic> {
  /// returns a random element from the list
  dynamic get randomChoice => this[math.Random().nextInt(length)];
}
