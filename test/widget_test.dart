// Пустой список серверов показывает действие добавления.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_ops/l10n/generated/app_localizations.dart';
import 'package:remote_ops/application/connection_service.dart';
import 'package:remote_ops/application/server_profile_service.dart';
import 'package:remote_ops/core/logging/app_logger.dart';
import 'package:remote_ops/domain/connections/remote_connection.dart';
import 'package:remote_ops/domain/connections/remote_connection_factory.dart';
import 'package:remote_ops/domain/connections/resolved_credentials.dart';
import 'package:remote_ops/domain/entities/command_script.dart';
import 'package:remote_ops/domain/entities/server_profile.dart';
import 'package:remote_ops/domain/entities/stored_host_key.dart';
import 'package:remote_ops/domain/repositories/host_key_store.dart';
import 'package:remote_ops/domain/repositories/script_catalog.dart';
import 'package:remote_ops/domain/repositories/secret_storage.dart';
import 'package:remote_ops/domain/repositories/server_repository.dart';
import 'package:remote_ops/presentation/app_scope.dart';
import 'package:remote_ops/presentation/screens/servers_screen.dart';

class _SilentLogger implements AppLogger {
  @override
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, Object?> fields = const {}}) {}

  @override
  void info(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void warning(String message, {Map<String, Object?> fields = const {}}) {}
}

class _Servers implements ServerRepository {
  final items = <ServerProfile>[];

  @override
  Future<void> delete(String id) async => items.removeWhere((item) => item.id == id);

  @override
  Future<ServerProfile?> findById(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<ServerProfile>> list() async => items;

  @override
  Future<void> save(ServerProfile profile) async => items.add(profile);
}

class _Secrets implements SecretStorage {
  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> get(String key) async => null;

  @override
  Future<void> save(String key, String value) async {}
}

class _HostKeys implements HostKeyStore {
  @override
  Future<void> delete(String host, int port) async {}

  @override
  Future<StoredHostKey?> find(String host, int port) async => null;

  @override
  Future<void> save(StoredHostKey key) async {}
}

class _Scripts implements ScriptCatalog {
  @override
  Future<CommandScript?> findById(String id) async => null;

  @override
  Future<List<CommandScript>> list() async => const [];
}

class _Connections implements RemoteConnectionFactory {
  @override
  Future<RemoteConnection> open({
    required ServerProfile profile,
    required ResolvedCredentials credentials,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('shows empty server list and add action', (tester) async {
    final logger = _SilentLogger();
    final servers = _Servers();
    final secrets = _Secrets();
    final profiles = ServerProfileService(
      servers: servers,
      secrets: secrets,
      hostKeys: _HostKeys(),
      logger: logger,
    );
    await tester.pumpWidget(
      AppScope(
        profiles: profiles,
        scripts: _Scripts(),
        connections: ConnectionService(
          servers: servers,
          secrets: secrets,
          connections: _Connections(),
          logger: logger,
        ),
        execution: ScriptExecutionService(
          connections: ConnectionService(
            servers: servers,
            secrets: secrets,
            connections: _Connections(),
            logger: logger,
          ),
          scripts: _Scripts(),
          logger: logger,
        ),
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ServersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Servers'), findsOneWidget);
    expect(find.textContaining('No server profiles'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });
}
