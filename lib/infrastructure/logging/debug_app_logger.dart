// Лог разработчика. Поля password, key и token не печатаются.
import 'dart:developer' as developer;

import '../../core/logging/app_logger.dart';

class DebugAppLogger implements AppLogger {
  @override
  void info(String message, {Map<String, Object?> fields = const {}}) {
    developer.log(_format(message, fields), name: 'remote_ops');
  }

  @override
  void warning(String message, {Map<String, Object?> fields = const {}}) {
    developer.log(_format(message, fields), name: 'remote_ops', level: 900);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const {},
  }) {
    developer.log(
      _format(message, fields),
      name: 'remote_ops',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  String _format(String message, Map<String, Object?> fields) {
    final safe = <String, Object?>{};
    for (final entry in fields.entries) {
      if (forbiddenLogKeys.contains(entry.key.toLowerCase())) {
        continue;
      }
      safe[entry.key] = entry.value;
    }
    if (safe.isEmpty) {
      return message;
    }
    return '$message $safe';
  }
}
