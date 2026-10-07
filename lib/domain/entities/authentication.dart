// Способ входа. Пароль и ключ здесь не лежат, только ссылки на секреты.
sealed class Authentication {
  const Authentication();

  String get type;
}

final class PasswordAuthentication extends Authentication {
  const PasswordAuthentication({required this.secretKey});

  /// Key inside SecretStorage, never the password itself.
  final String secretKey;

  @override
  String get type => 'password';
}

final class PrivateKeyAuthentication extends Authentication {
  const PrivateKeyAuthentication({
    required this.privateKeySecretKey,
    this.passphraseSecretKey,
  });

  final String privateKeySecretKey;
  final String? passphraseSecretKey;

  @override
  String get type => 'privateKey';
}
