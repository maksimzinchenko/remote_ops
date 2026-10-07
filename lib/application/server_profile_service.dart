// Создание и удаление профилей. Пароль пишется только в SecretStorage.
import 'package:uuid/uuid.dart';

import '../core/errors/app_failure.dart';
import '../core/logging/app_logger.dart';
import '../domain/entities/authentication.dart';
import '../domain/entities/server_profile.dart';
import '../domain/repositories/host_key_store.dart';
import '../domain/repositories/secret_storage.dart';
import '../domain/repositories/server_repository.dart';

class ServerDraft {
  const ServerDraft({
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
}

class ServerProfileService {
  ServerProfileService({
    required ServerRepository servers,
    required SecretStorage secrets,
    required HostKeyStore hostKeys,
    required AppLogger logger,
    Uuid? uuid,
  })  : _servers = servers,
        _secrets = secrets,
        _hostKeys = hostKeys,
        _logger = logger,
        _uuid = uuid ?? const Uuid();

  final ServerRepository _servers;
  final SecretStorage _secrets;
  final HostKeyStore _hostKeys;
  final AppLogger _logger;
  final Uuid _uuid;

  Future<List<ServerProfile>> list() async {
    final profiles = await _servers.list();
    profiles.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return profiles;
  }

  Future<ServerProfile> create(ServerDraft draft) async {
    final normalized = _validate(draft, passwordRequired: true);
    final id = _uuid.v4();
    final secretKey = passwordSecretKey(id);
    final now = DateTime.now().toUtc();
    final profile = ServerProfile(
      id: id,
      name: normalized.name,
      host: normalized.host,
      port: normalized.port,
      username: normalized.username,
      authentication: PasswordAuthentication(secretKey: secretKey),
      createdAt: now,
      updatedAt: now,
    );
    await _secrets.save(secretKey, normalized.password);
    try {
      await _servers.save(profile);
    } catch (error, stackTrace) {
      await _secrets.delete(secretKey);
      _logger.error('failed to save server profile', error: error, stackTrace: stackTrace);
      throw const AppFailure(
        kind: AppFailureKind.storage,
        code: AppMessage.saveFailed,
      );
    }
    _logger.info('server profile created', fields: {'host': profile.host, 'port': profile.port});
    return profile;
  }

  Future<void> delete(String id) async {
    final existing = await _servers.findById(id);
    if (existing == null) {
      throw const AppFailure(
        kind: AppFailureKind.notFound,
        code: AppMessage.profileNotFound,
      );
    }
    await _servers.delete(id);
    final auth = existing.authentication;
    if (auth is PasswordAuthentication) {
      await _secrets.delete(auth.secretKey);
    } else if (auth is PrivateKeyAuthentication) {
      await _secrets.delete(auth.privateKeySecretKey);
      final passphrase = auth.passphraseSecretKey;
      if (passphrase != null) {
        await _secrets.delete(passphrase);
      }
    }
    final others = await _servers.list();
    final stillUsed = others.any(
      (profile) => profile.host == existing.host && profile.port == existing.port,
    );
    if (!stillUsed) {
      await _hostKeys.delete(existing.host, existing.port);
    }
    _logger.info('server profile deleted', fields: {'host': existing.host, 'port': existing.port});
  }

  ServerDraft _validate(ServerDraft draft, {required bool passwordRequired}) {
    final name = draft.name.trim();
    final host = draft.host.trim();
    final username = draft.username.trim();
    if (name.isEmpty || host.isEmpty || username.isEmpty) {
      throw const AppFailure(
        kind: AppFailureKind.validation,
        code: AppMessage.requiredFields,
      );
    }
    if (draft.port < 1 || draft.port > 65535) {
      throw const AppFailure(
        kind: AppFailureKind.validation,
        code: AppMessage.invalidPort,
      );
    }
    if (passwordRequired && draft.password.isEmpty) {
      throw const AppFailure(
        kind: AppFailureKind.validation,
        code: AppMessage.passwordRequired,
      );
    }
    return ServerDraft(
      name: name,
      host: host,
      port: draft.port,
      username: username,
      password: draft.password,
    );
  }

  static String passwordSecretKey(String profileId) => 'server:$profileId:password';
}
