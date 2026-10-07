# ssh

Реализация RemoteConnection на dartssh2 4.1.0. Фабрика зависит от HostKeyVerifier и ResolvedCredentials, не от application-сервисов.

Соединение создаётся на один запуск блока и закрывается вызывающим сценарием. Пула сессий нет. Вывод декодируется как UTF-8. Таймаут берётся из ConnectionOptions.

