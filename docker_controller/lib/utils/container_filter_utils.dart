class ContainerFilterUtils {
  static List<Map<String, dynamic>> filterContainers({
    required List<Map<String, dynamic>> containers,
    required String searchQuery,
    required String selectedFilter,
  }) {
    return containers.where((container) {
      final name = container['Names']?.first?.toString().replaceFirst('/', '') ?? '';
      final image = container['Image']?.toString() ?? '';
      final state = container['State']?.toString() ?? '';
      final matchesSearch = name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                           image.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = selectedFilter == 'All' || 
                           (selectedFilter == 'Running' && state == 'running') ||
                           (selectedFilter == 'Stopped' && state == 'stopped') ||
                           (selectedFilter == 'Exited' && state == 'exited');
      return matchesSearch && matchesFilter;
    }).toList();
  }
} 