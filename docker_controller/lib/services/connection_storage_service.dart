import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/connection_config.dart';

typedef JsonMap = Map<String, dynamic>;

class ConnectionStorageService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'connectionConfig';
  static const _historyKey = 'connectionHistory';

  static Future<void> saveConnectionConfig(ConnectionConfig config) async {
    final json = jsonEncode(config.toJson());
    await _storage.write(key: _key, value: json);
  }

  static Future<ConnectionConfig?> loadConnectionConfig() async {
    final value = await _storage.read(key: _key);
    if (value == null) return null;
    try {
      final map = jsonDecode(value) as Map<String, dynamic>;
      return ConnectionConfig.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteConnectionConfig() async {
    await _storage.delete(key: _key);
  }

  static Future<void> saveConnectionHistory(List<String> history) async {
    final json = jsonEncode(history);
    await _storage.write(key: _historyKey, value: json);
  }

  static Future<List<String>> loadConnectionHistory() async {
    final value = await _storage.read(key: _historyKey);
    if (value == null) return [];
    try {
      final list = jsonDecode(value) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> deleteConnectionHistory() async {
    await _storage.delete(key: _historyKey);
  }
}