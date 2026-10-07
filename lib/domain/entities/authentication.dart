// Способ входа. Пароль здесь не лежит, только ссылка на секрет.
sealed class Authentication {
  const Authentication();

  String get type;

  Map<String, Object?> toJson();

  static Authentication fromJson(Map<String, Object?> json) {
    final type = json['type'];
    switch (type) {
      case 'password':
        final secretKey = json['secretKey'];
        if (secretKey is! String || secretKey.isEmpty) {
          throw const FormatException('password authentication has no secretKey');
        }
        return PasswordAuthentication(secretKey: secretKey);
      case 'privateKey':
        final privateKeySecretKey = json['privateKeySecretKey'];
        if (privateKeySecretKey is! String || privateKeySecretKey.isEmpty) {
          throw const FormatException('private key authentication has no key reference');
        }
        final passphrase = json['passphraseSecretKey'];
        return PrivateKeyAuthentication(
          privateKeySecretKey: privateKeySecretKey,
          passphraseSecretKey: passphrase is String && passphrase.isNotEmpty
              ? passphrase
              : null,
        );
      default:
        throw FormatException('unsupported authentication type: $type');
    }
  }
}

final class PasswordAuthentication extends Authentication {
  const PasswordAuthentication({required this.secretKey});

  /// Key inside [SecretStorage], never the password itself.
  final String secretKey;

  @override
  String get type => 'password';

  @override
  Map<String, Object?> toJson() => {
        'type': type,
        'secretKey': secretKey,
      };
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

  @override
  Map<String, Object?> toJson() => {
        'type': type,
        'privateKeySecretKey': privateKeySecretKey,
        'passphraseSecretKey': passphraseSecretKey,
      };
}
