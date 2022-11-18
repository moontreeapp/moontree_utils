Generic Dart Utilities, made specifically to support multiple Moontree repos.

## Example

```dart
//import 'package:utils/utils.dart'; // everything
//import 'package:utils/extensions/extensions.dart'; // all extensions
import 'package:utils/extensions/int.dart'; 
import 'package:utils/mixins.dart' show ToStringMixin;
import 'package:utils/list.dart' show range;

class Example with ToStringMixin {
  final String symbol;

  Example(this.symbol);

  @override
  List<Object?> get props => [symbol];

  @override
  List<String> get propNames => ['symbol'];

  void example() {
    for (var i in range(100, start: 999)) {
      print(i.toCommaString()); // 999 1,000 1,001 ... 1,099 
    }
  }
}
```
