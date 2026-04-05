class AppStrings {
  AppStrings._();

  static const String appName = 'Docker Controller';
  static const String appTagline = 'Manage Docker\nRemotely, Anytime, Anywhere';
  
  // Connection Screen
  static const String dockerApiUri = 'Docker API IP:PORT';
  static const String dockerApiUriHintIpPort = 'e.g. 192.168.1.10:2375';
  static const String authType = 'Auth Type';
  static const String connect = 'Connect';
  static const String connecting = 'Connecting...';
  static const String advanced = 'Advanced';
  static const String saveCredentials = 'Save Credentials';
  static const String tlsCerts = 'TLS Certificates';
  
  // Auth Types
  static const String authNone = 'None';
  static const String authBasic = 'Basic';
  
  // Form Labels
  static const String username = 'Username';
  static const String password = 'Password';
  
  // Validation Messages
  static const String uriRequired = 'Docker API URI is required';
  static const String invalidIpPort = 'Please enter a valid IP:PORT (e.g. 192.168.1.10:2375)';
  static const String usernameRequired = 'Username is required for Basic auth';
  static const String passwordRequired = 'Password is required for Basic auth';
  
  // Containers Screen
  static const String containersTitle = 'Containers';
  static const String searchContainersHint = 'Search containers...';
  static const String noContainersFound = 'No containers found';
  static const String createFirstContainer = 'Create your first container to get started';
  static const String statusRunning = 'Running';
  static const String statusStopped = 'Stopped';
  static const String statusExited = 'Exited';
  static const String statusUnknown = 'Unknown';
  static const String labelImage = 'Image';
  static const String labelPorts = 'Ports';
  static const String labelUptime = 'Uptime';
  static const String noPorts = 'No ports';
  static const String justCreated = 'Just created';
  static const String actionStart = 'Start';
  static const String actionStop = 'Stop';
  static const String actionDetails = 'Details';
  static const String startedContainer = 'Started container';
  static const String failedToStartContainer = 'Failed to start container';
  static const String errorStartingContainer = 'Error starting container';
  static const String stoppedContainer = 'Stopped container';
  static const String failedToStopContainer = 'Failed to stop container';
  static const String errorStoppingContainer = 'Error stopping container';
  
  // Images Screen
  static const String imagesTitle = 'Images';
  static const String searchImagesHint = 'Search images...';
  static const String noImagesFound = 'No images found';
  static const String pullFirstImage = 'Pull your first image to get started';
  
  // Images Screen (continued)
  static const String actionRunContainer = 'Run Container';
  static const String copiedRawJson = 'Copied raw JSON to clipboard';
  static const String close = 'Close';
  static const String labelCreated = 'Created';
  static const String labelDigest = 'Digest';
  static const String labelId = 'ID';
  static const String labelRepoTags = 'RepoTags';
  static const String labelRepoDigests = 'RepoDigests';
  static const String labelLabels = 'Labels';
  static const String labelParentId = 'Parent ID';
  static const String labelComment = 'Comment';
  static const String labelOs = 'OS';
  static const String labelArchitecture = 'Architecture';
  static const String labelVirtualSize = 'Virtual Size';
  
  // Volumes & Networks Screen
  static const String volumesNetworksTitle = 'Volumes & Networks';
  static const String dockerVolumes = 'Docker Volumes';
  static const String dockerNetworks = 'Docker Networks';
  static const String createVolume = 'Create Volume';
  static const String createNetwork = 'Create Network';
  
  // Volumes & Networks Screen (continued)
  static const String labelMountPoint = 'Mount Point';
  static const String labelContainers = 'Containers';
  static const String labelSubnet = 'Subnet';
  static const String labelDriver = 'Driver';
  static const String labelScope = 'Scope';
  
  // General/shared actions and labels
  static const String actionInspect = 'Inspect';
  static const String actionRemove = 'Remove';
  static const String labelSize = 'Size';
  
  // Logs & Notifications Screen
  static const String logsNotificationsTitle = 'Logs & Notifications';
  static const String logsTab = 'Logs';
  static const String notificationsTab = 'Notifications';
  static const String logLevelLabel = 'Log Level';
  static const String containerLabel = 'Container';
  static const String logLevelAll = 'All';
  static const String logLevelError = 'Error';
  static const String logLevelWarn = 'Warning';
  static const String logLevelInfo = 'Info';
  static const String logLevelDebug = 'Debug';
  
  // Logs & Notifications Screen (continued)
  static const String followLogs = 'Follow Logs';
  static const String clear = 'Clear';
  static const String markAllRead = 'Mark All Read';
  
  // Resource Monitoring Screen
  static const String resourceMonitoringTitle = 'Resource Monitoring';
  static const String timeRangeLabel = 'Time Range';
  static const String containerDropdownLabel = 'Container';
  static const String timeRange1Hour = '1 Hour';
  static const String timeRange6Hours = '6 Hours';
  static const String timeRange24Hours = '24 Hours';
  static const String timeRange7Days = '7 Days';
  
  // Resource Monitoring Screen (continued)
  static const String cpuUsage = 'CPU Usage';
  static const String memoryUsage = 'Memory Usage';
  static const String networkIO = 'Network I/O';
  static const String diskIO = 'Disk I/O';
  static const String noDataAvailable = 'No data available';
  static const String notConnected = 'Not Connected';
  static const String connectToDocker = 'Connect to Docker daemon to view resource monitoring';
  
  // System Info Screen
  static const String systemInfoTitle = 'System Information';
  static const String operatingSystem = 'Operating System';
  static const String dockerEngine = 'Docker Engine';
  static const String hardware = 'Hardware';
  static const String networks = 'Networks';
  static const String volumes = 'Volumes';
  static const String osLabel = 'OS';
  static const String kernel = 'Kernel';
  static const String hostname = 'Hostname';
  static const String architecture = 'Architecture';
  static const String version = 'Version';
  static const String apiVersion = 'API Version';
  static const String storageDriver = 'Storage Driver';
  static const String swarmStatus = 'Swarm Status';
  static const String plugins = 'Plugins';
  static const String cpuCores = 'CPU Cores';
  static const String memory = 'Memory';
  static const String gpu = 'GPU';
  
  // Settings Screen
  static const String settingsTitle = 'Settings';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String useDarkTheme = 'Use dark theme';
  static const String theme = 'Theme';
  static const String system = 'System';
  static const String connection = 'Connection';
  static const String connected = 'Connected';
  static const String disconnected = 'Disconnected';
  static const String settingsSaved = 'Settings saved';
  static const String notifications = 'Notifications';
  static const String security = 'Security';
  static const String dataStorage = 'Data & Storage';
  static const String about = 'About';
  
  // Home Screen
  static const String dashboardTitle = 'Dashboard';

  // Compose Screen
  static const String composeTitle = 'Compose';
  
  // Home Screen (continued)
  static const String connectionLost = 'Connection Lost';
  static const String connectionLostDesc = 'The connection to the Docker daemon has been lost.';
  static const String connectionError = 'Connection Error';
  static const String reconnect = 'Reconnect';
  static const String systemInformation = 'System Information';
  static const String os = 'OS';
  static const String dockerVersion = 'Docker Version';
  static const String memTotal = 'Total Memory';
  static const String ncpu = 'CPU Cores';
  static const String resourceUsage = 'Resource Usage';
  static const String refreshDetailedStats = 'Refresh detailed stats';
  static const String gpuUtilization = 'GPU Utilization';
  static const String containersSummary = 'Containers Summary';
  static const String running = 'Running';
  static const String stopped = 'Stopped';
  static const String exited = 'Exited';
  static const String volumesNetworks = 'Volumes & Networks';
  
  // Create Container Screen
  static const String createContainerTitle = 'Create Container';
  static const String selectImage = 'Select Image';
  static const String basicConfig = 'Basic Config';
  static const String advancedConfig = 'Advanced Config';
  static const String reviewCreate = 'Review & Create';
  static const String stepOf = 'Step {X} of {Y}';
  static const String previous = 'Previous';
  static const String next = 'Next';
  static const String createContainer = 'Create Container';
  static const String failedToLoadImages = 'Failed to load images';
  static const String notConnectedToDocker = 'Not connected to Docker daemon';
  static const String errorLoadingImages = 'Error loading images';
  static const String customImage = 'Custom Image';
  static const String loadingImages = 'Loading images...';
  static const String imageName = 'Image Name';
  
  // Container Detail Screen
  static const String infoTab = 'Info';
  static const String statsTab = 'Stats';
  static const String actionsTab = 'Actions';
  static const String noContainerInfo = 'No container information available';
  static const String noStatsAvailable = 'No stats available';
  static const String noLogsAvailable = 'No logs available';
  static const String basicInformation = 'Basic Information';
  static const String ports = 'Ports';
  static const String envVars = 'Environment Variables';
  static const String containerId = 'Container ID';
  static const String name = 'Name';
  static const String image = 'Image';
  static const String status = 'Status';
  static const String created = 'Created';
  static const String port = 'Port';
  static const String volume = 'Volume';
  static const String env = 'ENV';
  static const String network = 'Network';
  static const String pause = 'Pause';
  static const String follow = 'Follow';
  static const String refresh = 'Refresh';
  static const String errorLoadingContainerData = 'Error loading container data';
  static const String retry = 'Retry';
  
  // Connection Screen (continued)
  static const String authentication = 'Authentication';
  static const String advancedOptions = 'Advanced Options';
  static const String rememberThisConnectionLong = 'Remember This Connection';
  static const String saveHostCredentials = 'Save host and credentials for automatic login';
  static const String hostUriAlwaysSaved = 'The host URI will always be saved for convenience, even if credentials are not saved.';
  static const String useTls = 'Use TLS';
  static const String enableSecureConnection = 'Enable secure connection';
  static const String stayLoggedIn = 'Stay Logged In';
  static const String stayLoggedInSubtitle = 'Remain logged in on this device. If unchecked, you will be logged out when you close the app.';
  static const String autoLogoutMessage = 'Connection failed multiple times. Please re-enter your Docker host details.';

  /// Label for the Docker host URI input field.
  static const String dockerHostUri = 'Docker Host URI';

  /// Label shown on the authentication picker tile.
  static const String authenticationLabel = 'Authentication';

  /// Label shown on the advanced options picker tile.
  static const String advancedOptionsLabel = 'Advanced Options';

  /// Status text when the "remember connection" toggle is on (short form).
  static const String rememberConnection = 'Remember connection';

  /// Status text when the "remember connection" toggle is off.
  static const String dontRemember = "Don't remember";

  /// Status text when TLS is enabled.
  static const String tlsEnabled = 'TLS enabled';

  /// Status text when TLS is disabled.
  static const String tlsDisabled = 'TLS disabled';

  /// Generic short label for a "More details" button.
  static const String more = 'More';

  /// Label for the "Remember This Connection" switch in the advanced drawer.
  static const String rememberThisConnection = 'Remember This Connection';

  // Connection History
  static const String recentConnections = 'Recent Connections';
  static const String noHistory = 'No recent connections found';
  static const String clearHistory = 'Clear History';
}
