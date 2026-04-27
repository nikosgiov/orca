import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Docker Controller'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage Docker\nRemotely, Anytime, Anywhere'**
  String get appTagline;

  /// No description provided for @dockerApiUri.
  ///
  /// In en, this message translates to:
  /// **'Docker API IP:PORT'**
  String get dockerApiUri;

  /// No description provided for @dockerApiUriHintIpPort.
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.10:2375'**
  String get dockerApiUriHintIpPort;

  /// No description provided for @authType.
  ///
  /// In en, this message translates to:
  /// **'Auth Type'**
  String get authType;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @saveCredentials.
  ///
  /// In en, this message translates to:
  /// **'Save Credentials'**
  String get saveCredentials;

  /// No description provided for @tlsCerts.
  ///
  /// In en, this message translates to:
  /// **'TLS Certificates'**
  String get tlsCerts;

  /// No description provided for @authNone.
  ///
  /// In en, this message translates to:
  /// **'No Authentication'**
  String get authNone;

  /// No description provided for @authBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic Authentication'**
  String get authBasic;

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

  /// No description provided for @uriRequired.
  ///
  /// In en, this message translates to:
  /// **'Docker API URI is required'**
  String get uriRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required for Basic auth'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required for Basic auth'**
  String get passwordRequired;

  /// No description provided for @containersTitle.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get containersTitle;

  /// No description provided for @searchContainersHint.
  ///
  /// In en, this message translates to:
  /// **'Search containers...'**
  String get searchContainersHint;

  /// No description provided for @noContainersFound.
  ///
  /// In en, this message translates to:
  /// **'No containers found'**
  String get noContainersFound;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get statusRunning;

  /// No description provided for @statusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get statusStopped;

  /// No description provided for @statusExited.
  ///
  /// In en, this message translates to:
  /// **'Exited'**
  String get statusExited;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @labelImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get labelImage;

  /// No description provided for @labelPorts.
  ///
  /// In en, this message translates to:
  /// **'Ports'**
  String get labelPorts;

  /// No description provided for @labelUptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get labelUptime;

  /// No description provided for @noPorts.
  ///
  /// In en, this message translates to:
  /// **'No ports'**
  String get noPorts;

  /// No description provided for @justCreated.
  ///
  /// In en, this message translates to:
  /// **'Just created'**
  String get justCreated;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @actionStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get actionStop;

  /// No description provided for @actionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get actionDetails;

  /// No description provided for @startedContainer.
  ///
  /// In en, this message translates to:
  /// **'Started container'**
  String get startedContainer;

  /// No description provided for @failedToStartContainer.
  ///
  /// In en, this message translates to:
  /// **'Failed to start container'**
  String get failedToStartContainer;

  /// No description provided for @errorStartingContainer.
  ///
  /// In en, this message translates to:
  /// **'Error starting container'**
  String get errorStartingContainer;

  /// No description provided for @stoppedContainer.
  ///
  /// In en, this message translates to:
  /// **'Stopped container'**
  String get stoppedContainer;

  /// No description provided for @failedToStopContainer.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop container'**
  String get failedToStopContainer;

  /// No description provided for @errorStoppingContainer.
  ///
  /// In en, this message translates to:
  /// **'Error stopping container'**
  String get errorStoppingContainer;

  /// No description provided for @imagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get imagesTitle;

  /// No description provided for @searchImagesHint.
  ///
  /// In en, this message translates to:
  /// **'Search images...'**
  String get searchImagesHint;

  /// No description provided for @noImagesFound.
  ///
  /// In en, this message translates to:
  /// **'No images found'**
  String get noImagesFound;

  /// No description provided for @pullFirstImage.
  ///
  /// In en, this message translates to:
  /// **'Pull your first image to get started'**
  String get pullFirstImage;

  /// No description provided for @actionRunContainer.
  ///
  /// In en, this message translates to:
  /// **'Run Container'**
  String get actionRunContainer;

  /// No description provided for @copyRawJson.
  ///
  /// In en, this message translates to:
  /// **'Copy Raw JSON'**
  String get copyRawJson;

  /// No description provided for @copiedRawJson.
  ///
  /// In en, this message translates to:
  /// **'Copied raw JSON to clipboard'**
  String get copiedRawJson;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @labelCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get labelCreated;

  /// No description provided for @labelDigest.
  ///
  /// In en, this message translates to:
  /// **'Digest'**
  String get labelDigest;

  /// No description provided for @labelId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get labelId;

  /// No description provided for @labelRepoTags.
  ///
  /// In en, this message translates to:
  /// **'RepoTags'**
  String get labelRepoTags;

  /// No description provided for @labelRepoDigests.
  ///
  /// In en, this message translates to:
  /// **'RepoDigests'**
  String get labelRepoDigests;

  /// No description provided for @labelLabels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labelLabels;

  /// No description provided for @labelParentId.
  ///
  /// In en, this message translates to:
  /// **'Parent ID'**
  String get labelParentId;

  /// No description provided for @labelComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get labelComment;

  /// No description provided for @labelOs.
  ///
  /// In en, this message translates to:
  /// **'OS'**
  String get labelOs;

  /// No description provided for @labelArchitecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get labelArchitecture;

  /// No description provided for @labelVirtualSize.
  ///
  /// In en, this message translates to:
  /// **'Virtual Size'**
  String get labelVirtualSize;

  /// No description provided for @volumesNetworksTitle.
  ///
  /// In en, this message translates to:
  /// **'Volumes & Networks'**
  String get volumesNetworksTitle;

  /// No description provided for @dockerVolumes.
  ///
  /// In en, this message translates to:
  /// **'Docker Volumes'**
  String get dockerVolumes;

  /// No description provided for @dockerNetworks.
  ///
  /// In en, this message translates to:
  /// **'Docker Networks'**
  String get dockerNetworks;

  /// No description provided for @createVolume.
  ///
  /// In en, this message translates to:
  /// **'Create Volume'**
  String get createVolume;

  /// No description provided for @createNetwork.
  ///
  /// In en, this message translates to:
  /// **'Create Network'**
  String get createNetwork;

  /// No description provided for @labelMountPoint.
  ///
  /// In en, this message translates to:
  /// **'Mount Point'**
  String get labelMountPoint;

  /// No description provided for @labelContainers.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get labelContainers;

  /// No description provided for @labelSubnet.
  ///
  /// In en, this message translates to:
  /// **'Subnet'**
  String get labelSubnet;

  /// No description provided for @labelDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get labelDriver;

  /// No description provided for @labelScope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get labelScope;

  /// No description provided for @actionInspect.
  ///
  /// In en, this message translates to:
  /// **'Inspect'**
  String get actionInspect;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @labelSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get labelSize;

  /// No description provided for @logsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Logs & Notifications'**
  String get logsNotificationsTitle;

  /// No description provided for @logsTab.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsTab;

  /// No description provided for @notificationsTab.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTab;

  /// No description provided for @logLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Log Level'**
  String get logLevelLabel;

  /// No description provided for @containerLabel.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get containerLabel;

  /// No description provided for @logLevelAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get logLevelAll;

  /// No description provided for @logLevelError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get logLevelError;

  /// No description provided for @logLevelWarn.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get logLevelWarn;

  /// No description provided for @logLevelInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get logLevelInfo;

  /// No description provided for @logLevelDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get logLevelDebug;

  /// No description provided for @followLogs.
  ///
  /// In en, this message translates to:
  /// **'Follow Logs'**
  String get followLogs;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get markAllRead;

  /// No description provided for @resourceMonitoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Resource Monitoring'**
  String get resourceMonitoringTitle;

  /// No description provided for @timeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get timeRangeLabel;

  /// No description provided for @containerDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get containerDropdownLabel;

  /// No description provided for @timeRange1Hour.
  ///
  /// In en, this message translates to:
  /// **'1 Hour'**
  String get timeRange1Hour;

  /// No description provided for @timeRange6Hours.
  ///
  /// In en, this message translates to:
  /// **'6 Hours'**
  String get timeRange6Hours;

  /// No description provided for @timeRange24Hours.
  ///
  /// In en, this message translates to:
  /// **'24 Hours'**
  String get timeRange24Hours;

  /// No description provided for @timeRange7Days.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get timeRange7Days;

  /// No description provided for @cpuUsage.
  ///
  /// In en, this message translates to:
  /// **'CPU Usage'**
  String get cpuUsage;

  /// No description provided for @memoryUsage.
  ///
  /// In en, this message translates to:
  /// **'Memory Usage'**
  String get memoryUsage;

  /// No description provided for @networkIO.
  ///
  /// In en, this message translates to:
  /// **'Network I/O'**
  String get networkIO;

  /// No description provided for @diskIO.
  ///
  /// In en, this message translates to:
  /// **'Disk I/O'**
  String get diskIO;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get notConnected;

  /// No description provided for @systemInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get systemInfoTitle;

  /// No description provided for @operatingSystem.
  ///
  /// In en, this message translates to:
  /// **'Operating System'**
  String get operatingSystem;

  /// No description provided for @dockerEngine.
  ///
  /// In en, this message translates to:
  /// **'Docker Engine'**
  String get dockerEngine;

  /// No description provided for @hardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get hardware;

  /// No description provided for @networks.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get networks;

  /// No description provided for @volumes.
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get volumes;

  /// No description provided for @osLabel.
  ///
  /// In en, this message translates to:
  /// **'OS'**
  String get osLabel;

  /// No description provided for @kernel.
  ///
  /// In en, this message translates to:
  /// **'Kernel'**
  String get kernel;

  /// No description provided for @hostname.
  ///
  /// In en, this message translates to:
  /// **'Hostname'**
  String get hostname;

  /// No description provided for @architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get architecture;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @apiVersion.
  ///
  /// In en, this message translates to:
  /// **'API Version'**
  String get apiVersion;

  /// No description provided for @storageDriver.
  ///
  /// In en, this message translates to:
  /// **'Storage Driver'**
  String get storageDriver;

  /// No description provided for @swarmStatus.
  ///
  /// In en, this message translates to:
  /// **'Swarm Status'**
  String get swarmStatus;

  /// No description provided for @plugins.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get plugins;

  /// No description provided for @cpuCores.
  ///
  /// In en, this message translates to:
  /// **'CPU Cores'**
  String get cpuCores;

  /// No description provided for @memory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memory;

  /// No description provided for @gpu.
  ///
  /// In en, this message translates to:
  /// **'GPU'**
  String get gpu;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @useDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get useDarkTheme;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @dataStorage.
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataStorage;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @composeTitle.
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get composeTitle;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection Lost'**
  String get connectionLost;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// No description provided for @systemInformation.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get systemInformation;

  /// No description provided for @os.
  ///
  /// In en, this message translates to:
  /// **'OS'**
  String get os;

  /// No description provided for @dockerVersion.
  ///
  /// In en, this message translates to:
  /// **'Docker Version'**
  String get dockerVersion;

  /// No description provided for @memTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Memory'**
  String get memTotal;

  /// No description provided for @ncpu.
  ///
  /// In en, this message translates to:
  /// **'CPU Cores'**
  String get ncpu;

  /// No description provided for @resourceUsage.
  ///
  /// In en, this message translates to:
  /// **'Resource Usage'**
  String get resourceUsage;

  /// No description provided for @refreshDetailedStats.
  ///
  /// In en, this message translates to:
  /// **'Refresh detailed stats'**
  String get refreshDetailedStats;

  /// No description provided for @gpuUtilization.
  ///
  /// In en, this message translates to:
  /// **'GPU Utilization'**
  String get gpuUtilization;

  /// No description provided for @containersSummary.
  ///
  /// In en, this message translates to:
  /// **'Containers Summary'**
  String get containersSummary;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stopped;

  /// No description provided for @exited.
  ///
  /// In en, this message translates to:
  /// **'Exited'**
  String get exited;

  /// No description provided for @volumesNetworks.
  ///
  /// In en, this message translates to:
  /// **'Volumes & Networks'**
  String get volumesNetworks;

  /// No description provided for @createContainerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Container'**
  String get createContainerTitle;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @basicConfig.
  ///
  /// In en, this message translates to:
  /// **'Basic Config'**
  String get basicConfig;

  /// No description provided for @advancedConfig.
  ///
  /// In en, this message translates to:
  /// **'Advanced Config'**
  String get advancedConfig;

  /// No description provided for @reviewCreate.
  ///
  /// In en, this message translates to:
  /// **'Review & Create'**
  String get reviewCreate;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {X} of {Y}'**
  String stepOf(Object X, Object Y);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @createContainer.
  ///
  /// In en, this message translates to:
  /// **'Create Container'**
  String get createContainer;

  /// No description provided for @failedToLoadImages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load images'**
  String get failedToLoadImages;

  /// No description provided for @notConnectedToDocker.
  ///
  /// In en, this message translates to:
  /// **'Not connected to Docker daemon'**
  String get notConnectedToDocker;

  /// No description provided for @errorLoadingImages.
  ///
  /// In en, this message translates to:
  /// **'Error loading images'**
  String get errorLoadingImages;

  /// No description provided for @customImage.
  ///
  /// In en, this message translates to:
  /// **'Custom Image'**
  String get customImage;

  /// No description provided for @loadingImages.
  ///
  /// In en, this message translates to:
  /// **'Loading images...'**
  String get loadingImages;

  /// No description provided for @imageName.
  ///
  /// In en, this message translates to:
  /// **'Image Name'**
  String get imageName;

  /// No description provided for @infoTab.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTab;

  /// No description provided for @statsTab.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTab;

  /// No description provided for @actionsTab.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsTab;

  /// No description provided for @noContainerInfo.
  ///
  /// In en, this message translates to:
  /// **'No container information available'**
  String get noContainerInfo;

  /// No description provided for @noStatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stats available'**
  String get noStatsAvailable;

  /// No description provided for @noLogsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get noLogsAvailable;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @ports.
  ///
  /// In en, this message translates to:
  /// **'Ports'**
  String get ports;

  /// No description provided for @envVars.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get envVars;

  /// No description provided for @containerId.
  ///
  /// In en, this message translates to:
  /// **'Container ID'**
  String get containerId;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @env.
  ///
  /// In en, this message translates to:
  /// **'ENV'**
  String get env;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// No description provided for @advancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get advancedOptions;

  /// No description provided for @rememberThisConnectionLong.
  ///
  /// In en, this message translates to:
  /// **'Remember This Connection'**
  String get rememberThisConnectionLong;

  /// No description provided for @useTls.
  ///
  /// In en, this message translates to:
  /// **'Use TLS'**
  String get useTls;

  /// No description provided for @enableSecureConnection.
  ///
  /// In en, this message translates to:
  /// **'Enable secure connection'**
  String get enableSecureConnection;

  /// No description provided for @stayLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Stay Logged In'**
  String get stayLoggedIn;

  /// No description provided for @dockerHostUri.
  ///
  /// In en, this message translates to:
  /// **'Docker Host URI'**
  String get dockerHostUri;

  /// No description provided for @authenticationLabel.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authenticationLabel;

  /// No description provided for @advancedOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get advancedOptionsLabel;

  /// No description provided for @rememberConnection.
  ///
  /// In en, this message translates to:
  /// **'Remember connection'**
  String get rememberConnection;

  /// No description provided for @tlsEnabled.
  ///
  /// In en, this message translates to:
  /// **'TLS enabled'**
  String get tlsEnabled;

  /// No description provided for @tlsDisabled.
  ///
  /// In en, this message translates to:
  /// **'TLS disabled'**
  String get tlsDisabled;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @rememberThisConnection.
  ///
  /// In en, this message translates to:
  /// **'Remember This Connection'**
  String get rememberThisConnection;

  /// No description provided for @recentConnections.
  ///
  /// In en, this message translates to:
  /// **'Recent Connections'**
  String get recentConnections;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No recent connections found'**
  String get noHistory;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @loadingResourceData.
  ///
  /// In en, this message translates to:
  /// **'Loading resource data...'**
  String get loadingResourceData;

  /// No description provided for @notConnectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Not connected to Docker. Please connect first.'**
  String get notConnectedMessage;

  /// No description provided for @searchLogsHint.
  ///
  /// In en, this message translates to:
  /// **'Search logs...'**
  String get searchLogsHint;

  /// No description provided for @timeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get timeAllTime;

  /// No description provided for @lines.
  ///
  /// In en, this message translates to:
  /// **'Lines:'**
  String get lines;

  /// No description provided for @noVolumesFound.
  ///
  /// In en, this message translates to:
  /// **'No volumes found'**
  String get noVolumesFound;

  /// No description provided for @noNetworksFound.
  ///
  /// In en, this message translates to:
  /// **'No networks found'**
  String get noNetworksFound;

  /// No description provided for @removeVolumeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove volume \"{name}\"?'**
  String removeVolumeConfirm(String name);

  /// No description provided for @removeNetworkConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove network \"{name}\"?'**
  String removeNetworkConfirm(String name);

  /// No description provided for @removedVolume.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}'**
  String removedVolume(String name);

  /// No description provided for @failedToRemoveVolume.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove {name}'**
  String failedToRemoveVolume(String name);

  /// No description provided for @removedNetwork.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}'**
  String removedNetwork(String name);

  /// No description provided for @failedToRemoveNetwork.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove {name}'**
  String failedToRemoveNetwork(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @networksTitle.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get networksTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @failedToFetchNetworkDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch network details'**
  String get failedToFetchNetworkDetails;

  /// No description provided for @removeImageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name}?'**
  String removeImageConfirm(String name);

  /// No description provided for @removedImageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully removed {name}'**
  String removedImageSuccess(String name);

  /// No description provided for @failedToRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove image'**
  String get failedToRemoveImage;

  /// No description provided for @containerCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Container created successfully! ID: {id}'**
  String containerCreatedSuccessfully(String id);

  /// No description provided for @containerStartedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Container created and started successfully! ID: {id}'**
  String containerStartedSuccessfully(String id);

  /// No description provided for @imageNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Image name is required.'**
  String get imageNameRequired;

  /// No description provided for @imageNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Image name can only contain letters, numbers, dots, dashes, underscores, and slashes.'**
  String get imageNameInvalid;

  /// No description provided for @tagRequired.
  ///
  /// In en, this message translates to:
  /// **'Tag is required.'**
  String get tagRequired;

  /// No description provided for @tagInvalid.
  ///
  /// In en, this message translates to:
  /// **'Tag can only contain letters, numbers, dots, dashes, and underscores.'**
  String get tagInvalid;

  /// No description provided for @portRequired.
  ///
  /// In en, this message translates to:
  /// **'Port is required.'**
  String get portRequired;

  /// No description provided for @portInvalid.
  ///
  /// In en, this message translates to:
  /// **'Port must be a number between 1 and 65535.'**
  String get portInvalid;

  /// No description provided for @containerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Container Name'**
  String get containerNameLabel;

  /// No description provided for @containerNameHint.
  ///
  /// In en, this message translates to:
  /// **'my-container'**
  String get containerNameHint;

  /// No description provided for @interactive.
  ///
  /// In en, this message translates to:
  /// **'Interactive'**
  String get interactive;

  /// No description provided for @keepStdinOpen.
  ///
  /// In en, this message translates to:
  /// **'Keep STDIN open'**
  String get keepStdinOpen;

  /// No description provided for @tty.
  ///
  /// In en, this message translates to:
  /// **'TTY'**
  String get tty;

  /// No description provided for @allocatePseudoTty.
  ///
  /// In en, this message translates to:
  /// **'Allocate pseudo-TTY'**
  String get allocatePseudoTty;

  /// No description provided for @autoRemoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto Remove'**
  String get autoRemoveLabel;

  /// No description provided for @removeOnExit.
  ///
  /// In en, this message translates to:
  /// **'Remove container when it exits'**
  String get removeOnExit;

  /// No description provided for @startAfterCreateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start After Create'**
  String get startAfterCreateLabel;

  /// No description provided for @startAfterCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically start the container after creation'**
  String get startAfterCreateSubtitle;

  /// No description provided for @portMappings.
  ///
  /// In en, this message translates to:
  /// **'Port Mappings'**
  String get portMappings;

  /// No description provided for @hostPort.
  ///
  /// In en, this message translates to:
  /// **'Host Port'**
  String get hostPort;

  /// No description provided for @containerPort.
  ///
  /// In en, this message translates to:
  /// **'Container Port'**
  String get containerPort;

  /// No description provided for @volumeMappings.
  ///
  /// In en, this message translates to:
  /// **'Volume Mappings'**
  String get volumeMappings;

  /// No description provided for @hostPath.
  ///
  /// In en, this message translates to:
  /// **'Host Path'**
  String get hostPath;

  /// No description provided for @containerPath.
  ///
  /// In en, this message translates to:
  /// **'Container Path'**
  String get containerPath;

  /// No description provided for @envVarsLabel.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get envVarsLabel;

  /// No description provided for @variableName.
  ///
  /// In en, this message translates to:
  /// **'Variable Name'**
  String get variableName;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @networkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Network Mode'**
  String get networkModeLabel;

  /// No description provided for @networkBridge.
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get networkBridge;

  /// No description provided for @networkHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get networkHost;

  /// No description provided for @networkNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get networkNone;

  /// No description provided for @imageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkLabel;

  /// No description provided for @portsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ports'**
  String get portsLabel;

  /// No description provided for @volumesLabel.
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get volumesLabel;

  /// No description provided for @environmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environmentLabel;

  /// No description provided for @optionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsLabel;

  /// No description provided for @createVolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Volume'**
  String get createVolumeTitle;

  /// No description provided for @volumeCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Volume {name} created successfully!'**
  String volumeCreatedSuccessfully(String name);

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @createNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Network'**
  String get createNetworkTitle;

  /// No description provided for @networkCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Network {name} created successfully!'**
  String networkCreatedSuccessfully(String name);

  /// No description provided for @ipamConfig.
  ///
  /// In en, this message translates to:
  /// **'IPAM Config'**
  String get ipamConfig;

  /// No description provided for @noProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No Compose Projects Found'**
  String get noProjectsFound;

  /// No description provided for @composeLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Ensure labels com.docker.compose.project exist on containers.'**
  String get composeLabelHint;

  /// No description provided for @navDash.
  ///
  /// In en, this message translates to:
  /// **'Dash'**
  String get navDash;

  /// No description provided for @navContainers.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get navContainers;

  /// No description provided for @navImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get navImages;

  /// No description provided for @navMonitor.
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get navMonitor;

  /// No description provided for @navCompose.
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get navCompose;

  /// No description provided for @navConfig.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get navConfig;

  /// No description provided for @autoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Auto Refresh'**
  String get autoRefresh;

  /// No description provided for @autoRefreshSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically refresh data'**
  String get autoRefreshSubtitle;

  /// No description provided for @refreshInterval.
  ///
  /// In en, this message translates to:
  /// **'Refresh Interval'**
  String get refreshInterval;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String seconds(int count);

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect and clear saved data'**
  String get logoutSubtitle;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @showPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Show push notifications'**
  String get showPushNotifications;

  /// No description provided for @containerEvents.
  ///
  /// In en, this message translates to:
  /// **'Container Events'**
  String get containerEvents;

  /// No description provided for @notifyContainerChanges.
  ///
  /// In en, this message translates to:
  /// **'Notify on container state changes'**
  String get notifyContainerChanges;

  /// No description provided for @resourceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Resource Alerts'**
  String get resourceAlerts;

  /// No description provided for @notifyHighUsage.
  ///
  /// In en, this message translates to:
  /// **'Notify on high resource usage'**
  String get notifyHighUsage;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @configPushThresholds.
  ///
  /// In en, this message translates to:
  /// **'Configure push notifications and thresholds'**
  String get configPushThresholds;

  /// No description provided for @viewDetailedInfo.
  ///
  /// In en, this message translates to:
  /// **'View detailed system info'**
  String get viewDetailedInfo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout? This will disconnect from the Docker host and clear all saved connection data.'**
  String get logoutConfirm;

  /// No description provided for @loggedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccessfully;

  /// No description provided for @release.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get release;

  /// No description provided for @cpuThreads.
  ///
  /// In en, this message translates to:
  /// **'CPU Threads'**
  String get cpuThreads;

  /// No description provided for @cpuModel.
  ///
  /// In en, this message translates to:
  /// **'CPU Model'**
  String get cpuModel;

  /// No description provided for @disk.
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get disk;

  /// No description provided for @authNoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect without authentication'**
  String get authNoneDesc;

  /// No description provided for @authBasicDesc.
  ///
  /// In en, this message translates to:
  /// **'Use username and password'**
  String get authBasicDesc;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted Lifecycle Control'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Start, Stop, and Recreate containers instantly. Pull, delete, and inspect image repositories natively dashboards setup streamline.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Docker Compose Orchestration'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Execute entire multi-container clusters together using Docker Compose configurations setups transparently streamline layouts.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Native Analytics & Node Metrics'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Stream real-time datasets detailing continuous CPU datasets limit allocations, Memory leaks analytics and I/O rates.'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Interactive Exec TTY Terminals'**
  String get onboardingTitle4;

  /// No description provided for @onboardingSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Spawn live interactive secure shell sessions directly inside container workspaces dashboards streamline frames transparent setup correctly.'**
  String get onboardingSubtitle4;

  /// No description provided for @onboardingTitle5.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Run Backend'**
  String get onboardingTitle5;

  /// No description provided for @onboardingSubtitle5.
  ///
  /// In en, this message translates to:
  /// **'To talk to Docker daemon, run our secure container server configuration.'**
  String get onboardingSubtitle5;

  /// No description provided for @onboardingDesc5.
  ///
  /// In en, this message translates to:
  /// **'1. git clone github.com/nikosgiov/orca\n2. Follow the README instructions to configure Firebase and start the orca-server.\n3. Ensure your exposed port is accessible.'**
  String get onboardingDesc5;

  /// No description provided for @onboardingTitle6.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Connect!'**
  String get onboardingTitle6;

  /// No description provided for @onboardingSubtitle6.
  ///
  /// In en, this message translates to:
  /// **'Connect your mobile app securely to your server in seconds.'**
  String get onboardingSubtitle6;

  /// No description provided for @onboardingDesc6.
  ///
  /// In en, this message translates to:
  /// **'Enter your Server IP:PORT in the connection screen. Supports Basic auth or TLS securely environments transparent.'**
  String get onboardingDesc6;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @startSetup.
  ///
  /// In en, this message translates to:
  /// **'Start setup'**
  String get startSetup;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @gpuUsage.
  ///
  /// In en, this message translates to:
  /// **'GPU Usage'**
  String get gpuUsage;

  /// No description provided for @timeframe.
  ///
  /// In en, this message translates to:
  /// **'Timeframe'**
  String get timeframe;

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Minutes'**
  String minutesCount(int count);

  /// No description provided for @hoursCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Hours'**
  String hoursCount(int count);

  /// No description provided for @terminalTitle.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminalTitle;

  /// No description provided for @connectingTo.
  ///
  /// In en, this message translates to:
  /// **'Connecting to {name}...'**
  String connectingTo(String name);

  /// No description provided for @processTerminated.
  ///
  /// In en, this message translates to:
  /// **'[Process Terminated]'**
  String get processTerminated;

  /// No description provided for @streamError.
  ///
  /// In en, this message translates to:
  /// **'[Stream Error] {error}'**
  String streamError(String error);

  /// No description provided for @connectionClosed.
  ///
  /// In en, this message translates to:
  /// **'[Connection Closed]'**
  String get connectionClosed;

  /// No description provided for @webSocketError.
  ///
  /// In en, this message translates to:
  /// **'[WebSocket Error] {error}'**
  String webSocketError(String error);

  /// No description provided for @connectedVia.
  ///
  /// In en, this message translates to:
  /// **'[Connected via {shell}]'**
  String connectedVia(String shell);

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'[Connection Failed] {error}'**
  String connectionFailed(String error);

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'COPY'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'PASTE'**
  String get paste;

  /// No description provided for @systemNode.
  ///
  /// In en, this message translates to:
  /// **'System Node'**
  String get systemNode;

  /// No description provided for @liveTelemetry.
  ///
  /// In en, this message translates to:
  /// **'Live Telemetry'**
  String get liveTelemetry;

  /// No description provided for @updatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'UPDATED: JUST NOW'**
  String get updatedJustNow;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @allNotificationsMarkedRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedRead;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @loadingContainers.
  ///
  /// In en, this message translates to:
  /// **'Loading containers...'**
  String get loadingContainers;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @startContainer.
  ///
  /// In en, this message translates to:
  /// **'Start Container'**
  String get startContainer;

  /// No description provided for @stopContainer.
  ///
  /// In en, this message translates to:
  /// **'Stop Container'**
  String get stopContainer;

  /// No description provided for @pauseContainer.
  ///
  /// In en, this message translates to:
  /// **'Pause Container'**
  String get pauseContainer;

  /// No description provided for @resumeContainer.
  ///
  /// In en, this message translates to:
  /// **'Resume Container'**
  String get resumeContainer;

  /// No description provided for @restartContainer.
  ///
  /// In en, this message translates to:
  /// **'Restart Container'**
  String get restartContainer;

  /// No description provided for @openTerminal.
  ///
  /// In en, this message translates to:
  /// **'Open Terminal'**
  String get openTerminal;

  /// No description provided for @killContainer.
  ///
  /// In en, this message translates to:
  /// **'Kill Container'**
  String get killContainer;

  /// No description provided for @renameContainer.
  ///
  /// In en, this message translates to:
  /// **'Rename Container'**
  String get renameContainer;

  /// No description provided for @removeContainer.
  ///
  /// In en, this message translates to:
  /// **'Remove Container'**
  String get removeContainer;

  /// No description provided for @killConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Kill Container'**
  String get killConfirmTitle;

  /// No description provided for @killConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to kill \"{name}\"?'**
  String killConfirmMessage(Object name);

  /// No description provided for @killedContainer.
  ///
  /// In en, this message translates to:
  /// **'Killed {name}'**
  String killedContainer(Object name);

  /// No description provided for @renameConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Container'**
  String get renameConfirmTitle;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter new name:'**
  String get enterNewName;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New Name'**
  String get newName;

  /// No description provided for @renamedTo.
  ///
  /// In en, this message translates to:
  /// **'Renamed to {name}'**
  String renamedTo(Object name);

  /// No description provided for @failedToRename.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename'**
  String get failedToRename;

  /// No description provided for @removeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Container'**
  String get removeConfirmTitle;

  /// No description provided for @removeConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"? This cannot be undone.'**
  String removeConfirmMessage(Object name);

  /// No description provided for @removedContainer.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}'**
  String removedContainer(Object name);

  /// No description provided for @failedToRemove.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove'**
  String get failedToRemove;

  /// No description provided for @actionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully {action}ed container'**
  String actionSuccess(Object action);

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to {action}'**
  String actionFailed(Object action);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statusLabel;

  /// No description provided for @tagLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tagLabel;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully registered for notifications'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to register for notifications: {error}'**
  String registerFailed(Object error);

  /// No description provided for @unregisterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully unregistered from notifications'**
  String get unregisterSuccess;

  /// No description provided for @unregisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unregister from notifications: {error}'**
  String unregisterFailed(Object error);

  /// No description provided for @thresholdsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Thresholds updated successfully'**
  String get thresholdsUpdated;

  /// No description provided for @enterPercent.
  ///
  /// In en, this message translates to:
  /// **'Enter 0–100'**
  String get enterPercent;

  /// No description provided for @noActiveConnection.
  ///
  /// In en, this message translates to:
  /// **'No active connection'**
  String get noActiveConnection;

  /// No description provided for @failedToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notification settings: {error}'**
  String failedToLoadSettings(Object error);

  /// No description provided for @failedToUpdateServer.
  ///
  /// In en, this message translates to:
  /// **'Failed to update server: {error}'**
  String failedToUpdateServer(Object error);

  /// No description provided for @pullImage.
  ///
  /// In en, this message translates to:
  /// **'Pull Image'**
  String get pullImage;

  /// No description provided for @pull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get pull;

  /// No description provided for @pullingImage.
  ///
  /// In en, this message translates to:
  /// **'Pulling {name}:{tag}... This may take a while.'**
  String pullingImage(Object name, Object tag);

  /// No description provided for @pullSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully pulled {name}'**
  String pullSuccess(Object name);

  /// No description provided for @pullFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pull image'**
  String get pullFailed;

  /// No description provided for @loadingImagesProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading images...'**
  String get loadingImagesProgress;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @preparingContainerCreation.
  ///
  /// In en, this message translates to:
  /// **'Preparing container creation...'**
  String get preparingContainerCreation;

  /// No description provided for @failedToCreateContainer.
  ///
  /// In en, this message translates to:
  /// **'Failed to create container: {error}'**
  String failedToCreateContainer(Object error);

  /// No description provided for @driverOptionValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Driver option value is required'**
  String get driverOptionValueRequired;

  /// No description provided for @driverOptionKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Driver option key is required'**
  String get driverOptionKeyRequired;

  /// No description provided for @labelValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Label value is required'**
  String get labelValueRequired;

  /// No description provided for @labelKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Label key is required'**
  String get labelKeyRequired;

  /// No description provided for @notConnectedDocker.
  ///
  /// In en, this message translates to:
  /// **'Not connected to Docker. Please connect first.'**
  String get notConnectedDocker;

  /// No description provided for @failedToCreateVolume.
  ///
  /// In en, this message translates to:
  /// **'Failed to create volume'**
  String get failedToCreateVolume;

  /// No description provided for @errorCreatingVolume.
  ///
  /// In en, this message translates to:
  /// **'Error creating volume: {error}'**
  String errorCreatingVolume(Object error);

  /// No description provided for @driverLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get driverLocal;

  /// No description provided for @driverNfs.
  ///
  /// In en, this message translates to:
  /// **'NFS'**
  String get driverNfs;

  /// No description provided for @driverCifs.
  ///
  /// In en, this message translates to:
  /// **'CIFS'**
  String get driverCifs;

  /// No description provided for @driverTmpfs.
  ///
  /// In en, this message translates to:
  /// **'Tmpfs'**
  String get driverTmpfs;

  /// No description provided for @networkOverlay.
  ///
  /// In en, this message translates to:
  /// **'Overlay'**
  String get networkOverlay;

  /// No description provided for @networkMacvlan.
  ///
  /// In en, this message translates to:
  /// **'Macvlan'**
  String get networkMacvlan;

  /// No description provided for @networkIpvlan.
  ///
  /// In en, this message translates to:
  /// **'IPvlan'**
  String get networkIpvlan;

  /// No description provided for @volumeName.
  ///
  /// In en, this message translates to:
  /// **'Volume Name'**
  String get volumeName;

  /// No description provided for @networkName.
  ///
  /// In en, this message translates to:
  /// **'Network Name'**
  String get networkName;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark Read'**
  String get markRead;

  /// No description provided for @markUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark Unread'**
  String get markUnread;

  /// No description provided for @labelKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Label key can only contain letters, numbers, dots, dashes, and underscores'**
  String get labelKeyInvalid;

  /// No description provided for @labelValueNoTabs.
  ///
  /// In en, this message translates to:
  /// **'Label value cannot contain newlines or tabs'**
  String get labelValueNoTabs;

  /// No description provided for @labelValueTooLong.
  ///
  /// In en, this message translates to:
  /// **'Label value cannot exceed 255 characters'**
  String get labelValueTooLong;

  /// No description provided for @driverOptionKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Driver option key can only contain letters, numbers, dots, dashes, and underscores'**
  String get driverOptionKeyInvalid;

  /// No description provided for @driverOptionValueNoTabs.
  ///
  /// In en, this message translates to:
  /// **'Driver option value cannot contain newlines or tabs'**
  String get driverOptionValueNoTabs;

  /// No description provided for @driverOptionValueTooLong.
  ///
  /// In en, this message translates to:
  /// **'Driver option value cannot exceed 255 characters'**
  String get driverOptionValueTooLong;

  /// No description provided for @driverOptions.
  ///
  /// In en, this message translates to:
  /// **'Driver Options'**
  String get driverOptions;

  /// No description provided for @noOptionsAdded.
  ///
  /// In en, this message translates to:
  /// **'No options added'**
  String get noOptionsAdded;

  /// No description provided for @keyLabel.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get keyLabel;

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueLabel;

  /// No description provided for @noLabelsAdded.
  ///
  /// In en, this message translates to:
  /// **'No labels added'**
  String get noLabelsAdded;

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get addOption;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add label'**
  String get addLabel;

  /// No description provided for @volumeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Volume name is required'**
  String get volumeNameRequired;

  /// No description provided for @volumeNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Volume name can only contain letters, numbers, dots, dashes, underscores, and slashes'**
  String get volumeNameInvalid;

  /// No description provided for @networkNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Network name is required'**
  String get networkNameRequired;

  /// No description provided for @networkNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Network name can only contain letters, numbers, dots, dashes, underscores, and slashes'**
  String get networkNameInvalid;

  /// No description provided for @volumesTitle.
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get volumesTitle;

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverLabel;

  /// No description provided for @labels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labels;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @saveHostCredentials.
  ///
  /// In en, this message translates to:
  /// **'Save Host Credentials'**
  String get saveHostCredentials;

  /// No description provided for @dontRemember.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Remember'**
  String get dontRemember;

  /// No description provided for @invalidIpPort.
  ///
  /// In en, this message translates to:
  /// **'Invalid IP:PORT format'**
  String get invalidIpPort;

  /// No description provided for @errorLoadingContainerData.
  ///
  /// In en, this message translates to:
  /// **'Error loading container data'**
  String get errorLoadingContainerData;

  /// No description provided for @createFirstContainer.
  ///
  /// In en, this message translates to:
  /// **'Create your first container'**
  String get createFirstContainer;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @connectionLostDesc.
  ///
  /// In en, this message translates to:
  /// **'We lost connection to the Docker daemon. Please check your network or server status.'**
  String get connectionLostDesc;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please check your network and host URI.'**
  String get errorTimeout;

  /// No description provided for @errorConnection.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Ensure the host is reachable.'**
  String get errorConnection;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized: Please check your credentials.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Access Forbidden: You do not have permission to access this resource.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found (404).'**
  String get errorNotFound;

  /// No description provided for @errorInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal Server Error (500). Please check your Docker daemon logs.'**
  String get errorInternal;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown network error'**
  String get errorUnknown;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
