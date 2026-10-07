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
      error: _safeError(error),
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
      safe[entry.key] = _safeValue(entry.value);
    }
    if (safe.isEmpty) {
      return message;
    }
    return '$message $safe';
  }

  Object? _safeError(Object? error) {
    if (error == null) return null;
    final text = error.toString();
    if (_looksSensitive(text)) {
      return error.runtimeType;
    }
    return error;
  }

  Object? _safeValue(Object? value) {
    if (value is! String) return value;
    return _looksSensitive(value) ? '[redacted]' : value;
  }

  bool _looksSensitive(String value) {
    final lower = value.toLowerCase();
    return lower.contains('private key') ||
        lower.contains('passphrase') ||
        lower.contains('password=') ||
        lower.contains('begin openssh') ||
        lower.contains('begin rsa');
  }
}
