import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/connection_config.dart';
import '../models/compose_project.dart';
import 'docker_service.dart';

class ComposeService {
  static const String _logPrefix = 'ComposeService';

  static Future<List<ComposeProject>?> getProjects(ConnectionConfig config) async {
    try {
      final response = await DockerService.makeRequest(config, '/compose/projects');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => ComposeProject.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        developer.log('$_logPrefix: Failed to fetch compose projects - Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error fetching compose projects: $e');
      return null;
    }
  }

  static Future<bool> registerProject(ConnectionConfig config, String name, String workingDir, List<String> configFiles) async {
    try {
      final protocol = config.useTls ? 'https://' : 'http://';
      final uri = Uri.parse('$protocol${config.uri}/compose/register');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (config.authType == AuthType.basic && config.token != null)
            'Authorization': 'Bearer ${config.token}',
        },
        body: json.encode({
          'name': name,
          'working_dir': workingDir,
          'config_files': configFiles,
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        developer.log('$_logPrefix: Failed to register compose project - Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error registering compose project: $e');
      return false;
    }
  }

  static Future<bool> unregisterProject(ConnectionConfig config, String name) async {
    try {
      final protocol = config.useTls ? 'https://' : 'http://';
      final uri = Uri.parse('$protocol${config.uri}/compose/register/$name');
      
      final response = await http.delete(
        uri,
        headers: {
          if (config.authType == AuthType.basic && config.token != null)
            'Authorization': 'Bearer ${config.token}',
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        developer.log('$_logPrefix: Failed to unregister compose project - Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      developer.log('$_logPrefix: Error unregistering compose project: $e');
      return false;
    }
  }


  /// Runs a docker compose command on the server and returns the raw HTTP response.
  /// The response acts as an event stream (JSON lines).
  static Future<http.StreamedResponse> runCommandStream(
    ConnectionConfig config,
    String project,
    String workingDir,
    String command, {
    String? service,
  }) async {
    final protocol = config.useTls ? 'https://' : 'http://';
    final uri = Uri.parse('$protocol${config.uri}/compose/command');
    
    final request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/json';
    
    if (config.authType == AuthType.basic && config.token != null) {
      request.headers['Authorization'] = 'Bearer ${config.token}';
    }

    final body = {
      'project': project,
      'working_dir': workingDir,
      'command': command,
      if (service != null && service.isNotEmpty) 'service': service,
    };
    
    request.body = json.encode(body);
    developer.log('$_logPrefix: Streaming compose command to $uri');
    
    // Create client to stream the response
    final client = http.Client();
    final response = await client.send(request);
    return response;
  }
}
