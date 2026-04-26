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
  String get resourceMonitoringTitle => 'Resource Monitoring';

  @override
  String get timeframe => 'Timeframe';

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
  String get loadingResourceData => 'Loading resource data...';

  @override
  String get notConnectedMessage =>
      'Not connected to Docker. Please connect first.';
}
