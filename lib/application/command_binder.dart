// Подставляет параметры каталога в шаблон команды до отправки на сервер.
import '../core/errors/app_failure.dart';
import '../domain/entities/command_script.dart';

class CommandBinder {
  const CommandBinder();

  String bind(CommandStep step, List<CommandParameter> parameters, Map<String, String> stored) {
    var command = step.command;
    for (final parameter in parameters) {
      final token = '{{${parameter.id}}}';
      final raw = _raw(parameter, stored);
      if (raw == null) {
        if (parameter.required) {
          throw AppFailure(
            kind: AppFailureKind.validation,
            code: AppMessage.parametersRequired,
            params: {'name': parameter.name},
          );
        }
        command = command.replaceAll(token, '');
        continue;
      }
      command = command.replaceAll(token, _render(parameter, raw));
    }
    return command.replaceAll(RegExp(r'[ \t]{2,}'), ' ').replaceAll(' \n', '\n').trimRight();
  }

  List<CommandParameter> missing(List<CommandParameter> parameters, Map<String, String> stored) {
    return [
      for (final parameter in parameters)
        if (parameter.required && _raw(parameter, stored) == null) parameter,
    ];
  }

  String? _raw(CommandParameter parameter, Map<String, String> stored) {
    final entered = stored[parameter.id]?.trim();
    if (entered != null && entered.isNotEmpty) {
      return entered;
    }
    final fallback = parameter.defaultValue?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return null;
  }

  String _render(CommandParameter parameter, String raw) {
    switch (parameter.type) {
      case CommandParameterType.boolean:
        if (raw != 'true') return '';
        return parameter.trueValue ?? '';
      case CommandParameterType.number:
        if (int.tryParse(raw) == null) {
          throw AppFailure(
            kind: AppFailureKind.validation,
            code: AppMessage.invalidParameter,
            params: {'name': parameter.name},
          );
        }
        return '${parameter.prefix ?? ''}$raw';
      case CommandParameterType.text:
        return _quote(raw);
    }
  }

  String _quote(String value) => "'${value.replaceAll("'", r"'\''")}'";
}
