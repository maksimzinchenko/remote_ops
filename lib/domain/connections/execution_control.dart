// Отмена и поток вывода. Итог по-прежнему ExecutionResult, не единственный канал.
import 'dart:async';

enum OutputChannel { stdout, stderr }

class OutputChunk {
  const OutputChunk({required this.channel, required this.text});

  final OutputChannel channel;
  final String text;
}

abstract class ExecutionObserver {
  void onOutput(OutputChunk chunk);
}

class RunCancellation {
  final _done = Completer<void>();

  bool get isCancelled => _done.isCompleted;

  Future<void> get onCancel => _done.future;

  void cancel() {
    if (!_done.isCompleted) {
      _done.complete();
    }
  }
}
