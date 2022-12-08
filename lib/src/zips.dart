Map<dynamic, dynamic> zipMap(List<dynamic> names, List<dynamic> values) =>
    <dynamic, dynamic>{
      for (int i = 0; i < names.length; i += 1) names[i]: values[i]
    };

List<dynamic> zipIterable(Iterable<List<dynamic>> lists) => <dynamic>[
      for (int i = 0; i < lists.first.length; i += 1)
        <dynamic>[for (List<dynamic> list in lists) list[i]]
    ];
