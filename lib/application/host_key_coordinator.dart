// Сравнение отпечатка с локальным. Новый и изменившийся ключ требуют явного ответа.
import 'dart:async';

import '../core/errors/app_failure.dart';
import '../core/logging/app_logger.dart';
import '../domain/connections/host_key_prompt.dart';
import '../domain/connections/host_key_verifier.dart';
import '../domain/entities/host_endpoint.dart';
import '../domain/entities/stored_host_key.dart';
import '../domain/repositories/host_key_store.dart';

/// Trust-on-first-use with an explicit warning when a stored fingerprint changes.
class HostKeyCoordinator implements HostKeyVerifier {
  HostKeyCoordinator({
    required HostKeyStore store,
    required HostKeyPrompt prompt,
    required AppLogger logger,
  })  : _store = store,
        _prompt = prompt,
        _logger = logger;

  final HostKeyStore _store;
  final HostKeyPrompt _prompt;
  final AppLogger _logger;
  Future<void> _promptQueue = Future<void>.value();

  @override
  Future<bool> verify({
    required String host,
    required int port,
    required String keyType,
    required String fingerprint,
  }) {
    final gate = Completer<void>();
    final previous = _promptQueue;
    _promptQueue = gate.future;
    return previous.catchError((_) {}).then((_) {
      return _verify(
        host: normalizeHost(host),
        port: port,
        keyType: keyType,
        fingerprint: fingerprint,
      );
    }).whenComplete(gate.complete);
  }

  Future<bool> _verify({
    required String host,
    required int port,
    required String keyType,
    required String fingerprint,
  }) async {
    final stored = await _store.find(host, port);
    if (stored == null) {
      _logger.info(
        'unknown host key',
        fields: {'host': host, 'port': port, 'keyType': keyType},
      );
      final trusted = await _prompt.confirmUnknown(
        host: host,
        port: port,
        keyType: keyType,
        fingerprint: fingerprint,
      );
      if (!trusted) {
        return false;
      }
      await _store.save(
        StoredHostKey(
          host: host,
          port: port,
          keyType: keyType,
          fingerprint: fingerprint,
          trustedAt: DateTime.now().toUtc(),
        ),
      );
      return true;
    }

    if (stored.fingerprint == fingerprint && stored.keyType == keyType) {
      return true;
    }

    _logger.warning(
      'host key mismatch',
      fields: {'host': host, 'port': port, 'keyType': keyType},
    );
    final trusted = await _prompt.confirmChanged(
      host: host,
      port: port,
      keyType: keyType,
      storedFingerprint: stored.fingerprint,
      presentedFingerprint: fingerprint,
    );
    if (!trusted) {
      return false;
    }
    await _store.save(
      StoredHostKey(
        host: host,
        port: port,
        keyType: keyType,
        fingerprint: fingerprint,
        trustedAt: DateTime.now().toUtc(),
      ),
    );
    return true;
  }
}

AppFailure hostKeyRejectedFailure() {
  return const AppFailure(
    kind: AppFailureKind.hostKeyRejected,
    code: AppMessage.hostKeyRejected,
  );
}
