import 'package:freezed_annotation/freezed_annotation.dart';

part 'docker_network.freezed.dart';
part 'docker_network.g.dart';

@freezed
class DockerNetwork with _$DockerNetwork {
  const factory DockerNetwork({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'Driver') required String driver,
    @JsonKey(name: 'Scope') required String scope,
    @JsonKey(name: 'Created') String? created,
    @JsonKey(name: 'Internal') required bool internal,
    @JsonKey(name: 'EnableIPv6') required bool enableIPv6,
    @JsonKey(name: 'Labels') @Default({}) Map<String, dynamic> labels,
    @JsonKey(name: 'IPAM') Map<String, dynamic>? ipam,
    @JsonKey(name: 'Containers') Map<String, dynamic>? containers,
  }) = _DockerNetwork;

  factory DockerNetwork.fromJson(Map<String, dynamic> json) =>
      _$DockerNetworkFromJson(json);
}
