import 'dart:convert';

import 'package:docker_controller/models/connection_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef JsonMap = Map<String, dynamic>;

class ConnectionStorageService {
  const ConnectionStorageService(this._storage);

  final FlutterSecureStorage _storage;
  static const _key = 'connectionConfig';
  static const _historyKey = 'connectionHistory';

  Future<void> saveConnectionConfig(ConnectionConfig config) async {
    final json = jsonEncode(config.toJson());
    await _storage.write(key: _key, value: json);
  }

  Future<ConnectionConfig?> loadConnectionConfig() async {
    final value = await _storage.read(key: _key);
    if (value == null) {
      return null;
    }
    try {
      final map = jsonDecode(value) as Map<String, dynamic>;
      return ConnectionConfig.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteConnectionConfig() async {
    await _storage.delete(key: _key);
  }

  Future<void> saveConnectionHistory(List<String> history) async {
    final json = jsonEncode(history);
    await _storage.write(key: _historyKey, value: json);
  }

  Future<List<String>> loadConnectionHistory() async {
    final value = await _storage.read(key: _historyKey);
    if (value == null) {
      return [];
    }
    try {
      final list = jsonDecode(value) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteConnectionHistory() async {
    await _storage.delete(key: _historyKey);
  }
}
