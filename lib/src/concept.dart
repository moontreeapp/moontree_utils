import 'package:moontree_utils/extensions/string.dart';

abstract class Concept<T extends Enum> {
  const Concept(this.option);
  final T option;
  String get name => option.name;
  String get title => option.name.toTitleCase();
}
