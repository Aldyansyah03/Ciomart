import '../db_connection.dart';

class CategoryRepository {
  Future<List<Map<String, dynamic>>> findAll() async {
    final pool = await DBConnection.getPool();
    final result = await pool.execute('SELECT * FROM categories ORDER BY name');
    
    return result.rows.map((row) => row.assoc()).toList();
  }

  Future<Map<String, dynamic>?> findById(int id) async {
    final pool = await DBConnection.getPool();
    final result = await pool.execute(
      'SELECT * FROM categories WHERE id = :id',
      {'id': id},
    );
    
    if (result.rows.isNotEmpty) {
      return result.rows.first.assoc();
    }
    return null;
  }

  Future<int> save(Map<String, dynamic> category) async {
    final pool = await DBConnection.getPool();
    final result = await pool.execute(
      'INSERT INTO categories (name, description) VALUES (:name, :desc)',
      {
        'name': category['name'],
        'desc': category['description'],
      },
    );
    return result.lastInsertID.toInt();
  }

  Future<void> update(int id, Map<String, dynamic> category) async {
    final pool = await DBConnection.getPool();
    await pool.execute(
      'UPDATE categories SET name = :name, description = :desc WHERE id = :id',
      {
        'name': category['name'],
        'desc': category['description'],
        'id': id,
      },
    );
  }

  Future<void> deleteById(int id) async {
    final pool = await DBConnection.getPool();
    await pool.execute('DELETE FROM categories WHERE id = :id', {'id': id});
  }
}
