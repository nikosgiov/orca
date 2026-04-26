import '../models/docker_container.dart';

class ContainerFilterUtils {
  /// Filters a list of [DockerContainer] based on a search query and a selected status filter.
  static List<DockerContainer> filterContainers({
    required List<DockerContainer> containers,
    required String searchQuery,
    required String selectedFilter,
  }) {
    return containers.where((container) {
      final name = container.displayName;
      final image = container.image;
      final state = container.stateDisplay.toLowerCase();
      
      final matchesSearch =
          name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          image.toLowerCase().contains(searchQuery.toLowerCase());
          
      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'Running' && state == 'running') ||
          (selectedFilter == 'Stopped' && (state == 'stopped' || state == 'exited')) ||
          (selectedFilter == 'Exited' && state == 'exited');
          
      return matchesSearch && matchesFilter;
    }).toList();
  }
}
