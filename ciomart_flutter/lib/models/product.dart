import 'category.dart';

class Product {
  final int? id;
  final String sku;
  final String name;
  final double price;
  int stock;
  final int categoryId;
  final Category? category;
  final int discountPercentage;

  Product({
    this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.category,
    this.discountPercentage = 0,
  });

  // Business Logic Methods
  double getPriceAfterDiscount() {
    if (discountPercentage > 0) {
      return price * (100 - discountPercentage) / 100;
    }
    return price;
  }

  bool isAvailable(int quantity) {
    return stock >= quantity;
  }

  void reduceStock(int quantity) {
    if (isAvailable(quantity)) {
      stock -= quantity;
    } else {
      throw Exception('Stok tidak cukup');
    }
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      sku: json['sku'],
      name: json['name'],
      price: json['price'] is num ? (json['price'] as num).toDouble() : double.parse(json['price'].toString()),
      stock: json['stock'] is int ? json['stock'] : int.parse(json['stock'].toString()),
      categoryId: json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()),
      category: json['category_name'] != null 
          ? Category(
              id: json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()), 
              name: json['category_name']) 
          : null,
      discountPercentage: json['discount_percentage'] is int 
          ? json['discount_percentage'] 
          : int.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sku': sku,
      'name': name,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'discount_percentage': discountPercentage,
    };
  }
}
