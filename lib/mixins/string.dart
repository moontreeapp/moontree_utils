import 'package:quiver/iterables.dart';

abstract class ToStringMixin {
  @override
  String toString() => toStringOverride(this, props, propNames);
  List<Object?> get props => [];
  List<String> get propNames => [];
}

String toStringOverride(object, List items, List<String> names) =>
    '${object.runtimeType.toString()}(${[
      for (var z in zip([names, items])) '${z[0]}: ${z[1]}'
    ].join(', ')})';
