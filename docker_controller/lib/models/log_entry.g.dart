// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LogEntryImpl _$$LogEntryImplFromJson(Map<String, dynamic> json) =>
    _$LogEntryImpl(
      timestamp: json['timestamp'] as String,
      level: $enumDecode(_$LogLevelEnumMap, json['level']),
      container: json['container'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$LogEntryImplToJson(_$LogEntryImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'level': _$LogLevelEnumMap[instance.level]!,
      'container': instance.container,
      'message': instance.message,
    };

const _$LogLevelEnumMap = {
  LogLevel.all: 'all',
  LogLevel.error: 'error',
  LogLevel.warn: 'warn',
  LogLevel.info: 'info',
  LogLevel.debug: 'debug',
};
