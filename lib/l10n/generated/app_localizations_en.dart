// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Remote Ops';

  @override
  String get serversTitle => 'Servers';

  @override
  String get addServer => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get testConnection => 'Test connection';

  @override
  String get connecting => 'Connecting...';

  @override
  String get newServer => 'New server';

  @override
  String get name => 'Name';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get requiredField => 'Required field';

  @override
  String get invalidPort => 'Port must be 1–65535';

  @override
  String get emptyServers =>
      'No server profiles yet.\nAdd the first one to connect over SSH.';

  @override
  String get deleteProfileTitle => 'Delete profile';

  @override
  String deleteProfileBody(String name) {
    return 'Delete \"$name\"? The password will be removed from secure storage.';
  }

  @override
  String get serverFallback => 'Server';

  @override
  String get profileMissing => 'Profile not found.';

  @override
  String get runHint =>
      'The block runs on this server. The connection opens for the run and closes when it finishes.';

  @override
  String get connectionSucceeded =>
      'Connection succeeded. The profile is not saved yet.';

  @override
  String get unknownHostKeyTitle => 'New server key';

  @override
  String unknownHostKeyBody(String endpoint) {
    return 'There is no saved fingerprint for $endpoint. The connection continues only if you trust this key.';
  }

  @override
  String get changedHostKeyTitle => 'Server key changed';

  @override
  String changedHostKeyBody(String endpoint) {
    return 'The fingerprint of $endpoint does not match the saved one. The connection will not continue silently: this may be a server impersonation.';
  }

  @override
  String get trust => 'Trust';

  @override
  String get trustNewKey => 'Trust the new key';

  @override
  String get reject => 'Reject';

  @override
  String keyType(String type) {
    return 'Type: $type';
  }

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get storedFingerprint => 'Saved fingerprint';

  @override
  String get presentedFingerprint => 'New fingerprint';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRunning => 'Connecting and running...';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get stdout => 'stdout';

  @override
  String get stderr => 'stderr';

  @override
  String exitCode(String code) {
    return 'Exit code: $code';
  }

  @override
  String duration(String seconds) {
    return 'Duration: $seconds s';
  }

  @override
  String get scriptCheckStatusName => 'Status check';

  @override
  String get scriptCheckStatusDescription =>
      'Uptime, memory and disk. The file is read-only and is not edited in the app.';

  @override
  String get scriptIdentityName => 'Identity';

  @override
  String get scriptIdentityDescription => 'User, host and system.';

  @override
  String get scriptProcessesName => 'Processes';

  @override
  String get scriptProcessesDescription => 'Top processes by CPU.';

  @override
  String get stepUptime => 'Uptime';

  @override
  String get stepMemory => 'Memory';

  @override
  String get stepDisk => 'Disk';

  @override
  String get stepWho => 'User and host';

  @override
  String get stepPs => 'Process list';

  @override
  String get scriptInstallDockerName => 'Install Docker';

  @override
  String get scriptInstallDockerDescription =>
      'Installs Docker Engine on Linux when it is missing. An existing Docker is left as is.';

  @override
  String get stepInstallDocker => 'Docker Engine';

  @override
  String get dockerStatusInstalled => 'Installed successfully';

  @override
  String get dockerStatusAlready => 'Already on the server';

  @override
  String get dockerStatusFailed =>
      'Installation failed. Details are in the output below.';

  @override
  String get dockerStatusNeedRoot =>
      'Installation failed: root or passwordless sudo is required.';

  @override
  String get dockerStatusUnsupported =>
      'Installation failed: this Linux distribution is not supported.';

  @override
  String get dockerStatusNoDaemon =>
      'Installation failed: packages are present, but the Docker daemon is not responding.';

  @override
  String get dockerStatusNetwork =>
      'Installation failed: the installer could not be downloaded.';

  @override
  String get failureProfileNotFound => 'Server profile not found.';

  @override
  String get failurePasswordAuthOnly =>
      'This version supports password authentication only.';

  @override
  String get failurePasswordMissing =>
      'The profile password was not found in secure storage.';

  @override
  String get failureConnectionFailed => 'Could not connect to the server.';

  @override
  String get failureScriptNotFound => 'Command block not found.';

  @override
  String get failureHostKeyRejected =>
      'Connection stopped: the server key was not confirmed.';

  @override
  String get failureSaveFailed => 'Could not save the server profile.';

  @override
  String get failureRequiredFields => 'Name, host and username are required.';

  @override
  String get failureInvalidPort => 'Port must be in the range 1–65535.';

  @override
  String get failurePasswordRequired => 'Password is required.';

  @override
  String get failureNotConnected => 'There is no active SSH connection.';

  @override
  String get failureTimeout => 'The server did not respond in time.';

  @override
  String get failureAuthFailed =>
      'Sign-in failed: check the username and password.';

  @override
  String get failureHostKeyDenied => 'Server key rejected.';

  @override
  String get failureHandshake => 'SSH handshake failed.';

  @override
  String get failureDisconnected => 'The server closed the connection.';

  @override
  String get failureSshError => 'SSH connection error.';

  @override
  String get failureOperationFailed =>
      'Could not complete the operation on the server.';

  @override
  String get failureDns => 'Could not resolve the server name.';

  @override
  String get failureRefused => 'The server refused the connection.';

  @override
  String get failureNetwork => 'The network is unreachable.';

  @override
  String get failureUnreachable => 'The server is unreachable.';

  @override
  String failureCommandFailed(String name, String code) {
    return 'Command \"$name\" finished with code $code.';
  }

  @override
  String get failureScriptInterrupted => 'The command block was interrupted.';
}
