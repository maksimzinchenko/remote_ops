// Зависимости экранов. Экраны не создают SSH-клиент сами.
import 'package:flutter/material.dart';

import '../application/connection_service.dart';
import '../application/server_profile_service.dart';
import '../domain/repositories/script_catalog.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.profiles,
    required this.scripts,
    required this.connections,
    required this.execution,
    required super.child,
  });

  final ServerProfileService profiles;
  final ScriptCatalog scripts;
  final ConnectionService connections;
  final ScriptExecutionService execution;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
