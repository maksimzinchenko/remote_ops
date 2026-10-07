// Блок команд из файла. В приложении эта модель не редактируется.
class CommandScript {
  const CommandScript({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.stopOnError,
  });

  final String id;
  final String name;
  final String description;
  final List<CommandStep> steps;
  final bool stopOnError;
}

class CommandStep {
  const CommandStep({
    required this.id,
    required this.name,
    required this.command,
  });

  final String id;
  final String name;
  final String command;
}
