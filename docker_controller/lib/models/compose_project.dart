class ComposeProject {
  final String name;
  final String workingDir;
  final List<String> configFiles;
  final List<ComposeContainer> containers;

  ComposeProject({
    required this.name,
    required this.workingDir,
    required this.configFiles,
    required this.containers,
  });

  factory ComposeProject.fromJson(Map<String, dynamic> json) {
    return ComposeProject(
      name: json['name'] as String? ?? 'Unknown',
      workingDir: json['working_dir'] as String? ?? '',
      configFiles: (json['config_files'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      containers: (json['containers'] as List<dynamic>?)
              ?.map((c) => ComposeContainer.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  int get runningCount => containers.where((c) => c.state == 'running').length;
  int get totalCount => containers.length;
}

class ComposeContainer {
  final String id;
  final String name;
  final String image;
  final String state;
  final String status;
  final String service;

  ComposeContainer({
    required this.id,
    required this.name,
    required this.image,
    required this.state,
    required this.status,
    required this.service,
  });

  factory ComposeContainer.fromJson(Map<String, dynamic> json) {
    return ComposeContainer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      state: json['state'] as String? ?? 'unknown',
      status: json['status'] as String? ?? '',
      service: json['service'] as String? ?? '',
    );
  }
}
