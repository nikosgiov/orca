import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'docker_image.freezed.dart';
part 'docker_image.g.dart';

@freezed
class DockerImage with _$DockerImage {
  const factory DockerImage({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'RepoTags') @Default([]) List<String> repoTags,
    @JsonKey(name: 'RepoDigests') @Default([]) List<String> repoDigests,
    @JsonKey(name: 'Size') required int size,
    @JsonKey(name: 'Created') required int created,
    @JsonKey(name: 'Labels') @Default({}) Map<String, dynamic> labels,
    @JsonKey(name: 'ParentId') String? parentId,
    @JsonKey(name: 'Comment') String? comment,
    @JsonKey(name: 'Os') String? os,
    @JsonKey(name: 'Architecture') String? architecture,
    @JsonKey(name: 'VirtualSize') int? virtualSize,
  }) = _DockerImage;

  const DockerImage._();

  factory DockerImage.fromJson(Map<String, dynamic> json) =>
      _$DockerImageFromJson(json);

  String get displayName =>
      repoTags.isNotEmpty ? repoTags.first : id.substring(0, 12);

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(created * 1000);

  String get displaySize {
    final bytes = virtualSize ?? size;
    if (bytes <= 0) {
      return '0 B';
    }
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  String get displayCreated {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    }
    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }

  String get displayDigest {
    if (repoDigests.isNotEmpty) {
      final digest = repoDigests.first;
      if (digest.contains('@')) {
        return digest.split('@').last;
      }
      return digest;
    }
    return id.substring(0, 12);
  }
}
