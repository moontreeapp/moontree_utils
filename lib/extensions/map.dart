extension SetOrUpdateOnMapExtension<TK, TV> on Map<TK, TV> {
  /// if key present, overwrites value, if overwriteValue set, else inserts
  void upsert({
    required TK key,
    TV Function(TV item)? value,
    required TV defaultValue,
    bool overwrite = true,
  }) {
    if (!containsKey(key)) {
      this[key] = defaultValue;
    } else {
      if (!overwrite) {
        return;
      }
    }
    if (value != null && containsKey(key)) {
      this[key] = value(this[key] as TV);
    }
  }
}

extension GetOnMapExtension<TK, TV> on Map<TK, TV> {
  TV? get(TK key, [TV? defaultValue]) =>
      !containsKey(key) ? defaultValue : this[key];
  TV getOr(TK key, TV defaultValue) =>
      !containsKey(key) ? defaultValue : this[key]!;
}
