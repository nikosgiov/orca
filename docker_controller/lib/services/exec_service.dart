import 'package:docker_controller/models/connection_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ExecService {
  /// Connects to the custom server's WebSocket endpoint for container exec.
  /// The server proxy will handle creating the exec instance and attaching to the Docker API.
  static WebSocketChannel connectToExec(
    ConnectionConfig config,
    String containerId, {
    String shell = '/bin/sh',
  }) {
    // Determine the base WebSocket URL from the connection config's base HTTP URL.
    final protocol = config.useTls ? 'https://' : 'http://';
    final httpUrl = Uri.parse('$protocol${config.uri}');
    final scheme = httpUrl.scheme == 'https' ? 'wss' : 'ws';

    // Construct the endpoint URI
    // e.g. ws://localhost:8000/compose/exec/{containerId}?shell=/bin/sh
    final Map<String, dynamic> queryParams = {'shell': shell};

    // If the config requires an authorization token, pass it as a query param.
    // (WebSockets in the browser/flutter don't easily allow setting the Authorization header directly)
    if (config.token != null && config.token!.isNotEmpty) {
      queryParams['token'] = config.token;
    }

    final wsUri = Uri(
      scheme: scheme,
      host: httpUrl.host,
      port: httpUrl.port,
      path: '/exec/$containerId',
      queryParameters: queryParams,
    );

    return WebSocketChannel.connect(wsUri);
  }
}
