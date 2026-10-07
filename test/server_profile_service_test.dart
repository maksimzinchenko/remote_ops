// Профиль сохраняется без пароля, удаление стирает секрет.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remote_ops/application/server_profile_service.dart';
import 'package:remote_ops/core/errors/app_failure.dart';
import 'package:remote_ops/core/logging/app_logger.dart';
import 'package:remote_ops/domain/entities/authentication.dart';
import 'package:remote_ops/domain/entities/stored_host_key.dart';
import 'package:remote_ops/domain/repositories/secret_storage.dart';
import 'package:remote_ops/infrastructure/storage/file_host_key_store.dart';
import 'package:remote_ops/infrastructure/storage/file_server_repository.dart';

class _MemorySecrets implements SecretStorage {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> get(String key) async => values[key];

  @override
  Future<void> save(String key, String value) async => values[key] = value;
}

class _SilentLogger implements AppLogger {
  @override
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, Object?> fields = const {}}) {}

  @override
  void info(String message, {Map<String, Object?> fields = const {}}) {}

  @override
  void warning(String message, {Map<String, Object?> fields = const {}}) {}
}

void main() {
  test('create stores profile without password and delete removes secret', () async {
    final directory = await Directory.systemTemp.createTemp('remote_ops_profiles');
    addTearDown(() => directory.delete(recursive: true));
    final secrets = _MemorySecrets();
    final service = ServerProfileService(
      servers: FileServerRepository(File('${directory.path}/servers.json')),
      secrets: secrets,
      hostKeys: FileHostKeyStore(File('${directory.path}/host_keys.json')),
      logger: _SilentLogger(),
    );

    final created = await service.create(
      const ServerDraft(
        name: 'Production',
        host: '10.0.0.10',
        port: 22,
        username: 'deploy',
        password: 'secret-value',
      ),
    );

    final stored = await service.list();
    expect(stored, hasLength(1));
    expect(stored.single.name, 'Production');
    final auth = stored.single.authentication as PasswordAuthentication;
    expect(auth.secretKey, ServerProfileService.passwordSecretKey(created.id));
    expect(secrets.values[auth.secretKey], 'secret-value');
    expect(File('${directory.path}/servers.json').readAsStringSync().contains('secret-value'), isFalse);

    await service.delete(created.id);
    expect(await service.list(), isEmpty);
    expect(secrets.values.containsKey(auth.secretKey), isFalse);
  });

  test('update keeps the password when the field is empty and moves the host key', () async {
    final directory = await Directory.systemTemp.createTemp('remote_ops_profiles');
    addTearDown(() => directory.delete(recursive: true));
    final secrets = _MemorySecrets();
    final hostKeys = FileHostKeyStore(File('${directory.path}/host_keys.json'));
    final service = ServerProfileService(
      servers: FileServerRepository(File('${directory.path}/servers.json')),
      secrets: secrets,
      hostKeys: hostKeys,
      logger: _SilentLogger(),
    );
    final created = await service.create(
      const ServerDraft(name: 'Production', host: '10.0.0.10', port: 22, username: 'deploy', password: 'secret-value'),
    );
    await hostKeys.save(
      StoredHostKey(
        host: '10.0.0.10',
        port: 22,
        keyType: 'ssh-ed25519',
        fingerprint: 'SHA256:abc',
        trustedAt: DateTime.utc(2026),
      ),
    );

    await service.update(
      created.id,
      const ServerDraft(name: 'Production', host: '10.0.0.11', port: 2222, username: 'deploy', password: ''),
    );

    final stored = await service.list();
    expect(stored.single.host, '10.0.0.11');
    expect(stored.single.port, 2222);
    expect(secrets.values[ServerProfileService.passwordSecretKey(created.id)], 'secret-value');
    expect(await hostKeys.find('10.0.0.10', 22), isNull);
    expect((await hostKeys.find('10.0.0.11', 2222))?.fingerprint, 'SHA256:abc');
    expect(File('${directory.path}/servers.json').readAsStringSync(), contains('"schemaVersion":1'));
  });

  test('legacy server list without schema version still loads', () async {
    final directory = await Directory.systemTemp.createTemp('remote_ops_profiles');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/servers.json');
    await file.writeAsString('''
[
  {
    "id": "s1",
    "name": "Legacy",
    "host": "example.test",
    "port": 22,
    "username": "root",
    "authentication": {"type": "password", "secretKey": "server:s1:password"},
    "createdAt": "2026-01-01T00:00:00.000Z",
    "updatedAt": "2026-01-01T00:00:00.000Z"
  }
]
''');
    final service = ServerProfileService(
      servers: FileServerRepository(file),
      secrets: _MemorySecrets(),
      hostKeys: FileHostKeyStore(File('${directory.path}/host_keys.json')),
      logger: _SilentLogger(),
    );

    final stored = await service.list();
    expect(stored.single.name, 'Legacy');
    expect(stored.single.options.connectTimeout, const Duration(seconds: 20));
  });

  test('create rejects an empty password', () async {
    final directory = await Directory.systemTemp.createTemp('remote_ops_profiles');
    addTearDown(() => directory.delete(recursive: true));
    final service = ServerProfileService(
      servers: FileServerRepository(File('${directory.path}/servers.json')),
      secrets: _MemorySecrets(),
      hostKeys: FileHostKeyStore(File('${directory.path}/host_keys.json')),
      logger: _SilentLogger(),
    );

    expect(
      () => service.create(
        const ServerDraft(name: 'Dev', host: 'example', port: 22, username: 'root', password: ''),
      ),
      throwsA(isA<AppFailure>().having((error) => error.kind, 'kind', AppFailureKind.validation)),
    );
  });
}
