// Точка входа: собирает локальные хранилища и сервисы, не открывая SSH заранее.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'application/connection_service.dart';
import 'application/host_key_coordinator.dart';
import 'application/noop_execution_journal.dart';
import 'application/server_profile_service.dart';
import 'infrastructure/commands/asset_script_catalog.dart';
import 'infrastructure/logging/debug_app_logger.dart';
import 'infrastructure/logging/noop_app_logger.dart';
import 'infrastructure/security/flutter_secret_storage.dart';
import 'infrastructure/ssh/ssh_connection_factory.dart';
import 'infrastructure/storage/file_host_key_store.dart';
import 'infrastructure/storage/file_server_repository.dart';
import 'presentation/app_scope.dart';
import 'presentation/host_key_prompt_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debug пишет в DevTools. profile и release молчат: kDebugMode вырезается при сборке.
  final logger = kDebugMode ? DebugAppLogger() : const NoOpAppLogger();
  final supportDir = await getApplicationSupportDirectory();
  final dataDir = Directory(p.join(supportDir.path, 'remote_ops'));
  await dataDir.create(recursive: true);

  final navigatorKey = GlobalKey<NavigatorState>();
  final hostKeyStore = FileHostKeyStore(File(p.join(dataDir.path, 'host_keys.json')));
  final hostKeys = HostKeyCoordinator(
    store: hostKeyStore,
    prompt: DialogHostKeyPrompt(navigatorKey),
    logger: logger,
  );
  final servers = FileServerRepository(File(p.join(dataDir.path, 'servers.json')));
  final secrets = FlutterSecretStorage();
  final scripts = AssetScriptCatalog();
  final profiles = ServerProfileService(
    servers: servers,
    secrets: secrets,
    hostKeys: hostKeyStore,
    logger: logger,
  );
  final connections = ConnectionService(
    servers: servers,
    secrets: secrets,
    connections: SshConnectionFactory(hostKeys: hostKeys, logger: logger),
    logger: logger,
  );
  final execution = ScriptExecutionService(
    connections: connections,
    scripts: scripts,
    logger: logger,
    journal: const NoOpExecutionJournal(),
  );

  runApp(
    AppScope(
      profiles: profiles,
      scripts: scripts,
      connections: connections,
      execution: execution,
      child: RemoteOpsMaterialApp(navigatorKey: navigatorKey),
    ),
  );
}
