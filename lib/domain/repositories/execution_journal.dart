// Журнал запуска. Первая реализация может ничего не сохранять.
import '../entities/execution_result.dart';

abstract class ExecutionJournal {
  Future<void> record(ScriptRun run);
}
