import 'package:quiver/iterables.dart';

abstract class ToStringMixin {
  @override
  String toString() => toStringOverride(this, props, propNames);
  List<Object?> get props => <Object?>[];
  List<String> get propNames => <String>[];
}

String toStringOverride(
  dynamic object,
  List<dynamic> items,
  List<String> names,
) =>
    '${object.runtimeType.toString()}(${[
      for (final List<dynamic> z in zip(<List<dynamic>>[names, items]))
        '${z[0]}: ${z[1]}'
    ].join(', ')})';
