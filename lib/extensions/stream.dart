extension ReadableIdentifierExtension on Stream {
  static final _name = Expando<String>();
  String? get name => _name[this];
  set name(String? x) => _name[this] = x;
}
