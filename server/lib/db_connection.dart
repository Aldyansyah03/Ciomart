import 'package:mysql_client/mysql_client.dart';

class DBConnection {
  static MySQLConnectionPool? _pool;

  // Private constructor
  DBConnection._();

  static Future<MySQLConnectionPool> getPool() async {
    _pool ??= MySQLConnectionPool(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '',
      databaseName: 'tokoku',
      maxConnections: 10,
      secure: false,
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
