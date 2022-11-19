// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:math';

//gatherFutures(Iterable<Functions> functions) {
//  var futures = <Future<Tx>>[];
//  futupros.add(functions);
//  return futures;
//}

Timer doLater<T>(
  T Function() callback, {
  Duration? wait,
  int? waitInSeconds,
  int? waitInMilliseconds,
}) {
  wait = wait ??
      (waitInSeconds != null
          ? Duration(seconds: waitInSeconds)
          : Duration(milliseconds: waitInMilliseconds!));
  return Timer(wait, callback);
}

Future<void> simulateWait(String desc, [Duration? duration]) async {
  print('waiting on $desc...');
  await Future.delayed(
      duration ?? Duration(milliseconds: Random().nextInt(10)));
  print('done $desc');
}
