extension IsInStuff on Object? {
  bool isIn(Iterable<dynamic> x) => x.contains(this);
}
