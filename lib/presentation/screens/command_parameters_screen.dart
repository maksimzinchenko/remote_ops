// Форма параметров блока. Каталог не меняет, пишет только значения этого сервера.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../application/command_binder.dart';
import '../../domain/entities/command_script.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../l10n/app_text.dart';

class CommandParametersScreen extends StatefulWidget {
  const CommandParametersScreen({super.key, required this.profileId, required this.script});

  final String profileId;
  final CommandScript script;

  @override
  State<CommandParametersScreen> createState() => _CommandParametersScreenState();
}

class _CommandParametersScreenState extends State<CommandParametersScreen> {
  final _binder = const CommandBinder();
  final _fields = <String, TextEditingController>{};
  final _flags = <String, bool>{};
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    for (final parameter in widget.script.parameters) {
      if (parameter.type != CommandParameterType.boolean) {
        _fields[parameter.id] = TextEditingController();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final stored = await AppScope.of(context).parameters.read(widget.profileId, widget.script.id);
    for (final parameter in widget.script.parameters) {
      final value = stored[parameter.id];
      if (parameter.type == CommandParameterType.boolean) {
        _flags[parameter.id] = value == 'true';
      } else {
        _fields[parameter.id]!.text = value ?? '';
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  Map<String, String> _values() {
    final values = <String, String>{};
    for (final parameter in widget.script.parameters) {
      if (parameter.type == CommandParameterType.boolean) {
        if (_flags[parameter.id] == true) values[parameter.id] = 'true';
        continue;
      }
      final text = _fields[parameter.id]!.text.trim();
      if (text.isNotEmpty) values[parameter.id] = text;
    }
    return values;
  }

  Future<void> _save({required bool run}) async {
    final values = _values();
    if (_binder.missing(widget.script.parameters, values).isNotEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failureParametersRequired)));
      return;
    }
    await AppScope.of(context).parameters.save(widget.profileId, widget.script.id, values);
    if (mounted) Navigator.of(context).pop(run);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(scriptTitle(l10n, widget.script))),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final parameter in widget.script.parameters) ...[
                  _field(l10n, parameter),
                  const SizedBox(height: 12),
                ],
                FilledButton(onPressed: () => _save(run: true), child: Text(l10n.run)),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () => _save(run: false), child: Text(l10n.save)),
              ],
            ),
    );
  }

  Widget _field(AppLocalizations l10n, CommandParameter parameter) {
    final label = parameterLabel(l10n, parameter);
    if (parameter.type == CommandParameterType.boolean) {
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: parameter.required ? null : Text(l10n.paramOptionalHint),
        value: _flags[parameter.id] ?? false,
        onChanged: (value) => setState(() => _flags[parameter.id] = value),
      );
    }
    return TextFormField(
      controller: _fields[parameter.id],
      decoration: InputDecoration(
        labelText: parameter.required ? label : '$label (${l10n.paramOptionalHint})',
      ),
      keyboardType: parameter.type == CommandParameterType.number ? TextInputType.number : TextInputType.text,
      inputFormatters: parameter.type == CommandParameterType.number ? [FilteringTextInputFormatter.digitsOnly] : null,
    );
  }
}
