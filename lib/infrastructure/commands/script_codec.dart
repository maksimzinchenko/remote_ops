// Разбор JSON-файла блоков команд. Формат файла не редактируется из UI.
import 'dart:convert';

import '../../domain/entities/command_script.dart';

class ScriptCodec {
  static List<CommandScript> parse(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('command file must be an object');
    }
    final scripts = decoded['scripts'];
    if (scripts is! List) {
      throw const FormatException('command file has no scripts list');
    }
    return scripts.map((item) {
      if (item is! Map) {
        throw const FormatException('script entry must be an object');
      }
      return _script(Map<String, Object?>.from(item));
    }).toList();
  }

  static CommandScript _script(Map<String, Object?> json) {
    final stepsJson = json['steps'];
    if (stepsJson is! List || stepsJson.isEmpty) {
      throw const FormatException('script has no steps');
    }
    return CommandScript(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      description: json['description'] is String ? json['description'] as String : '',
      titleKey: _optional(json, 'titleKey'),
      descriptionKey: _optional(json, 'descriptionKey'),
      stopOnError: json['stopOnError'] is bool ? json['stopOnError'] as bool : true,
      steps: stepsJson.map((step) {
        if (step is! Map) {
          throw const FormatException('command step must be an object');
        }
        final data = Map<String, Object?>.from(step);
        return CommandStep(
          id: _string(data, 'id'),
          name: _string(data, 'name'),
          command: _string(data, 'command'),
          titleKey: _optional(data, 'titleKey'),
        );
      }).toList(),
    );
  }

  static String? _optional(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('missing $key in command file');
    }
    return value;
  }
}
