// Итог команды и всего блока: вывод, код выхода, длительность.
class ExecutionResult {
  const ExecutionResult({
    required this.command,
    required this.stdout,
    required this.stderr,
    required this.exitCode,
    required this.startedAt,
    required this.finishedAt,
  });

  final String command;
  final String stdout;
  final String stderr;
  final int? exitCode;
  final DateTime startedAt;
  final DateTime finishedAt;

  Duration get duration => finishedAt.difference(startedAt);

  bool get success => exitCode == 0;
}

class ScriptStepResult {
  const ScriptStepResult({
    required this.stepId,
    required this.stepName,
    required this.result,
  });

  final String stepId;
  final String stepName;
  final ExecutionResult result;
}

enum ScriptRunStatus { running, completed, failed, cancelled }

class ScriptRun {
  const ScriptRun({
    required this.scriptId,
    required this.scriptName,
    required this.status,
    required this.steps,
    this.failureCode,
    this.failureParams = const {},
  });

  final String scriptId;
  final String scriptName;
  final ScriptRunStatus status;
  final List<ScriptStepResult> steps;

  /// Код сообщения. Неизвестный код UI показывает общим текстом, без нового switch.
  final String? failureCode;
  final Map<String, String> failureParams;
}
