// Неизвестный ключ сохраняется только после согласия, смена без согласия отклоняется.
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_ops/application/host_key_coordinator.dart';
import 'package:remote_ops/core/logging/app_logger.dart';
import 'package:remote_ops/domain/connections/host_key_prompt.dart';
import 'package:remote_ops/domain/entities/stored_host_key.dart';
import 'package:remote_ops/domain/repositories/host_key_store.dart';

class _MemoryHostKeys implements HostKeyStore {
  final keys = <String, StoredHostKey>{};

  @override
  Future<void> delete(String host, int port) async => keys.remove('$host:$port');

  @override
  Future<StoredHostKey?> find(String host, int port) async => keys['$host:$port'];

  @override
  Future<void> save(StoredHostKey key) async => keys[key.endpoint] = key;
}

class _Prompt implements HostKeyPrompt {
  _Prompt(this.unknown, this.changed);

  final bool unknown;
  final bool changed;

  @override
  Future<bool> confirmChanged({
    required String host,
    required int port,
    required String keyType,
    required String storedFingerprint,
    required String presentedFingerprint,
  }) async =>
      changed;

  @override
  Future<bool> confirmUnknown({
    required String host,
    required int port,
    required String keyType,
    required String fingerprint,
  }) async =>
      unknown;
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
  test('unknown key is stored only after explicit trust', () async {
    final store = _MemoryHostKeys();
    final coordinator = HostKeyCoordinator(
      store: store,
      prompt: _Prompt(true, false),
      logger: _SilentLogger(),
    );

    final trusted = await coordinator.verify(
      host: '10.0.0.10',
      port: 22,
      keyType: 'ssh-ed25519',
      fingerprint: 'SHA256:abc',
    );

    expect(trusted, isTrue);
    expect((await store.find('10.0.0.10', 22))?.fingerprint, 'SHA256:abc');
  });

  test('changed key is rejected without explicit confirmation', () async {
    final store = _MemoryHostKeys();
    await store.save(
      StoredHostKey(
        host: '10.0.0.10',
        port: 22,
        keyType: 'ssh-ed25519',
        fingerprint: 'SHA256:old',
        trustedAt: DateTime.utc(2026),
      ),
    );
    final coordinator = HostKeyCoordinator(
      store: store,
      prompt: _Prompt(true, false),
      logger: _SilentLogger(),
    );

    final trusted = await coordinator.verify(
      host: '10.0.0.10',
      port: 22,
      keyType: 'ssh-ed25519',
      fingerprint: 'SHA256:new',
    );

    expect(trusted, isFalse);
    expect((await store.find('10.0.0.10', 22))?.fingerprint, 'SHA256:old');
  });
}
