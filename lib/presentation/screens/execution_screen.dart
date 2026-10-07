// Ожидание одного блока на одном сервере. Соединение к этому экрану не привязано.
import 'package:flutter/material.dart';

import '../../application/connection_service.dart';
import '../../domain/connections/execution_control.dart';
import '../../domain/entities/execution_result.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../l10n/app_text.dart';

class ExecutionScreen extends StatefulWidget {
  const ExecutionScreen({
    super.key,
    required this.profileId,
    required this.scriptId,
    required this.scriptName,
  });

  final String profileId;
  final String scriptId;
  final String scriptName;

  @override
  State<ExecutionScreen> createState() => _ExecutionScreenState();
}

class _ExecutionScreenState extends State<ExecutionScreen> {
  ScriptRun? _run;
  bool _started = false;
  final _cancellation = RunCancellation();
  final _live = <String, _LiveOutput>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runScript());
  }

  Future<void> _runScript() async {
    setState(() => _started = true);
    final run = await AppScope.of(context).execution.run(
          request: CommandBlockRequest(profileId: widget.profileId, scriptId: widget.scriptId),
          cancellation: _cancellation,
          onProgress: (progress) {
            if (mounted) setState(() => _run = progress);
          },
          onOutput: (stepId, chunk) {
            if (!mounted) return;
            setState(() {
              final live = _live.putIfAbsent(stepId, _LiveOutput.new);
              if (chunk.channel == OutputChannel.stdout) {
                live.stdout.write(chunk.text);
              } else {
                live.stderr.write(chunk.text);
              }
            });
          },
        );
    if (mounted) setState(() => _run = run);
  }

  @override
  Widget build(BuildContext context) {
    final run = _run;
    final status = run?.status;
    final l10n = AppLocalizations.of(context);
    final running = status == null || status == ScriptRunStatus.running;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scriptName),
        actions: [
          if (running && _started)
            TextButton(
              onPressed: _cancellation.isCancelled ? null : () => setState(_cancellation.cancel),
              child: Text(l10n.cancel),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusBanner(status: status, run: run, started: _started),
          const SizedBox(height: 16),
          if (_live.isNotEmpty && (run == null || run.steps.isEmpty)) ...[
            for (final entry in _live.entries) ...[
              Text(entry.key),
              _Output(
                text: entry.value.stdout.toString(),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 12),
            ],
          ],
          if (run != null)
            for (final step in run.steps) ...[
              _StepCard(step: step),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status, required this.run, required this.started});

  final ScriptRunStatus? status;
  final ScriptRun? run;
  final bool started;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      ScriptRunStatus.completed => (l10n.statusCompleted, scheme.primary),
      ScriptRunStatus.failed => (l10n.statusFailed, scheme.error),
      ScriptRunStatus.cancelled => (l10n.statusCancelled, scheme.outline),
      ScriptRunStatus.running || null => (started ? l10n.statusRunning : l10n.statusWaiting, scheme.tertiary),
    };
    final failure = run?.failureCode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          if (failure != null) ...[
            const SizedBox(height: 4),
            Text(failureText(l10n, failure, run!.failureParams)),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});

  final ScriptStepResult step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = step.result;
    final scheme = Theme.of(context).colorScheme;
    final ok = result.success;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ok ? Icons.check_circle : Icons.error, color: ok ? scheme.primary : scheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stepTitle(l10n, step.stepId, step.stepName),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('\$ ${result.command}', style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 8),
            Text(l10n.stdout),
            _Output(text: result.stdout, color: scheme.surfaceContainerHighest),
            const SizedBox(height: 8),
            Text(l10n.stderr),
            _Output(text: result.stderr, color: scheme.errorContainer),
            const SizedBox(height: 8),
            Text(l10n.exitCode('${result.exitCode ?? '—'}')),
            Text(l10n.duration((result.duration.inMilliseconds / 1000).toStringAsFixed(2))),
          ],
        ),
      ),
    );
  }
}

class _LiveOutput {
  final stdout = StringBuffer();
  final stderr = StringBuffer();
}

class _Output extends StatelessWidget {
  const _Output({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: SelectableText(
        text.isEmpty ? '—' : text,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      ),
    );
  }
}
