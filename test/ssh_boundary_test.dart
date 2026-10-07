// Инфраструктура SSH не должна зависеть от application-слоя.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ssh factory depends on the host key port, not the coordinator', () {
    final source = File('lib/infrastructure/ssh/ssh_connection_factory.dart').readAsStringSync();
    expect(source.contains('application/'), isFalse);
    expect(source.contains('HostKeyVerifier'), isTrue);
    expect(source.contains('ResolvedCredentials'), isTrue);
  });
}
