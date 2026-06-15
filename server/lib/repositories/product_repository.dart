import '../db_connection.dart';

class ProductRepository {
  Future<List<Map<String, dynamic>>> findAll() async {
    final pool = await DBConnection.getPool();
    final sql = '''
      SELECT p.*, c.name as category_name 
      FROM products p 
      LEFT JOIN categories c ON p.category_id = c.id 
      ORDER BY p.name
    ''';
    final result = await pool.execute(sql);
    return result.rows.map((row) => row.assoc()).toList();
  }

  Future<List<Map<String, dynamic>>> findByCategory(int categoryId) async {
    final pool = await DBConnection.getPool();
    final sql = '''
      SELECT p.*, c.name as category_name 
      FROM products p 
      LEFT JOIN categories c ON p.category_id = c.id 
      WHERE p.category_id = :catId
      ORDER BY p.name
    ''';
    final result = await pool.execute(sql, {'catId': categoryId});
    return result.rows.map((row) => row.assoc()).toList();
  }

  Future<Map<String, dynamic>?> findById(int id) async {
    final pool = await DBConnection.getPool();
    final sql = '''
      SELECT p.*, c.name as category_name 
      FROM products p 
      LEFT JOIN categories c ON p.category_id = c.id 
      WHERE p.id = :id
    ''';
    final result = await pool.execute(sql, {'id': id});
    if (result.rows.isNotEmpty) {
      return result.rows.first.assoc();
    }
    return null;
  }

  Future<int> save(Map<String, dynamic> product) async {
    final pool = await DBConnection.getPool();
    final sql = '''
      INSERT INTO products (sku, name, price, stock, category_id, discount_percentage) 
      VALUES (:sku, :name, :price, :stock, :categoryId, :discount)
    ''';
    final result = await pool.execute(sql, {
      'sku': product['sku'],
      'name': product['name'],
      'price': product['price'],
      'stock': product['stock'],
      'categoryId': product['category_id'],
      'discount': product['discount_percentage'],
    });
    return result.lastInsertID.toInt();
  }

  Future<void> update(int id, Map<String, dynamic> product) async {
    final pool = await DBConnection.getPool();
    final sql = '''
      UPDATE products 
      SET sku=:sku, name=:name, price=:price, stock=:stock, category_id=:categoryId, discount_percentage=:discount 
      WHERE id=:id
    ''';
    await pool.execute(sql, {
      'sku': product['sku'],
      'name': product['name'],
      'price': product['price'],
      'stock': product['stock'],
      'categoryId': product['category_id'],
      'discount': product['discount_percentage'],
      'id': id,
    });
  }

  Future<void> updateStock(int productId, int quantity) async {
    final pool = await DBConnection.getPool();
    await pool.execute(
      'UPDATE products SET stock = stock - :qty WHERE id = :id',
      {'qty': quantity, 'id': productId},
    );
  }

  Future<void> deleteById(int id) async {
    final pool = await DBConnection.getPool();
    await pool.execute('DELETE FROM products WHERE id = :id', {'id': id});
  }
}
