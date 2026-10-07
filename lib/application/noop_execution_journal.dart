// Журнал-заглушка. Порт уже есть, постоянное хранение не включено.
import '../domain/entities/execution_result.dart';
import '../domain/repositories/execution_journal.dart';

class NoOpExecutionJournal implements ExecutionJournal {
  const NoOpExecutionJournal();

  @override
  Future<void> record(ScriptRun run) async {}
}
