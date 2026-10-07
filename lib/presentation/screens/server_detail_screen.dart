// Один сервер и блоки из файла. Запуск идёт по одному блоку и ждёт завершения.
import 'package:flutter/material.dart';

import '../../application/command_binder.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/command_script.dart';
import '../../domain/entities/server_profile.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../l10n/app_text.dart';
import 'command_parameters_screen.dart';
import 'execution_screen.dart';
import 'server_form_screen.dart';

class ServerDetailScreen extends StatefulWidget {
  const ServerDetailScreen({super.key, required this.profileId});

  final String profileId;

  @override
  State<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends State<ServerDetailScreen> {
  ServerProfile? _profile;
  List<CommandScript> _scripts = [];
  AppFailure? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final scope = AppScope.of(context);
    try {
      final profile = await scope.profiles.find(widget.profileId);
      final scripts = await scope.scripts.list();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _scripts = scripts;
        _error = profile == null ? AppFailure(kind: AppFailureKind.notFound, code: AppMessage.profileNotFound) : null;
      });
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = _profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(profile?.name ?? l10n.serverFallback),
        actions: [
          if (profile != null)
            IconButton(
              tooltip: l10n.save,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final saved = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => ServerFormScreen(profileId: profile.id)),
                );
                if (saved == true) {
                  await _load();
                }
              },
            ),
        ],
      ),
      body: _error != null
          ? Center(child: Text(failureText(l10n, _error!.code, _error!.params)))
          : profile == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('${profile.username}@${profile.host}:${profile.port}'),
                    const SizedBox(height: 8),
                    Text(l10n.runHint, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    for (final script in _scripts)
                      Card(
                        child: ListTile(
                          title: Text(scriptTitle(l10n, script)),
                          subtitle: Text(scriptDescription(l10n, script)),
                          trailing: _actions(profile.id, script),
                          onTap: () => _run(profile.id, script),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _actions(String profileId, CommandScript script) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (script.parameters.isNotEmpty)
          IconButton(
            tooltip: AppLocalizations.of(context).parameters,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _configure(profileId, script),
          ),
        const Icon(Icons.play_arrow),
      ],
    );
  }

  Future<void> _configure(String profileId, CommandScript script) async {
    final run = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CommandParametersScreen(profileId: profileId, script: script),
      ),
    );
    if (run == true && mounted) {
      await _openRun(profileId, script);
    }
  }

  Future<void> _run(String profileId, CommandScript script) async {
    if (script.parameters.isEmpty) {
      await _openRun(profileId, script);
      return;
    }
    final stored = await AppScope.of(context).parameters.read(profileId, script.id);
    if (!mounted) return;
    if (const CommandBinder().missing(script.parameters, stored).isNotEmpty) {
      await _configure(profileId, script);
      return;
    }
    await _openRun(profileId, script);
  }

  Future<void> _openRun(String profileId, CommandScript script) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExecutionScreen(
          profileId: profileId,
          scriptId: script.id,
          scriptName: scriptTitle(AppLocalizations.of(context), script),
        ),
      ),
    );
  }
}
