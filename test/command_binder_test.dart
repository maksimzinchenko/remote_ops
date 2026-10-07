import 'package:flutter_test/flutter_test.dart';
import 'package:remote_ops/application/command_binder.dart';
import 'package:remote_ops/core/errors/app_failure.dart';
import 'package:remote_ops/domain/entities/command_script.dart';

void main() {
  const binder = CommandBinder();
  const step = CommandStep(id: 'mkdir', name: 'mkdir', command: 'mkdir {{parents}} {{mode}} -- {{path}}');
  const parameters = [
    CommandParameter(id: 'path', name: 'Path', type: CommandParameterType.text, required: true),
    CommandParameter(id: 'mode', name: 'Mode', type: CommandParameterType.number, required: false, prefix: '-m '),
    CommandParameter(id: 'parents', name: 'Parents', type: CommandParameterType.boolean, required: false, trueValue: '-p'),
  ];

  test('quotes text, drops empty optional values, and keeps an explicit false', () {
    final command = binder.bind(step, parameters, {'path': "/tmp/o'hare", 'parents': 'false'});
    expect(command, "mkdir -- '/tmp/o'\\''hare'");
  });

  test('inserts optional number and bool fragments', () {
    final command = binder.bind(step, parameters, {'path': '/tmp/remote-ops-param', 'mode': '755', 'parents': 'true'});
    expect(command, "mkdir -p -m 755 -- '/tmp/remote-ops-param'");
  });

  test('does not build a command when a required value is missing', () {
    expect(binder.missing(parameters, {}), isNotEmpty);
    expect(
      () => binder.bind(step, parameters, {}),
      throwsA(isA<AppFailure>().having((failure) => failure.code, 'code', AppMessage.parametersRequired)),
    );
  });
}
