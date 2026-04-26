class ContainerConfigBuilder {
  static Map<String, dynamic> buildConfig({
    required String selectedImage,
    required String containerName,
    required bool tty,
    required bool interactive,
    required String networkMode,
    required bool autoRemove,
    required List<Map<String, String>> portMappings,
    required List<Map<String, String>> volumeMappings,
    required List<Map<String, String>> environmentVars,
  }) {
    final containerConfig = <String, dynamic>{
      'Image': selectedImage,
      'Cmd': [],
      'Tty': tty,
      'OpenStdin': interactive,
      'StdinOnce': false,
      'AttachStdin': interactive,
      'AttachStdout': true,
      'AttachStderr': true,
      'NetworkMode': networkMode,
      'AutoRemove': autoRemove,
    };
    if (containerName.isNotEmpty) {
      containerConfig['name'] = containerName;
    }
    if (portMappings.isNotEmpty) {
      final portBindings = <String, List<Map<String, String>>>{};
      final exposedPorts = <String, Map<String, dynamic>>{};
      for (final mapping in portMappings) {
        final hostPort = mapping['host'];
        final containerPort = mapping['container'];
        if (hostPort != null &&
            hostPort.isNotEmpty &&
            containerPort != null &&
            containerPort.isNotEmpty) {
          final formattedContainerPort = containerPort.contains('/')
              ? containerPort
              : '$containerPort/tcp';
          portBindings[formattedContainerPort] = [
            {'HostPort': hostPort, 'HostIp': ''},
          ];
          exposedPorts[formattedContainerPort] = <String, dynamic>{};
        }
      }
      if (portBindings.isNotEmpty) {
        containerConfig['HostConfig'] = <String, dynamic>{
          'PortBindings': portBindings,
        };
      }
      if (exposedPorts.isNotEmpty) {
        containerConfig['ExposedPorts'] = exposedPorts;
      }
    }
    if (volumeMappings.isNotEmpty) {
      final binds = <String>[];
      for (final mapping in volumeMappings) {
        final hostPath = mapping['host'];
        final containerPath = mapping['container'];
        if (hostPath != null &&
            hostPath.isNotEmpty &&
            containerPath != null &&
            containerPath.isNotEmpty) {
          binds.add('$hostPath:$containerPath');
        }
      }
      if (binds.isNotEmpty) {
        if (containerConfig['HostConfig'] == null) {
          containerConfig['HostConfig'] = <String, dynamic>{};
        }
        containerConfig['HostConfig']['Binds'] = binds;
      }
    }
    if (environmentVars.isNotEmpty) {
      final env = <String>[];
      for (final envVar in environmentVars) {
        final name = envVar['name'];
        final value = envVar['value'];
        if (name != null && name.isNotEmpty && value != null) {
          env.add('$name=$value');
        }
      }
      if (env.isNotEmpty) {
        containerConfig['Env'] = env;
      }
    }
    return containerConfig;
  }
}
