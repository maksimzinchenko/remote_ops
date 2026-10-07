// Фабрика одного короткого SSH-соединения, не пула сессий.
import '../../application/host_key_coordinator.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/connections/remote_connection.dart';
import '../../domain/connections/remote_connection_factory.dart';
import '../../domain/entities/server_profile.dart';
import 'ssh_remote_connection.dart';

class SshConnectionFactory implements RemoteConnectionFactory {
  SshConnectionFactory({
    required HostKeyCoordinator hostKeys,
    required AppLogger logger,
  })  : _hostKeys = hostKeys,
        _logger = logger;

  final HostKeyCoordinator _hostKeys;
  final AppLogger _logger;

  @override
  Future<RemoteConnection> open({
    required ServerProfile profile,
    required String password,
  }) async {
    return SshRemoteConnection(
      profile: profile,
      password: password,
      logger: _logger,
      onVerifyHostKey: ({
        required String host,
        required int port,
        required String keyType,
        required String fingerprint,
      }) {
        return _hostKeys.verify(
          host: host,
          port: port,
          keyType: keyType,
          fingerprint: fingerprint,
        );
      },
    );
  }
}
