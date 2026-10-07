// Файл блока команд разбирается как данные только для чтения.
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_ops/infrastructure/commands/script_codec.dart';

void main() {
  test('parses command blocks and does not expose a write model', () {
    final scripts = ScriptCodec.parse('''
{
  "version": 1,
  "scripts": [
    {
      "id": "check_status",
      "name": "Проверка состояния",
      "description": "read only",
      "stopOnError": true,
      "steps": [
        {"id": "uptime", "name": "Uptime", "command": "uptime"}
      ]
    }
  ]
}
''');

    expect(scripts, hasLength(1));
    expect(scripts.single.steps.single.command, 'uptime');
    expect(scripts.single.stopOnError, isTrue);
  });
}
