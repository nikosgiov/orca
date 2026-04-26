class ContainerFormatUtils {
  static String formatDate(String? dateString) {
    if (dateString == null) {
      return 'Unknown';
    }
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }

  static List<String> formatPorts(dynamic ports) {
    if (ports == null) {
      return [];
    }
    final List<String> formattedPorts = [];
    if (ports is Map) {
      for (final entry in ports.entries) {
        final containerPort = entry.key;
        final hostBindings = entry.value as List?;
        if (hostBindings != null && hostBindings.isNotEmpty) {
          for (final binding in hostBindings) {
            final hostPort = binding['HostPort'];
            final hostIp = binding['HostIp'];
            if (hostPort != null) {
              final ip = hostIp != null && hostIp.isNotEmpty
                  ? hostIp
                  : '0.0.0.0';
              formattedPorts.add('$ip:$hostPort->$containerPort');
            }
          }
        } else {
          formattedPorts.add(containerPort);
        }
      }
    }
    return formattedPorts;
  }
}
