import 'package:flutter_test/flutter_test.dart';
import 'package:remote_ops/presentation/l10n/app_text.dart';

void main() {
  test('reads the docker result code and ignores other output', () {
    const stdout = '''
Alpine detected.
REMOTE_OPS_STATUS=already_installed
Docker version 27.0.0
''';
    expect(remoteOpsStatus(stdout), 'already_installed');
    expect(remoteOpsStatus('no marker\n'), isNull);
  });
}
