import '../db_connection.dart';

class SaleRepository {
  Future<List<Map<String, dynamic>>> findAll() async {
    final pool = await DBConnection.getPool();
    final sql = '''
      SELECT s.*, u.username, u.full_name as cashier_name 
      FROM sales s 
      LEFT JOIN users u ON s.cashier_id = u.id 
      ORDER BY s.sale_date DESC
    ''';
    final result = await pool.execute(sql);
    return result.rows.map((row) => row.assoc()).toList();
  }

  Future<Map<String, dynamic>?> findById(int id) async {
    final pool = await DBConnection.getPool();
    
    // Get sale record
    final sqlSale = '''
      SELECT s.*, u.username, u.full_name as cashier_name 
      FROM sales s 
      LEFT JOIN users u ON s.cashier_id = u.id 
      WHERE s.id = :id
    ''';
    final resultSale = await pool.execute(sqlSale, {'id': id});
    
    if (resultSale.rows.isEmpty) return null;
    
    var sale = Map<String, dynamic>.from(resultSale.rows.first.assoc());
    
    // Get sale items
    final sqlItems = '''
      SELECT si.*, p.sku 
      FROM sale_items si 
      LEFT JOIN products p ON si.product_id = p.id 
      WHERE si.sale_id = :id
    ''';
    final resultItems = await pool.execute(sqlItems, {'id': id});
    
    sale['items'] = resultItems.rows.map((row) => row.assoc()).toList();
    
    return sale;
  }

  Future<int> saveSale(Map<String, dynamic> saleData, List<Map<String, dynamic>> items) async {
    final pool = await DBConnection.getPool();
    
    return await pool.transactional((conn) async {
      // 1. Insert sale
      final sqlSale = '''
        INSERT INTO sales (sale_number, cashier_id, subtotal, discount_type, discount_amount, tax_amount, total, cash_paid, cash_change) 
        VALUES (:saleNum, :cashierId, :subtotal, :discType, :discAmt, :taxAmt, :total, :cashPaid, :cashChange)
      ''';
      
      final result = await conn.execute(sqlSale, {
        'saleNum': saleData['sale_number'],
        'cashierId': saleData['cashier_id'],
        'subtotal': saleData['subtotal'],
        'discType': saleData['discount_type'],
        'discAmt': saleData['discount_amount'],
        'taxAmt': saleData['tax_amount'],
        'total': saleData['total'],
        'cashPaid': saleData['cash_paid'],
        'cashChange': saleData['cash_change'],
      });
      
      final saleId = result.lastInsertID.toInt();
      
      // 2. Insert items and update stock
      final sqlItem = '''
        INSERT INTO sale_items (sale_id, product_id, product_name, product_price, quantity, subtotal) 
        VALUES (:saleId, :productId, :productName, :productPrice, :qty, :subtotal)
      ''';
      
      final sqlStock = 'UPDATE products SET stock = stock - :qty WHERE id = :productId';
      
      for (var item in items) {
        await conn.execute(sqlItem, {
          'saleId': saleId,
          'productId': item['product_id'],
          'productName': item['product_name'],
          'productPrice': item['product_price'],
          'qty': item['quantity'],
          'subtotal': item['subtotal'],
        });
        
        await conn.execute(sqlStock, {
          'qty': item['quantity'],
          'productId': item['product_id'],
        });
      }
      
      return saleId;
    });
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final pool = await DBConnection.getPool();
    
    // Total products
    final res1 = await pool.execute('SELECT COUNT(*) as total FROM products');
    final totalProducts = int.parse(res1.rows.first.assoc()['total']!);
    
    // Total categories
    final res2 = await pool.execute('SELECT COUNT(*) as total FROM categories');
    final totalCategories = int.parse(res2.rows.first.assoc()['total']!);
    
    // Today's sales
    final res3 = await pool.execute('SELECT COUNT(*) as total, SUM(total) as revenue FROM sales WHERE DATE(sale_date) = CURDATE()');
    final todaySalesRow = res3.rows.first.assoc();
    final todaySales = int.parse(todaySalesRow['total'] ?? '0');
    final todayRevenue = double.parse(todaySalesRow['revenue'] ?? '0');
    
    // Low stock
    final res4 = await pool.execute('SELECT COUNT(*) as total FROM products WHERE stock < 20');
    final lowStock = int.parse(res4.rows.first.assoc()['total']!);
    
    return {
      'totalProducts': totalProducts,
      'totalCategories': totalCategories,
      'todaySales': todaySales,
      'todayRevenue': todayRevenue,
      'lowStock': lowStock,
    };
  }
}
