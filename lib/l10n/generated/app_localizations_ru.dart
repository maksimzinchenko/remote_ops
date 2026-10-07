// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Remote Ops';

  @override
  String get serversTitle => 'Серверы';

  @override
  String get addServer => 'Добавить';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get saving => 'Сохранение...';

  @override
  String get testConnection => 'Проверить подключение';

  @override
  String get connecting => 'Подключение...';

  @override
  String get newServer => 'Новый сервер';

  @override
  String get name => 'Имя';

  @override
  String get host => 'Хост';

  @override
  String get port => 'Порт';

  @override
  String get username => 'Пользователь';

  @override
  String get password => 'Пароль';

  @override
  String get requiredField => 'Обязательное поле';

  @override
  String get invalidPort => 'Порт 1–65535';

  @override
  String get emptyServers =>
      'Пока нет профилей серверов.\nДобавьте первый, чтобы подключаться по SSH.';

  @override
  String get deleteProfileTitle => 'Удалить профиль';

  @override
  String deleteProfileBody(String name) {
    return 'Удалить «$name»? Пароль будет удалён из защищённого хранилища.';
  }

  @override
  String get serverFallback => 'Сервер';

  @override
  String get profileMissing => 'Профиль не найден.';

  @override
  String get runHint =>
      'Блок выполнится на этом сервере. Соединение откроется на время запуска и закроется после завершения.';

  @override
  String get connectionSucceeded =>
      'Подключение успешно. Профиль ещё не сохранён.';

  @override
  String get unknownHostKeyTitle => 'Новый ключ сервера';

  @override
  String unknownHostKeyBody(String endpoint) {
    return 'Для $endpoint нет сохранённого отпечатка. Подключение продолжится только если вы доверяете этому ключу.';
  }

  @override
  String get changedHostKeyTitle => 'Ключ сервера изменился';

  @override
  String changedHostKeyBody(String endpoint) {
    return 'Отпечаток $endpoint не совпадает с сохранённым. Подключение не будет продолжено молча: это может быть подмена сервера.';
  }

  @override
  String get trust => 'Доверять';

  @override
  String get trustNewKey => 'Доверять новому ключу';

  @override
  String get reject => 'Отклонить';

  @override
  String keyType(String type) {
    return 'Тип: $type';
  }

  @override
  String get fingerprint => 'Отпечаток';

  @override
  String get storedFingerprint => 'Сохранённый отпечаток';

  @override
  String get presentedFingerprint => 'Новый отпечаток';

  @override
  String get statusCompleted => 'Завершено';

  @override
  String get statusFailed => 'Ошибка';

  @override
  String get statusCancelled => 'Отменено';

  @override
  String get statusRunning => 'Подключение и выполнение...';

  @override
  String get statusWaiting => 'Ожидание';

  @override
  String get stdout => 'stdout';

  @override
  String get stderr => 'stderr';

  @override
  String exitCode(String code) {
    return 'Код выхода: $code';
  }

  @override
  String duration(String seconds) {
    return 'Длительность: $seconds с';
  }

  @override
  String get scriptCheckStatusName => 'Проверка состояния';

  @override
  String get scriptCheckStatusDescription =>
      'Время работы, память и диск. Файл только для чтения и не редактируется в приложении.';

  @override
  String get scriptIdentityName => 'Идентификация';

  @override
  String get scriptIdentityDescription => 'Пользователь, хост и система.';

  @override
  String get scriptProcessesName => 'Процессы';

  @override
  String get scriptProcessesDescription => 'Первые процессы по загрузке CPU.';

  @override
  String get stepUptime => 'Uptime';

  @override
  String get stepMemory => 'Память';

  @override
  String get stepDisk => 'Диск';

  @override
  String get stepWho => 'Пользователь и хост';

  @override
  String get stepPs => 'Список процессов';

  @override
  String get scriptInstallDockerName => 'Установка Docker';

  @override
  String get scriptInstallDockerDescription =>
      'Ставит Docker Engine на Linux, если его ещё нет. Уже установленный не трогает.';

  @override
  String get stepInstallDocker => 'Docker Engine';

  @override
  String get dockerStatusInstalled => 'Успешно установлен';

  @override
  String get dockerStatusAlready => 'Уже есть на сервере';

  @override
  String get dockerStatusFailed => 'Ошибка установки. Пояснение в выводе ниже.';

  @override
  String get dockerStatusNeedRoot =>
      'Ошибка установки: нужны root или sudo без пароля.';

  @override
  String get dockerStatusUnsupported =>
      'Ошибка установки: этот дистрибутив Linux не поддерживается.';

  @override
  String get dockerStatusNoDaemon =>
      'Ошибка установки: пакеты есть, но демон Docker не отвечает.';

  @override
  String get dockerStatusNetwork =>
      'Ошибка установки: не удалось скачать установщик.';

  @override
  String get failureProfileNotFound => 'Профиль сервера не найден.';

  @override
  String get failurePasswordAuthOnly =>
      'Эта версия поддерживает только аутентификацию по паролю.';

  @override
  String get failurePasswordMissing =>
      'Пароль профиля не найден в защищённом хранилище.';

  @override
  String get failureConnectionFailed => 'Не удалось подключиться к серверу.';

  @override
  String get failureScriptNotFound => 'Блок команд не найден.';

  @override
  String get failureHostKeyRejected =>
      'Подключение остановлено: ключ сервера не подтверждён.';

  @override
  String get failureSaveFailed => 'Не удалось сохранить профиль сервера.';

  @override
  String get failureRequiredFields => 'Имя, хост и пользователь обязательны.';

  @override
  String get failureInvalidPort => 'Порт должен быть в диапазоне 1–65535.';

  @override
  String get failurePasswordRequired => 'Пароль обязателен.';

  @override
  String get failureNotConnected => 'Нет активного SSH-соединения.';

  @override
  String get failureTimeout => 'Сервер не ответил вовремя.';

  @override
  String get failureAuthFailed =>
      'Не удалось войти: проверьте имя пользователя и пароль.';

  @override
  String get failureHostKeyDenied => 'Ключ сервера отклонён.';

  @override
  String get failureHandshake => 'Ошибка SSH-рукопожатия.';

  @override
  String get failureDisconnected => 'Сервер разорвал соединение.';

  @override
  String get failureSshError => 'Ошибка SSH-соединения.';

  @override
  String get failureOperationFailed =>
      'Не удалось выполнить операцию на сервере.';

  @override
  String get failureDns => 'Не удалось найти сервер по имени.';

  @override
  String get failureRefused => 'Сервер отклонил подключение.';

  @override
  String get failureNetwork => 'Сеть недоступна.';

  @override
  String get failureUnreachable => 'Сервер недоступен.';

  @override
  String failureCommandFailed(String name, String code) {
    return 'Команда «$name» завершилась с кодом $code.';
  }

  @override
  String get failureScriptInterrupted => 'Выполнение блока команд прервано.';
}
