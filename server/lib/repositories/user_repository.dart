import '../db_connection.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserRepository {
  Future<Map<String, dynamic>?> login(String username, String plainPassword) async {
    // Generate SHA-256 hash
    final bytes = utf8.encode(plainPassword);
    final digest = sha256.convert(bytes);
    final passwordHash = digest.toString();

    final pool = await DBConnection.getPool();
    final result = await pool.execute(
      'SELECT id, username, role, full_name FROM users WHERE username = :username AND password_hash = :hash',
      {'username': username, 'hash': passwordHash},
    );

    if (result.rows.isNotEmpty) {
      return result.rows.first.assoc();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> findAll() async {
    final pool = await DBConnection.getPool();
    final result = await pool.execute('SELECT id, username, role, full_name, created_at FROM users ORDER BY full_name');
    return result.rows.map((row) => row.assoc()).toList();
  }

  Future<Map<String, dynamic>?> findById(int id) async {
    final pool = await DBConnection.getPool();
    final result = await pool.execute('SELECT id, username, role, full_name FROM users WHERE id = :id', {'id': id});
    if (result.rows.isNotEmpty) {
      return result.rows.first.assoc();
    }
    return null;
  }

  Future<int> save(Map<String, dynamic> user) async {
    final bytes = utf8.encode(user['password']);
    final passwordHash = sha256.convert(bytes).toString();

    final pool = await DBConnection.getPool();
    final result = await pool.execute(
      'INSERT INTO users (username, password_hash, role, full_name) VALUES (:username, :hash, :role, :fullName)',
      {
        'username': user['username'],
        'hash': passwordHash,
        'role': user['role'],
        'fullName': user['full_name'],
      },
    );
    return result.lastInsertID.toInt();
  }

  Future<void> update(int id, Map<String, dynamic> user) async {
    final pool = await DBConnection.getPool();
    
    if (user['password'] != null && user['password'].toString().isNotEmpty) {
      final bytes = utf8.encode(user['password']);
      final passwordHash = sha256.convert(bytes).toString();
      
      await pool.execute(
        'UPDATE users SET username=:username, password_hash=:hash, role=:role, full_name=:fullName WHERE id=:id',
        {
          'username': user['username'],
          'hash': passwordHash,
          'role': user['role'],
          'fullName': user['full_name'],
          'id': id,
        },
      );
    } else {
      await pool.execute(
        'UPDATE users SET username=:username, role=:role, full_name=:fullName WHERE id=:id',
        {
          'username': user['username'],
          'role': user['role'],
          'fullName': user['full_name'],
          'id': id,
        },
      );
    }
  }

  Future<void> deleteById(int id) async {
    final pool = await DBConnection.getPool();
    await pool.execute('DELETE FROM users WHERE id = :id', {'id': id});
  }
}
