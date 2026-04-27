// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Docker Controller';

  @override
  String get appTagline => 'Manage Docker\nRemotely, Anytime, Anywhere';

  @override
  String get dockerApiUri => 'Docker API IP:PORT';

  @override
  String get dockerApiUriHintIpPort => 'e.g. 192.168.1.10:2375';

  @override
  String get authType => 'Auth Type';

  @override
  String get connect => 'Connect';

  @override
  String get connecting => 'Connecting...';

  @override
  String get advanced => 'Advanced';

  @override
  String get saveCredentials => 'Save Credentials';

  @override
  String get tlsCerts => 'TLS Certificates';

  @override
  String get authNone => 'No Authentication';

  @override
  String get authBasic => 'Basic Authentication';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get uriRequired => 'Docker API URI is required';

  @override
  String get usernameRequired => 'Username is required for Basic auth';

  @override
  String get passwordRequired => 'Password is required for Basic auth';

  @override
  String get containersTitle => 'Containers';

  @override
  String get searchContainersHint => 'Search containers...';

  @override
  String get noContainersFound => 'No containers found';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusStopped => 'Stopped';

  @override
  String get statusExited => 'Exited';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get labelImage => 'Image';

  @override
  String get labelPorts => 'Ports';

  @override
  String get labelUptime => 'Uptime';

  @override
  String get noPorts => 'No ports';

  @override
  String get justCreated => 'Just created';

  @override
  String get actionStart => 'Start';

  @override
  String get actionStop => 'Stop';

  @override
  String get actionDetails => 'Details';

  @override
  String get startedContainer => 'Started container';

  @override
  String get failedToStartContainer => 'Failed to start container';

  @override
  String get errorStartingContainer => 'Error starting container';

  @override
  String get stoppedContainer => 'Stopped container';

  @override
  String get failedToStopContainer => 'Failed to stop container';

  @override
  String get errorStoppingContainer => 'Error stopping container';

  @override
  String get imagesTitle => 'Images';

  @override
  String get searchImagesHint => 'Search images...';

  @override
  String get noImagesFound => 'No images found';

  @override
  String get pullFirstImage => 'Pull your first image to get started';

  @override
  String get actionRunContainer => 'Run Container';

  @override
  String get copyRawJson => 'Copy Raw JSON';

  @override
  String get copiedRawJson => 'Copied raw JSON to clipboard';

  @override
  String get close => 'Close';

  @override
  String get labelCreated => 'Created';

  @override
  String get labelDigest => 'Digest';

  @override
  String get labelId => 'ID';

  @override
  String get labelRepoTags => 'RepoTags';

  @override
  String get labelRepoDigests => 'RepoDigests';

  @override
  String get labelLabels => 'Labels';

  @override
  String get labelParentId => 'Parent ID';

  @override
  String get labelComment => 'Comment';

  @override
  String get labelOs => 'OS';

  @override
  String get labelArchitecture => 'Architecture';

  @override
  String get labelVirtualSize => 'Virtual Size';

  @override
  String get volumesNetworksTitle => 'Volumes & Networks';

  @override
  String get dockerVolumes => 'Docker Volumes';

  @override
  String get dockerNetworks => 'Docker Networks';

  @override
  String get createVolume => 'Create Volume';

  @override
  String get createNetwork => 'Create Network';

  @override
  String get labelMountPoint => 'Mount Point';

  @override
  String get labelContainers => 'Containers';

  @override
  String get labelSubnet => 'Subnet';

  @override
  String get labelDriver => 'Driver';

  @override
  String get labelScope => 'Scope';

  @override
  String get actionInspect => 'Inspect';

  @override
  String get actionRemove => 'Remove';

  @override
  String get labelSize => 'Size';

  @override
  String get logsNotificationsTitle => 'Logs & Notifications';

  @override
  String get logsTab => 'Logs';

  @override
  String get notificationsTab => 'Notifications';

  @override
  String get logLevelLabel => 'Log Level';

  @override
  String get containerLabel => 'Container';

  @override
  String get logLevelAll => 'All';

  @override
  String get logLevelError => 'Error';

  @override
  String get logLevelWarn => 'Warning';

  @override
  String get logLevelInfo => 'Info';

  @override
  String get logLevelDebug => 'Debug';

  @override
  String get followLogs => 'Follow Logs';

  @override
  String get clear => 'Clear';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get resourceMonitoringTitle => 'Resource Monitoring';

  @override
  String get timeRangeLabel => 'Time Range';

  @override
  String get containerDropdownLabel => 'Container';

  @override
  String get timeRange1Hour => '1 Hour';

  @override
  String get timeRange6Hours => '6 Hours';

  @override
  String get timeRange24Hours => '24 Hours';

  @override
  String get timeRange7Days => '7 Days';

  @override
  String get cpuUsage => 'CPU Usage';

  @override
  String get memoryUsage => 'Memory Usage';

  @override
  String get networkIO => 'Network I/O';

  @override
  String get diskIO => 'Disk I/O';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get notConnected => 'Not Connected';

  @override
  String get systemInfoTitle => 'System Information';

  @override
  String get operatingSystem => 'Operating System';

  @override
  String get dockerEngine => 'Docker Engine';

  @override
  String get hardware => 'Hardware';

  @override
  String get networks => 'Networks';

  @override
  String get volumes => 'Volumes';

  @override
  String get osLabel => 'OS';

  @override
  String get kernel => 'Kernel';

  @override
  String get hostname => 'Hostname';

  @override
  String get architecture => 'Architecture';

  @override
  String get version => 'Version';

  @override
  String get apiVersion => 'API Version';

  @override
  String get storageDriver => 'Storage Driver';

  @override
  String get swarmStatus => 'Swarm Status';

  @override
  String get plugins => 'Plugins';

  @override
  String get cpuCores => 'CPU Cores';

  @override
  String get memory => 'Memory';

  @override
  String get gpu => 'GPU';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get useDarkTheme => 'Use dark theme';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get connection => 'Connection';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get notifications => 'Notifications';

  @override
  String get security => 'Security';

  @override
  String get dataStorage => 'Data & Storage';

  @override
  String get about => 'About';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get composeTitle => 'Compose';

  @override
  String get connectionLost => 'Connection Lost';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get systemInformation => 'System Information';

  @override
  String get os => 'OS';

  @override
  String get dockerVersion => 'Docker Version';

  @override
  String get memTotal => 'Total Memory';

  @override
  String get ncpu => 'CPU Cores';

  @override
  String get resourceUsage => 'Resource Usage';

  @override
  String get refreshDetailedStats => 'Refresh detailed stats';

  @override
  String get gpuUtilization => 'GPU Utilization';

  @override
  String get containersSummary => 'Containers Summary';

  @override
  String get running => 'Running';

  @override
  String get stopped => 'Stopped';

  @override
  String get exited => 'Exited';

  @override
  String get volumesNetworks => 'Volumes & Networks';

  @override
  String get createContainerTitle => 'Create Container';

  @override
  String get selectImage => 'Select Image';

  @override
  String get basicConfig => 'Basic Config';

  @override
  String get advancedConfig => 'Advanced Config';

  @override
  String get reviewCreate => 'Review & Create';

  @override
  String stepOf(Object X, Object Y) {
    return 'Step $X of $Y';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get createContainer => 'Create Container';

  @override
  String get failedToLoadImages => 'Failed to load images';

  @override
  String get notConnectedToDocker => 'Not connected to Docker daemon';

  @override
  String get errorLoadingImages => 'Error loading images';

  @override
  String get customImage => 'Custom Image';

  @override
  String get loadingImages => 'Loading images...';

  @override
  String get imageName => 'Image Name';

  @override
  String get infoTab => 'Info';

  @override
  String get statsTab => 'Stats';

  @override
  String get actionsTab => 'Actions';

  @override
  String get noContainerInfo => 'No container information available';

  @override
  String get noStatsAvailable => 'No stats available';

  @override
  String get noLogsAvailable => 'No logs available';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get ports => 'Ports';

  @override
  String get envVars => 'Environment Variables';

  @override
  String get containerId => 'Container ID';

  @override
  String get name => 'Name';

  @override
  String get image => 'Image';

  @override
  String get status => 'Status';

  @override
  String get created => 'Created';

  @override
  String get port => 'Port';

  @override
  String get volume => 'Volume';

  @override
  String get env => 'ENV';

  @override
  String get network => 'Network';

  @override
  String get pause => 'Pause';

  @override
  String get follow => 'Follow';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get authentication => 'Authentication';

  @override
  String get advancedOptions => 'Advanced Options';

  @override
  String get rememberThisConnectionLong => 'Remember This Connection';

  @override
  String get useTls => 'Use TLS';

  @override
  String get enableSecureConnection => 'Enable secure connection';

  @override
  String get stayLoggedIn => 'Stay Logged In';

  @override
  String get dockerHostUri => 'Docker Host URI';

  @override
  String get authenticationLabel => 'Authentication';

  @override
  String get advancedOptionsLabel => 'Advanced Options';

  @override
  String get rememberConnection => 'Remember connection';

  @override
  String get tlsEnabled => 'TLS enabled';

  @override
  String get tlsDisabled => 'TLS disabled';

  @override
  String get more => 'More';

  @override
  String get rememberThisConnection => 'Remember This Connection';

  @override
  String get recentConnections => 'Recent Connections';

  @override
  String get noHistory => 'No recent connections found';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get loadingResourceData => 'Loading resource data...';

  @override
  String get notConnectedMessage =>
      'Not connected to Docker. Please connect first.';

  @override
  String get searchLogsHint => 'Search logs...';

  @override
  String get timeAllTime => 'All Time';

  @override
  String get lines => 'Lines:';

  @override
  String get noVolumesFound => 'No volumes found';

  @override
  String get noNetworksFound => 'No networks found';

  @override
  String removeVolumeConfirm(String name) {
    return 'Remove volume \"$name\"?';
  }

  @override
  String removeNetworkConfirm(String name) {
    return 'Remove network \"$name\"?';
  }

  @override
  String removedVolume(String name) {
    return 'Removed $name';
  }

  @override
  String failedToRemoveVolume(String name) {
    return 'Failed to remove $name';
  }

  @override
  String removedNetwork(String name) {
    return 'Removed $name';
  }

  @override
  String failedToRemoveNetwork(String name) {
    return 'Failed to remove $name';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get networksTitle => 'Networks';

  @override
  String get loading => 'Loading...';

  @override
  String get failedToFetchNetworkDetails => 'Failed to fetch network details';

  @override
  String removeImageConfirm(String name) {
    return 'Are you sure you want to remove $name?';
  }

  @override
  String removedImageSuccess(String name) {
    return 'Successfully removed $name';
  }

  @override
  String get failedToRemoveImage => 'Failed to remove image';

  @override
  String containerCreatedSuccessfully(String id) {
    return 'Container created successfully! ID: $id';
  }

  @override
  String containerStartedSuccessfully(String id) {
    return 'Container created and started successfully! ID: $id';
  }

  @override
  String get imageNameRequired => 'Image name is required.';

  @override
  String get imageNameInvalid =>
      'Image name can only contain letters, numbers, dots, dashes, underscores, and slashes.';

  @override
  String get tagRequired => 'Tag is required.';

  @override
  String get tagInvalid =>
      'Tag can only contain letters, numbers, dots, dashes, and underscores.';

  @override
  String get portRequired => 'Port is required.';

  @override
  String get portInvalid => 'Port must be a number between 1 and 65535.';

  @override
  String get containerNameLabel => 'Container Name';

  @override
  String get containerNameHint => 'my-container';

  @override
  String get interactive => 'Interactive';

  @override
  String get keepStdinOpen => 'Keep STDIN open';

  @override
  String get tty => 'TTY';

  @override
  String get allocatePseudoTty => 'Allocate pseudo-TTY';

  @override
  String get autoRemoveLabel => 'Auto Remove';

  @override
  String get removeOnExit => 'Remove container when it exits';

  @override
  String get startAfterCreateLabel => 'Start After Create';

  @override
  String get startAfterCreateSubtitle =>
      'Automatically start the container after creation';

  @override
  String get portMappings => 'Port Mappings';

  @override
  String get hostPort => 'Host Port';

  @override
  String get containerPort => 'Container Port';

  @override
  String get volumeMappings => 'Volume Mappings';

  @override
  String get hostPath => 'Host Path';

  @override
  String get containerPath => 'Container Path';

  @override
  String get envVarsLabel => 'Environment Variables';

  @override
  String get variableName => 'Variable Name';

  @override
  String get value => 'Value';

  @override
  String get networkModeLabel => 'Network Mode';

  @override
  String get networkBridge => 'Bridge';

  @override
  String get networkHost => 'Host';

  @override
  String get networkNone => 'None';

  @override
  String get imageLabel => 'Image';

  @override
  String get nameLabel => 'Name';

  @override
  String get networkLabel => 'Network';

  @override
  String get portsLabel => 'Ports';

  @override
  String get volumesLabel => 'Volumes';

  @override
  String get environmentLabel => 'Environment';

  @override
  String get optionsLabel => 'Options';

  @override
  String get createVolumeTitle => 'Create Volume';

  @override
  String volumeCreatedSuccessfully(String name) {
    return 'Volume $name created successfully!';
  }

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get review => 'Review';

  @override
  String get createNetworkTitle => 'Create Network';

  @override
  String networkCreatedSuccessfully(String name) {
    return 'Network $name created successfully!';
  }

  @override
  String get ipamConfig => 'IPAM Config';

  @override
  String get noProjectsFound => 'No Compose Projects Found';

  @override
  String get composeLabelHint =>
      'Ensure labels com.docker.compose.project exist on containers.';

  @override
  String get navDash => 'Dash';

  @override
  String get navContainers => 'Containers';

  @override
  String get navImages => 'Images';

  @override
  String get navMonitor => 'Monitor';

  @override
  String get navCompose => 'Compose';

  @override
  String get navConfig => 'Config';

  @override
  String get autoRefresh => 'Auto Refresh';

  @override
  String get autoRefreshSubtitle => 'Automatically refresh data';

  @override
  String get refreshInterval => 'Refresh Interval';

  @override
  String seconds(int count) {
    return '$count seconds';
  }

  @override
  String get logout => 'Logout';

  @override
  String get logoutSubtitle => 'Disconnect and clear saved data';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get showPushNotifications => 'Show push notifications';

  @override
  String get containerEvents => 'Container Events';

  @override
  String get notifyContainerChanges => 'Notify on container state changes';

  @override
  String get resourceAlerts => 'Resource Alerts';

  @override
  String get notifyHighUsage => 'Notify on high resource usage';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get configPushThresholds =>
      'Configure push notifications and thresholds';

  @override
  String get viewDetailedInfo => 'View detailed system info';

  @override
  String get save => 'Save';

  @override
  String get logoutConfirm =>
      'Are you sure you want to logout? This will disconnect from the Docker host and clear all saved connection data.';

  @override
  String get loggedOutSuccessfully => 'Logged out successfully';

  @override
  String get release => 'Release';

  @override
  String get cpuThreads => 'CPU Threads';

  @override
  String get cpuModel => 'CPU Model';

  @override
  String get disk => 'Disk';

  @override
  String get authNoneDesc => 'Connect without authentication';

  @override
  String get authBasicDesc => 'Use username and password';

  @override
  String get onboardingTitle1 => 'Unrestricted Lifecycle Control';

  @override
  String get onboardingSubtitle1 =>
      'Start, Stop, and Recreate containers instantly. Pull, delete, and inspect image repositories natively dashboards setup streamline.';

  @override
  String get onboardingTitle2 => 'Docker Compose Orchestration';

  @override
  String get onboardingSubtitle2 =>
      'Execute entire multi-container clusters together using Docker Compose configurations setups transparently streamline layouts.';

  @override
  String get onboardingTitle3 => 'Native Analytics & Node Metrics';

  @override
  String get onboardingSubtitle3 =>
      'Stream real-time datasets detailing continuous CPU datasets limit allocations, Memory leaks analytics and I/O rates.';

  @override
  String get onboardingTitle4 => 'Interactive Exec TTY Terminals';

  @override
  String get onboardingSubtitle4 =>
      'Spawn live interactive secure shell sessions directly inside container workspaces dashboards streamline frames transparent setup correctly.';

  @override
  String get onboardingTitle5 => 'Step 1: Run Backend';

  @override
  String get onboardingSubtitle5 =>
      'To talk to Docker daemon, run our secure container server configuration.';

  @override
  String get onboardingDesc5 =>
      '1. git clone github.com/nikosgiov/orca\n2. Follow the README instructions to configure Firebase and start the orca-server.\n3. Ensure your exposed port is accessible.';

  @override
  String get onboardingTitle6 => 'Step 2: Connect!';

  @override
  String get onboardingSubtitle6 =>
      'Connect your mobile app securely to your server in seconds.';

  @override
  String get onboardingDesc6 =>
      'Enter your Server IP:PORT in the connection screen. Supports Basic auth or TLS securely environments transparent.';

  @override
  String get skip => 'Skip';

  @override
  String get startSetup => 'Start setup';

  @override
  String get continueLabel => 'Continue';

  @override
  String get gpuUsage => 'GPU Usage';

  @override
  String get timeframe => 'Timeframe';

  @override
  String minutesCount(int count) {
    return '$count Minutes';
  }

  @override
  String hoursCount(int count) {
    return '$count Hours';
  }

  @override
  String get terminalTitle => 'Terminal';

  @override
  String connectingTo(String name) {
    return 'Connecting to $name...';
  }

  @override
  String get processTerminated => '[Process Terminated]';

  @override
  String streamError(String error) {
    return '[Stream Error] $error';
  }

  @override
  String get connectionClosed => '[Connection Closed]';

  @override
  String webSocketError(String error) {
    return '[WebSocket Error] $error';
  }

  @override
  String connectedVia(String shell) {
    return '[Connected via $shell]';
  }

  @override
  String connectionFailed(String error) {
    return '[Connection Failed] $error';
  }

  @override
  String get copy => 'COPY';

  @override
  String get paste => 'PASTE';

  @override
  String get systemNode => 'System Node';

  @override
  String get liveTelemetry => 'Live Telemetry';

  @override
  String get updatedJustNow => 'UPDATED: JUST NOW';

  @override
  String get create => 'Create';

  @override
  String get allNotificationsMarkedRead => 'All notifications marked as read';

  @override
  String get all => 'All';

  @override
  String get unknown => 'Unknown';

  @override
  String get loadingContainers => 'Loading containers...';

  @override
  String get none => 'None';

  @override
  String get notAvailable => 'N/A';

  @override
  String get startContainer => 'Start Container';

  @override
  String get stopContainer => 'Stop Container';

  @override
  String get pauseContainer => 'Pause Container';

  @override
  String get resumeContainer => 'Resume Container';

  @override
  String get restartContainer => 'Restart Container';

  @override
  String get openTerminal => 'Open Terminal';

  @override
  String get killContainer => 'Kill Container';

  @override
  String get renameContainer => 'Rename Container';

  @override
  String get removeContainer => 'Remove Container';

  @override
  String get killConfirmTitle => 'Kill Container';

  @override
  String killConfirmMessage(Object name) {
    return 'Are you sure you want to kill \"$name\"?';
  }

  @override
  String killedContainer(Object name) {
    return 'Killed $name';
  }

  @override
  String get renameConfirmTitle => 'Rename Container';

  @override
  String get enterNewName => 'Enter new name:';

  @override
  String get newName => 'New Name';

  @override
  String renamedTo(Object name) {
    return 'Renamed to $name';
  }

  @override
  String get failedToRename => 'Failed to rename';

  @override
  String get removeConfirmTitle => 'Remove Container';

  @override
  String removeConfirmMessage(Object name) {
    return 'Remove \"$name\"? This cannot be undone.';
  }

  @override
  String removedContainer(Object name) {
    return 'Removed $name';
  }

  @override
  String get failedToRemove => 'Failed to remove';

  @override
  String actionSuccess(Object action) {
    return 'Successfully ${action}ed container';
  }

  @override
  String actionFailed(Object action) {
    return 'Failed to $action';
  }

  @override
  String get statusLabel => 'STATUS';

  @override
  String get tagLabel => 'Tag';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get registerSuccess => 'Successfully registered for notifications';

  @override
  String registerFailed(Object error) {
    return 'Failed to register for notifications: $error';
  }

  @override
  String get unregisterSuccess =>
      'Successfully unregistered from notifications';

  @override
  String unregisterFailed(Object error) {
    return 'Failed to unregister from notifications: $error';
  }

  @override
  String get thresholdsUpdated => 'Thresholds updated successfully';

  @override
  String get enterPercent => 'Enter 0–100';

  @override
  String get noActiveConnection => 'No active connection';

  @override
  String failedToLoadSettings(Object error) {
    return 'Failed to load notification settings: $error';
  }

  @override
  String failedToUpdateServer(Object error) {
    return 'Failed to update server: $error';
  }

  @override
  String get pullImage => 'Pull Image';

  @override
  String get pull => 'Pull';

  @override
  String pullingImage(Object name, Object tag) {
    return 'Pulling $name:$tag... This may take a while.';
  }

  @override
  String pullSuccess(Object name) {
    return 'Successfully pulled $name';
  }

  @override
  String get pullFailed => 'Failed to pull image';

  @override
  String get loadingImagesProgress => 'Loading images...';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get preparingContainerCreation => 'Preparing container creation...';

  @override
  String failedToCreateContainer(Object error) {
    return 'Failed to create container: $error';
  }

  @override
  String get driverOptionValueRequired => 'Driver option value is required';

  @override
  String get driverOptionKeyRequired => 'Driver option key is required';

  @override
  String get labelValueRequired => 'Label value is required';

  @override
  String get labelKeyRequired => 'Label key is required';

  @override
  String get notConnectedDocker =>
      'Not connected to Docker. Please connect first.';

  @override
  String get failedToCreateVolume => 'Failed to create volume';

  @override
  String errorCreatingVolume(Object error) {
    return 'Error creating volume: $error';
  }

  @override
  String get driverLocal => 'Local';

  @override
  String get driverNfs => 'NFS';

  @override
  String get driverCifs => 'CIFS';

  @override
  String get driverTmpfs => 'Tmpfs';

  @override
  String get networkOverlay => 'Overlay';

  @override
  String get networkMacvlan => 'Macvlan';

  @override
  String get networkIpvlan => 'IPvlan';

  @override
  String get volumeName => 'Volume Name';

  @override
  String get networkName => 'Network Name';

  @override
  String get markRead => 'Mark Read';

  @override
  String get markUnread => 'Mark Unread';

  @override
  String get labelKeyInvalid =>
      'Label key can only contain letters, numbers, dots, dashes, and underscores';

  @override
  String get labelValueNoTabs => 'Label value cannot contain newlines or tabs';

  @override
  String get labelValueTooLong => 'Label value cannot exceed 255 characters';

  @override
  String get driverOptionKeyInvalid =>
      'Driver option key can only contain letters, numbers, dots, dashes, and underscores';

  @override
  String get driverOptionValueNoTabs =>
      'Driver option value cannot contain newlines or tabs';

  @override
  String get driverOptionValueTooLong =>
      'Driver option value cannot exceed 255 characters';

  @override
  String get driverOptions => 'Driver Options';

  @override
  String get noOptionsAdded => 'No options added';

  @override
  String get keyLabel => 'Key';

  @override
  String get valueLabel => 'Value';

  @override
  String get noLabelsAdded => 'No labels added';

  @override
  String get addOption => 'Add option';

  @override
  String get addLabel => 'Add label';

  @override
  String get volumeNameRequired => 'Volume name is required';

  @override
  String get volumeNameInvalid =>
      'Volume name can only contain letters, numbers, dots, dashes, underscores, and slashes';

  @override
  String get networkNameRequired => 'Network name is required';

  @override
  String get networkNameInvalid =>
      'Network name can only contain letters, numbers, dots, dashes, underscores, and slashes';

  @override
  String get volumesTitle => 'Volumes';

  @override
  String get driverLabel => 'Driver';

  @override
  String get labels => 'Labels';

  @override
  String get failed => 'Failed';

  @override
  String get required => 'Required';

  @override
  String get saveHostCredentials => 'Save Host Credentials';

  @override
  String get dontRemember => 'Don\'t Remember';

  @override
  String get invalidIpPort => 'Invalid IP:PORT format';

  @override
  String get errorLoadingContainerData => 'Error loading container data';

  @override
  String get createFirstContainer => 'Create your first container';

  @override
  String get error => 'Error';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get connectionLostDesc =>
      'We lost connection to the Docker daemon. Please check your network or server status.';

  @override
  String get errorTimeout =>
      'Connection timed out. Please check your network and host URI.';

  @override
  String get errorConnection =>
      'Could not connect to the server. Ensure the host is reachable.';

  @override
  String get errorUnauthorized =>
      'Unauthorized: Please check your credentials.';

  @override
  String get errorForbidden =>
      'Access Forbidden: You do not have permission to access this resource.';

  @override
  String get errorNotFound => 'Resource not found (404).';

  @override
  String get errorInternal =>
      'Internal Server Error (500). Please check your Docker daemon logs.';

  @override
  String get errorUnknown => 'Unknown network error';
}
