// Пустой лог для profile и release. Вызовы сервисов остаются, вывода нет.
import '../../core/logging/app_logger.dart';

class NoOpAppLogger implements AppLogger {
  const NoOpAppLogger();

  @override
  void info(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void warning(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const {},
  }) {}
}
