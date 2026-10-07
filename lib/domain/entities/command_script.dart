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
    this.parameters = const [],
  });

  final String id;
  final String name;
  final String description;
  final String? titleKey;
  final String? descriptionKey;
  final List<CommandStep> steps;
  final List<CommandParameter> parameters;
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

enum CommandParameterType { text, number, boolean }

// Схема параметра из каталога. Введённое значение здесь не хранится.
class CommandParameter {
  const CommandParameter({
    required this.id,
    required this.name,
    required this.type,
    required this.required,
    this.labelKey,
    this.defaultValue,
    this.trueValue,
    this.prefix,
  });

  final String id;
  final String name;
  final String? labelKey;
  final CommandParameterType type;
  final bool required;
  final String? defaultValue;
  final String? trueValue;
  final String? prefix;
}
