// Короткое удалённое соединение на один запуск блока команд.
// Постоянных сессий и пула нет: вызывающий обязан закрыть его после выполнения.
import '../entities/execution_result.dart';
import 'execution_control.dart';

abstract class RemoteConnection {
  Future<void> connect();

  Future<ExecutionResult> execute(
    String command, {
    ExecutionObserver? observer,
    RunCancellation? cancellation,
  });

  Future<void> disconnect();

  bool get isConnected;
}
