// Список профилей: добавление и удаление.
import 'package:flutter/material.dart';

import '../../core/errors/app_failure.dart';
import '../../domain/entities/server_profile.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../l10n/app_text.dart';
import 'server_detail_screen.dart';
import 'server_form_screen.dart';

class ServersScreen extends StatefulWidget {
  const ServersScreen({super.key});

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  List<ServerProfile> _profiles = [];
  bool _loading = true;
  AppFailure? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profiles = await AppScope.of(context).profiles.list();
      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        _loading = false;
      });
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure;
        _loading = false;
      });
    }
  }

  Future<void> _delete(ServerProfile profile) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProfileTitle),
        content: Text(l10n.deleteProfileBody(profile.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await AppScope.of(context).profiles.delete(profile.id);
      await _load();
    } on AppFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failureText(AppLocalizations.of(context), failure.code, failure.params))),
      );
    }
  }

  Future<void> _add() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ServerFormScreen()),
    );
    if (created == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.serversTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(l10n.addServer),
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(failureText(l10n, _error!.code, _error!.params)));
    }
    if (_profiles.isEmpty) {
      return Center(child: Text(l10n.emptyServers, textAlign: TextAlign.center));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _profiles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final profile = _profiles[index];
          return Card(
            child: ListTile(
              title: Text(profile.name),
              subtitle: Text('${profile.username}@${profile.host}:${profile.port}'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ServerDetailScreen(profileId: profile.id)),
                );
              },
              trailing: IconButton(
                tooltip: l10n.delete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(profile),
              ),
            ),
          );
        },
      ),
    );
  }
}
