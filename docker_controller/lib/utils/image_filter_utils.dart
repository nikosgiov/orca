class ImageFilterUtils {
  static List<Map<String, dynamic>> filterImages({
    required List<Map<String, dynamic>> images,
    required String searchQuery,
  }) {
    final searchLower = searchQuery.toLowerCase();
    return images.where((image) {
      final repoTags = image['RepoTags'] as List? ?? [];
      final repoDigests = image['RepoDigests'] as List? ?? [];
      for (final repoTag in repoTags) {
        final tagStr = repoTag.toString().toLowerCase();
        if (tagStr.contains(searchLower)) return true;
      }
      for (final digest in repoDigests) {
        final digestStr = digest.toString().toLowerCase();
        if (digestStr.contains(searchLower)) return true;
      }
      final imageId = image['Id']?.toString().toLowerCase() ?? '';
      if (imageId.contains(searchLower)) return true;
      return false;
    }).toList();
  }
} 