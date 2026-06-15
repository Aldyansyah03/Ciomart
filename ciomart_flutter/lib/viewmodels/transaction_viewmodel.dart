import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/no_discount.dart';
import '../models/sale.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/sale_service.dart';

class TransactionViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SaleService _saleService = SaleService();
  
  final Cart cart = Cart();
  List<Product> products = [];
  List<Category> categories = [];
  
  int? selectedCategoryId;
  bool isLoading = true;
  bool isProcessing = false;
  String? error;

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final categoriesData = await _apiService.get('/categories');
      final productsData = await _apiService.get('/products');
      
      categories = (categoriesData as List).map((c) => Category.fromJson(c)).toList();
      products = (productsData as List).map((p) => Product.fromJson(p)).where((p) => p.stock > 0).toList();
      isLoading = false;
    } catch (e) {
      isLoading = false;
      error = 'Gagal memuat data: $e';
    }
    notifyListeners();
  }

  void filterByCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    if (selectedCategoryId == null) return products;
    return products.where((p) => p.categoryId == selectedCategoryId).toList();
  }

  void addToCart(Product product) {
    try {
      cart.addItem(product, 1);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      error = null; // reset immediately
    }
  }

  void updateQuantity(Product product, int qty) {
    if (qty > product.stock) {
      error = 'Stok tidak cukup';
    } else {
      cart.updateQuantity(product, qty);
    }
    notifyListeners();
    error = null;
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  Future<Sale?> processCheckout(User cashier, double cashPaid) async {
    if (cart.items.isEmpty) return null;

    isProcessing = true;
    error = null;
    notifyListeners();

    try {
      final discountPolicy = NoDiscount(); 
      final sale = await _saleService.processCheckout(cart, discountPolicy, cashier, cashPaid);
      isProcessing = false;
      notifyListeners();
      return sale;
    } catch (e) {
      error = e.toString();
      isProcessing = false;
      notifyListeners();
      return null;
    }
  }
}
