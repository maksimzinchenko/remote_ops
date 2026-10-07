import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote Ops'**
  String get appTitle;

  /// No description provided for @serversTitle.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get serversTitle;

  /// No description provided for @addServer.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addServer;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @newServer.
  ///
  /// In en, this message translates to:
  /// **'New server'**
  String get newServer;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @invalidPort.
  ///
  /// In en, this message translates to:
  /// **'Port must be 1–65535'**
  String get invalidPort;

  /// No description provided for @emptyServers.
  ///
  /// In en, this message translates to:
  /// **'No server profiles yet.\nAdd the first one to connect over SSH.'**
  String get emptyServers;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get deleteProfileTitle;

  /// No description provided for @deleteProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? The password will be removed from secure storage.'**
  String deleteProfileBody(String name);

  /// No description provided for @serverFallback.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverFallback;

  /// No description provided for @profileMissing.
  ///
  /// In en, this message translates to:
  /// **'Profile not found.'**
  String get profileMissing;

  /// No description provided for @runHint.
  ///
  /// In en, this message translates to:
  /// **'The block runs on this server. The connection opens for the run and closes when it finishes.'**
  String get runHint;

  /// No description provided for @connectionSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Connection succeeded. The profile is not saved yet.'**
  String get connectionSucceeded;

  /// No description provided for @unknownHostKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'New server key'**
  String get unknownHostKeyTitle;

  /// No description provided for @unknownHostKeyBody.
  ///
  /// In en, this message translates to:
  /// **'There is no saved fingerprint for {endpoint}. The connection continues only if you trust this key.'**
  String unknownHostKeyBody(String endpoint);

  /// No description provided for @changedHostKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Server key changed'**
  String get changedHostKeyTitle;

  /// No description provided for @changedHostKeyBody.
  ///
  /// In en, this message translates to:
  /// **'The fingerprint of {endpoint} does not match the saved one. The connection will not continue silently: this may be a server impersonation.'**
  String changedHostKeyBody(String endpoint);

  /// No description provided for @trust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get trust;

  /// No description provided for @trustNewKey.
  ///
  /// In en, this message translates to:
  /// **'Trust the new key'**
  String get trustNewKey;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @keyType.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String keyType(String type);

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @storedFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Saved fingerprint'**
  String get storedFingerprint;

  /// No description provided for @presentedFingerprint.
  ///
  /// In en, this message translates to:
  /// **'New fingerprint'**
  String get presentedFingerprint;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Connecting and running...'**
  String get statusRunning;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusWaiting;

  /// No description provided for @stdout.
  ///
  /// In en, this message translates to:
  /// **'stdout'**
  String get stdout;

  /// No description provided for @stderr.
  ///
  /// In en, this message translates to:
  /// **'stderr'**
  String get stderr;

  /// No description provided for @exitCode.
  ///
  /// In en, this message translates to:
  /// **'Exit code: {code}'**
  String exitCode(String code);

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {seconds} s'**
  String duration(String seconds);

  /// No description provided for @scriptCheckStatusName.
  ///
  /// In en, this message translates to:
  /// **'Status check'**
  String get scriptCheckStatusName;

  /// No description provided for @scriptCheckStatusDescription.
  ///
  /// In en, this message translates to:
  /// **'Uptime, memory and disk. The file is read-only and is not edited in the app.'**
  String get scriptCheckStatusDescription;

  /// No description provided for @scriptIdentityName.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get scriptIdentityName;

  /// No description provided for @scriptIdentityDescription.
  ///
  /// In en, this message translates to:
  /// **'User, host and system.'**
  String get scriptIdentityDescription;

  /// No description provided for @scriptProcessesName.
  ///
  /// In en, this message translates to:
  /// **'Processes'**
  String get scriptProcessesName;

  /// No description provided for @scriptProcessesDescription.
  ///
  /// In en, this message translates to:
  /// **'Top processes by CPU.'**
  String get scriptProcessesDescription;

  /// No description provided for @stepUptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get stepUptime;

  /// No description provided for @stepMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get stepMemory;

  /// No description provided for @stepDisk.
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get stepDisk;

  /// No description provided for @stepWho.
  ///
  /// In en, this message translates to:
  /// **'User and host'**
  String get stepWho;

  /// No description provided for @stepPs.
  ///
  /// In en, this message translates to:
  /// **'Process list'**
  String get stepPs;

  /// No description provided for @scriptInstallDockerName.
  ///
  /// In en, this message translates to:
  /// **'Install Docker'**
  String get scriptInstallDockerName;

  /// No description provided for @scriptInstallDockerDescription.
  ///
  /// In en, this message translates to:
  /// **'Installs Docker Engine on Linux when it is missing. An existing Docker is left as is.'**
  String get scriptInstallDockerDescription;

  /// No description provided for @stepInstallDocker.
  ///
  /// In en, this message translates to:
  /// **'Docker Engine'**
  String get stepInstallDocker;

  /// No description provided for @dockerStatusInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed successfully'**
  String get dockerStatusInstalled;

  /// No description provided for @dockerStatusAlready.
  ///
  /// In en, this message translates to:
  /// **'Already on the server'**
  String get dockerStatusAlready;

  /// No description provided for @dockerStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Installation failed. Details are in the output below.'**
  String get dockerStatusFailed;

  /// No description provided for @dockerStatusNeedRoot.
  ///
  /// In en, this message translates to:
  /// **'Installation failed: root or passwordless sudo is required.'**
  String get dockerStatusNeedRoot;

  /// No description provided for @dockerStatusUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Installation failed: this Linux distribution is not supported.'**
  String get dockerStatusUnsupported;

  /// No description provided for @dockerStatusNoDaemon.
  ///
  /// In en, this message translates to:
  /// **'Installation failed: packages are present, but the Docker daemon is not responding.'**
  String get dockerStatusNoDaemon;

  /// No description provided for @dockerStatusNetwork.
  ///
  /// In en, this message translates to:
  /// **'Installation failed: the installer could not be downloaded.'**
  String get dockerStatusNetwork;

  /// No description provided for @scriptUninstallDockerName.
  ///
  /// In en, this message translates to:
  /// **'Remove Docker'**
  String get scriptUninstallDockerName;

  /// No description provided for @scriptUninstallDockerDescription.
  ///
  /// In en, this message translates to:
  /// **'Stops Docker, deletes images, volumes and installer files, then removes the packages.'**
  String get scriptUninstallDockerDescription;

  /// No description provided for @stepUninstallDocker.
  ///
  /// In en, this message translates to:
  /// **'Remove Docker Engine'**
  String get stepUninstallDocker;

  /// No description provided for @dockerStatusRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed. Images, volumes and temporary files were deleted.'**
  String get dockerStatusRemoved;

  /// No description provided for @dockerStatusNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Docker is not on the server.'**
  String get dockerStatusNotInstalled;

  /// No description provided for @dockerStatusRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Removal failed. Details are in the output below.'**
  String get dockerStatusRemoveFailed;

  /// No description provided for @dockerStatusRemoveNeedRoot.
  ///
  /// In en, this message translates to:
  /// **'Removal failed: root or passwordless sudo is required.'**
  String get dockerStatusRemoveNeedRoot;

  /// No description provided for @dockerStatusRemoveUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Removal failed: this Linux distribution is not supported.'**
  String get dockerStatusRemoveUnsupported;

  /// No description provided for @failureProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Server profile not found.'**
  String get failureProfileNotFound;

  /// No description provided for @failurePasswordAuthOnly.
  ///
  /// In en, this message translates to:
  /// **'This version supports password authentication only.'**
  String get failurePasswordAuthOnly;

  /// No description provided for @failurePasswordMissing.
  ///
  /// In en, this message translates to:
  /// **'The profile password was not found in secure storage.'**
  String get failurePasswordMissing;

  /// No description provided for @failureConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get failureConnectionFailed;

  /// No description provided for @failureScriptNotFound.
  ///
  /// In en, this message translates to:
  /// **'Command block not found.'**
  String get failureScriptNotFound;

  /// No description provided for @failureHostKeyRejected.
  ///
  /// In en, this message translates to:
  /// **'Connection stopped: the server key was not confirmed.'**
  String get failureHostKeyRejected;

  /// No description provided for @failureSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the server profile.'**
  String get failureSaveFailed;

  /// No description provided for @failureRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Name, host and username are required.'**
  String get failureRequiredFields;

  /// No description provided for @failureInvalidPort.
  ///
  /// In en, this message translates to:
  /// **'Port must be in the range 1–65535.'**
  String get failureInvalidPort;

  /// No description provided for @failurePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get failurePasswordRequired;

  /// No description provided for @failureNotConnected.
  ///
  /// In en, this message translates to:
  /// **'There is no active SSH connection.'**
  String get failureNotConnected;

  /// No description provided for @failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server did not respond in time.'**
  String get failureTimeout;

  /// No description provided for @failureAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: check the username and password.'**
  String get failureAuthFailed;

  /// No description provided for @failureHostKeyDenied.
  ///
  /// In en, this message translates to:
  /// **'Server key rejected.'**
  String get failureHostKeyDenied;

  /// No description provided for @failureHandshake.
  ///
  /// In en, this message translates to:
  /// **'SSH handshake failed.'**
  String get failureHandshake;

  /// No description provided for @failureDisconnected.
  ///
  /// In en, this message translates to:
  /// **'The server closed the connection.'**
  String get failureDisconnected;

  /// No description provided for @failureSshError.
  ///
  /// In en, this message translates to:
  /// **'SSH connection error.'**
  String get failureSshError;

  /// No description provided for @failureOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the operation on the server.'**
  String get failureOperationFailed;

  /// No description provided for @failureDns.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve the server name.'**
  String get failureDns;

  /// No description provided for @failureRefused.
  ///
  /// In en, this message translates to:
  /// **'The server refused the connection.'**
  String get failureRefused;

  /// No description provided for @failureNetwork.
  ///
  /// In en, this message translates to:
  /// **'The network is unreachable.'**
  String get failureNetwork;

  /// No description provided for @failureUnreachable.
  ///
  /// In en, this message translates to:
  /// **'The server is unreachable.'**
  String get failureUnreachable;

  /// No description provided for @failureCommandFailed.
  ///
  /// In en, this message translates to:
  /// **'Command \"{name}\" finished with code {code}.'**
  String failureCommandFailed(String name, String code);

  /// No description provided for @failureScriptInterrupted.
  ///
  /// In en, this message translates to:
  /// **'The command block was interrupted.'**
  String get failureScriptInterrupted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
