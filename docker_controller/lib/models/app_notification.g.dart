// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  read: json['read'] as bool? ?? false,
  timestamp: json['timestamp'] as String,
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'message': instance.message,
  'type': instance.type,
  'read': instance.read,
  'timestamp': instance.timestamp,
};

const _$NotificationTypeEnumMap = {
  NotificationType.success: 'success',
  NotificationType.warning: 'warning',
  NotificationType.error: 'error',
  NotificationType.info: 'info',
};
