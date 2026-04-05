class ImageFormatUtils {
  static String getImageDisplayName(Map<String, dynamic> image) {
    final repoTags = image['RepoTags'] as List? ?? [];
    if (repoTags.isNotEmpty) {
      return repoTags.first.toString();
    }
    final repoDigests = image['RepoDigests'] as List? ?? [];
    if (repoDigests.isNotEmpty) {
      final digest = repoDigests.first.toString();
      final parts = digest.split('@');
      if (parts.length > 1) {
        return parts[0];
      }
    }
    return image['Id']?.toString().substring(0, 12) ?? 'Unknown';
  }

  static String formatSize(dynamic size) {
    if (size == null) return 'Unknown';
    final sizeInBytes = (size as int?) ?? 0;
    if (sizeInBytes < 1024) {
      return '${sizeInBytes}B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)}KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  static String formatCreatedDate(dynamic created) {
    if (created == null) return 'Unknown';
    try {
      final timestamp = (created as int?) ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  static String getImageDigest(Map<String, dynamic> image) {
    final repoDigests = image['RepoDigests'] as List? ?? [];
    if (repoDigests.isNotEmpty) {
      final digest = repoDigests.first.toString();
      if (digest.contains('@')) {
        return digest.split('@')[1].substring(0, 12);
      }
      return digest.substring(0, 12);
    }
    return 'No digest';
  }
} 