// Блок команд из файла. titleKey необязателен: без него UI берёт name.
class CommandScript {
  const CommandScript({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.stopOnError,
    this.titleKey,
    this.descriptionKey,
  });

  final String id;
  final String name;
  final String description;
  final String? titleKey;
  final String? descriptionKey;
  final List<CommandStep> steps;
  final bool stopOnError;
}

class CommandStep {
  const CommandStep({
    required this.id,
    required this.name,
    required this.command,
    this.titleKey,
  });

  final String id;
  final String name;
  final String command;
  final String? titleKey;
}
