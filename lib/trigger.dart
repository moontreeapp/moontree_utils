import 'dart:async';
import 'package:moontree_utils/exceptions.dart' show AlreadyListening;

typedef Listener<T> = void Function(T event);
typedef Check<T> = bool Function(T event);

abstract class Trigger {
  final Map<String, StreamSubscription> listeners = {};

  Trigger();

  Future<void> when<T>({
    required Stream<T> thereIsA,
    Check<T>? andIf,
    required Listener<T> doThis,
    String? key,
    bool autoDeinit = false,
  }) async {
    key ??= thereIsA.hashCode.toString();
    if (autoDeinit) {
      await deinitKey(key);
    }
    if (!listeners.keys.contains(key)) {
      listeners[key] = thereIsA
          .listen(andIf == null ? doThis : (e) => andIf(e) ? doThis : () {});
    } else {
      throw AlreadyListening('$key already listening');
    }
  }

  Future<void> deinit() async {
    for (var listener in listeners.values) {
      await listener.cancel();
    }
    listeners.clear();
  }

  Future<void> deinitKeys(List<String> keys) async {
    for (var listener in keys) {
      print('removing $listener');
      await listeners[listener]?.cancel();
      listeners.remove(listener);
    }
  }

  Future<void> deinitKey(String key) async => await deinitKeys([key]);
}
