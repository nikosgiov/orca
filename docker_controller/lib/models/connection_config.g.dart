// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConnectionConfigImpl _$$ConnectionConfigImplFromJson(
  Map<String, dynamic> json,
) => _$ConnectionConfigImpl(
  uri: json['uri'] as String,
  authType:
      $enumDecodeNullable(_$AuthTypeEnumMap, json['authType']) ?? AuthType.none,
  token: json['token'] as String?,
  useTls: json['useTls'] as bool? ?? false,
  firebaseConfig: json['firebaseConfig'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ConnectionConfigImplToJson(
  _$ConnectionConfigImpl instance,
) => <String, dynamic>{
  'uri': instance.uri,
  'authType': _$AuthTypeEnumMap[instance.authType]!,
  'token': instance.token,
  'useTls': instance.useTls,
  'firebaseConfig': instance.firebaseConfig,
};

const _$AuthTypeEnumMap = {AuthType.none: 'none', AuthType.basic: 'basic'};
