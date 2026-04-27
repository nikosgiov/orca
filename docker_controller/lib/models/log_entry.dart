import 'package:freezed_annotation/freezed_annotation.dart';
import 'log_level.dart';

part 'log_entry.freezed.dart';
part 'log_entry.g.dart';

@freezed
class LogEntry with _$LogEntry {
  const factory LogEntry({
    required String timestamp,
    required LogLevel level,
    required String container,
    required String message,
  }) = _LogEntry;

  factory LogEntry.fromJson(Map<String, dynamic> json) => _$LogEntryFromJson(json);
}
