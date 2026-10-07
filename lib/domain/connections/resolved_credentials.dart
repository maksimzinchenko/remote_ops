// Секреты уже прочитаны application-слоем. SSH-порт не ходит в хранилище.
sealed class ResolvedCredentials {
  const ResolvedCredentials();
}

final class PasswordCredentials extends ResolvedCredentials {
  const PasswordCredentials(this.password);

  final String password;
}

final class PrivateKeyCredentials extends ResolvedCredentials {
  const PrivateKeyCredentials({
    required this.privateKeyPem,
    this.passphrase,
  });

  final String privateKeyPem;
  final String? passphrase;
}
