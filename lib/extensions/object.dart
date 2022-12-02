extension IsInStuff on Object? {
  bool isIn(Iterable x) => x.contains(this);
}
