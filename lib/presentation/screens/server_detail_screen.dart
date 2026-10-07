// Один сервер и блоки из файла. Запуск идёт по одному блоку и ждёт завершения.
import 'package:flutter/material.dart';

import '../../core/errors/app_failure.dart';
import '../../domain/entities/command_script.dart';
import '../../domain/entities/server_profile.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../l10n/app_text.dart';
import 'execution_screen.dart';

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
      final profile = await scope.profiles.list().then(
            (items) => items.where((item) => item.id == widget.profileId).firstOrNull,
          );
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
      appBar: AppBar(title: Text(profile?.name ?? l10n.serverFallback)),
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
                          trailing: const Icon(Icons.play_arrow),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ExecutionScreen(
                                  profileId: profile.id,
                                  scriptId: script.id,
                                  scriptName: scriptTitle(l10n, script),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
    );
  }
}
