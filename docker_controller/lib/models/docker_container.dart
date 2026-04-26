import 'package:freezed_annotation/freezed_annotation.dart';

part 'docker_container.freezed.dart';
part 'docker_container.g.dart';

@freezed
class DockerContainer with _$DockerContainer {
  const factory DockerContainer({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Names') @Default([]) List<String> names,
    @JsonKey(name: 'Image') required String image,
    @JsonKey(name: 'State') dynamic state, // Can be String or Map
    @JsonKey(name: 'Status') String? status,
    @JsonKey(name: 'Created') required dynamic created,
    @JsonKey(name: 'Ports') @Default([]) List<Map<String, dynamic>> ports,
    @JsonKey(name: 'Labels') @Default({}) Map<String, dynamic> labels,
    @JsonKey(name: 'Command') String? command,
    @JsonKey(name: 'Mounts') @Default([]) List<Map<String, dynamic>> mounts,
    @JsonKey(name: 'Config') Map<String, dynamic>? config,
    @JsonKey(name: 'HostConfig') Map<String, dynamic>? hostConfig,
    @JsonKey(name: 'NetworkSettings') Map<String, dynamic>? networkSettings,
  }) = _DockerContainer;

  const DockerContainer._();

  factory DockerContainer.fromJson(Map<String, dynamic> json) =>
      _$DockerContainerFromJson(json);

  String get displayName => names.isNotEmpty
      ? names.first.replaceFirst('/', '')
      : id.substring(0, 12);

  String get stateDisplay {
    if (state is String) {
      return state;
    }
    if (state is Map) {
      return state['Status']?.toString() ?? 'unknown';
    }
    return 'unknown';
  }

  bool get isRunning => stateDisplay == 'running';

  DateTime get createdAt {
    if (created is int) {
      return DateTime.fromMillisecondsSinceEpoch(created * 1000);
    }
    if (created is String) {
      return DateTime.parse(created);
    }
    return DateTime.now();
  }

  String get uptime => status ?? 'Unknown';

  String get portDisplay {
    if (ports.isEmpty) {
      return 'No ports';
    }
    return ports
        .map((p) {
          final publicPort = p['PublicPort']?.toString() ?? '';
          final privatePort = p['PrivatePort']?.toString() ?? '';
          final type = p['Type']?.toString() ?? 'tcp';
          if (publicPort != '') {
            return '$publicPort:$privatePort/$type';
          }
          return '$privatePort/$type';
        })
        .join(', ');
  }
}
