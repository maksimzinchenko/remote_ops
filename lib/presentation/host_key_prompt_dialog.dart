// Диалог доверия host key. Отказ останавливает подключение.
import 'package:flutter/material.dart';

import '../domain/connections/host_key_prompt.dart';
import '../l10n/generated/app_localizations.dart';

class DialogHostKeyPrompt implements HostKeyPrompt {
  DialogHostKeyPrompt(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Future<bool> confirmUnknown({
    required String host,
    required int port,
    required String keyType,
    required String fingerprint,
  }) {
    final l10n = _l10n;
    if (l10n == null) return Future.value(false);
    return _ask(
      title: l10n.unknownHostKeyTitle,
      body: l10n.unknownHostKeyBody('$host:$port'),
      keyType: keyType,
      fingerprint: fingerprint,
      confirmLabel: l10n.trust,
    );
  }

  @override
  Future<bool> confirmChanged({
    required String host,
    required int port,
    required String keyType,
    required String storedFingerprint,
    required String presentedFingerprint,
  }) {
    final l10n = _l10n;
    if (l10n == null) return Future.value(false);
    return _ask(
      title: l10n.changedHostKeyTitle,
      body: l10n.changedHostKeyBody('$host:$port'),
      keyType: keyType,
      fingerprint: presentedFingerprint,
      previousFingerprint: storedFingerprint,
      confirmLabel: l10n.trustNewKey,
      dangerous: true,
    );
  }

  AppLocalizations? get _l10n {
    final context = navigatorKey.currentContext;
    if (context == null) return null;
    return AppLocalizations.of(context);
  }

  Future<bool> _ask({
    required String title,
    required String body,
    required String keyType,
    required String fingerprint,
    required String confirmLabel,
    String? previousFingerprint,
    bool dangerous = false,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return false;
    }
    final l10n = AppLocalizations.of(context);
    final decision = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(body),
                const SizedBox(height: 16),
                Text(l10n.keyType(keyType)),
                const SizedBox(height: 8),
                if (previousFingerprint != null) ...[
                  Text(l10n.storedFingerprint),
                  SelectableText(previousFingerprint),
                  const SizedBox(height: 8),
                  Text(l10n.presentedFingerprint),
                ] else
                  Text(l10n.fingerprint),
                SelectableText(fingerprint),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.reject),
            ),
            FilledButton(
              style: dangerous
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    )
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return decision ?? false;
  }
}
