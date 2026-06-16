import 'dart:io';
import 'package:mysql_client/mysql_client.dart';

class DBConnection {
  static MySQLConnectionPool? _pool;

  // Private constructor
  DBConnection._();

  static Future<MySQLConnectionPool> getPool() async {
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
    final port = int.tryParse(Platform.environment['DB_PORT'] ?? '') ?? 3306;
    final userName = Platform.environment['DB_USERNAME'] ?? 'root';
    final password = Platform.environment['DB_PASSWORD'] ?? '';
    final databaseName = Platform.environment['DB_DATABASE'] ?? 'tokoku';

    final secure = Platform.environment['DB_SECURE'] == 'true' || 
                   (host != '127.0.0.1' && host != 'localhost' && Platform.environment['DB_SECURE'] != 'false');

    _pool ??= MySQLConnectionPool(
      host: host,
      port: port,
      userName: userName,
      password: password,
      databaseName: databaseName,
      maxConnections: 10,
      secure: secure,
    );
    return _pool!;
  }

  static Future<void> close() async {
    if (_pool != null) {
      await _pool!.close();
      _pool = null;
    }
  }
}
