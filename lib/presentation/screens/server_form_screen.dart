// Форма нового профиля. Проверка подключения не оставляет сессию.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../application/server_profile_service.dart';
import '../../core/errors/app_failure.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../l10n/app_text.dart';

class ServerFormScreen extends StatefulWidget {
  const ServerFormScreen({super.key, this.profileId});

  final String? profileId;

  @override
  State<ServerFormScreen> createState() => _ServerFormScreenState();
}

class _ServerFormScreenState extends State<ServerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController(text: '22');
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _saving = false;
  bool _testing = false;
  bool _obscure = true;
  bool _loaded = false;

  bool get _editing => widget.profileId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = widget.profileId;
    if (id == null) {
      setState(() => _loaded = true);
      return;
    }
    final profile = await AppScope.of(context).profiles.find(id);
    if (!mounted) return;
    if (profile != null) {
      _name.text = profile.name;
      _host.text = profile.host;
      _port.text = '${profile.port}';
      _username.text = profile.username;
    }
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _name.dispose();
    _host.dispose();
    _port.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  ServerDraft? _draft({required bool passwordRequired}) {
    if (_formKey.currentState?.validate() != true) {
      return null;
    }
    if (passwordRequired && _password.text.isEmpty) {
      _show(AppLocalizations.of(context).failurePasswordRequired);
      return null;
    }
    return ServerDraft(
      name: _name.text,
      host: _host.text,
      port: int.parse(_port.text),
      username: _username.text,
      password: _password.text,
    );
  }

  Future<void> _save() async {
    final draft = _draft(passwordRequired: !_editing);
    if (draft == null) return;
    setState(() => _saving = true);
    final profiles = AppScope.of(context).profiles;
    final id = widget.profileId;
    try {
      if (id == null) {
        await profiles.create(draft);
      } else {
        await profiles.update(id, draft);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppFailure catch (failure) {
      if (!mounted) return;
      _show(failureText(AppLocalizations.of(context), failure.code, failure.params));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _test() async {
    final draft = _draft(passwordRequired: true);
    if (draft == null) return;
    setState(() => _testing = true);
    try {
      await AppScope.of(context).connections.testDraft(draft);
      if (!mounted) return;
      _show(AppLocalizations.of(context).connectionSucceeded);
    } on AppFailure catch (failure) {
      if (!mounted) return;
      _show(failureText(AppLocalizations.of(context), failure.code, failure.params));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = _saving || _testing;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? l10n.serverFallback : l10n.newServer)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.name),
              textInputAction: TextInputAction.next,
              validator: (value) => _required(value, l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _host,
              decoration: InputDecoration(labelText: l10n.host),
              textInputAction: TextInputAction.next,
              validator: (value) => _required(value, l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _port,
              decoration: InputDecoration(labelText: l10n.port),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final port = int.tryParse(value ?? '');
                if (port == null || port < 1 || port > 65535) {
                return l10n.invalidPort;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: InputDecoration(labelText: l10n.username),
              textInputAction: TextInputAction.next,
              validator: (value) => _required(value, l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: InputDecoration(
                labelText: l10n.password,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              obscureText: _obscure,
              validator: (value) => _editing ? null : _required(value, l10n),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: busy ? null : _save,
              child: Text(_saving ? l10n.saving : l10n.save),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: busy ? null : _test,
              child: Text(_testing ? l10n.connecting : l10n.testConnection),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.requiredField;
    }
    return null;
  }
}
