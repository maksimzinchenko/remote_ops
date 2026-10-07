// Один писатель на файл. Нужен, потому что save читает весь JSON и пишет его заново.
import 'dart:async';

class FileMutex {
  static final _tails = <String, Future<void>>{};

  static Future<T> synchronized<T>(String key, Future<T> Function() action) {
    final previous = _tails[key] ?? Future<void>.value();
    final gate = Completer<void>();
    _tails[key] = gate.future;
    return previous.catchError((_) {}).then((_) => action()).whenComplete(() => gate.complete());
  }
}
