import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/discount_policy.dart';
import '../models/no_discount.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/sale_service.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final ApiService _apiService = ApiService();
  final SaleService _saleService = SaleService();
  
  List<Product> _products = [];
  List<Category> _categories = [];
  int? _selectedCategoryId;
  
  final Cart _cart = Cart();
  final TextEditingController _cashController = TextEditingController();
  
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categoriesData = await _apiService.get('/categories');
      final productsData = await _apiService.get('/products');
      
      setState(() {
        _categories = (categoriesData as List).map((c) => Category.fromJson(c)).toList();
        _products = (productsData as List).map((p) => Product.fromJson(p)).where((p) => p.stock > 0).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedCategoryId == null) return _products;
    return _products.where((p) => p.categoryId == _selectedCategoryId).toList();
  }

  void _addToCart(Product product) {
    setState(() {
      try {
        _cart.addItem(product, 1);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger));
      }
    });
  }

  void _updateQuantity(Product product, int qty) {
    setState(() {
      _cart.updateQuantity(product, qty);
    });
  }

  void _processCheckout() async {
    if (_cart.items.isEmpty) return;
    
    final cashPaid = double.tryParse(_cashController.text) ?? 0;
    
    // Default no discount for transaction. Product discount is already in product.getPriceAfterDiscount()
    final discountPolicy = NoDiscount(); 
    
    final cashier = context.read<AuthService>().currentUser;
    if (cashier == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final sale = await _saleService.processCheckout(_cart, discountPolicy, cashier, cashPaid);
      
      if (!mounted) return;
      
      // Tampilkan dialog struk
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Transaksi Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No: ${sale.saleNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              Text('Total: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(sale.total)}'),
              Text('Tunai: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(sale.cashPaid)}'),
              Text('Kembalian: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(sale.cashChange)}', 
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _cart.clear();
                  _cashController.clear();
                  _loadData(); // reload stock
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK & Transaksi Baru'),
            )
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(child: AppHeader(title: 'Transaksi Penjualan')),
            ],
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kiri: Daftar Produk
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('📦 Pilih Produk', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger)),
                                const Spacer(),
                                DropdownButton<int?>(
                                  value: _selectedCategoryId,
                                  hint: const Text('Semua Kategori'),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                                    ..._categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                                  ],
                                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  return InkWell(
                                    onTap: () => _addToCart(product),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.cardBorder),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          Text(product.category?.name ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          const Spacer(),
                                          if (product.discountPercentage > 0) ...[
                                            Text(currencyFormat.format(product.price), style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                                            Row(
                                              children: [
                                                Text(currencyFormat.format(product.getPriceAfterDiscount()), style: const TextStyle(color: AppColors.brandOrange, fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                  decoration: BoxDecoration(color: AppColors.brandOrange, borderRadius: BorderRadius.circular(4)),
                                                  child: Text('${product.discountPercentage}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                )
                                              ],
                                            )
                                          ] else ...[
                                            Text(currencyFormat.format(product.price), style: const TextStyle(color: AppColors.brandOrange, fontWeight: FontWeight.bold)),
                                          ],
                                          const SizedBox(height: 4),
                                          Text('Stok: ${product.stock}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Kanan: Keranjang
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(left: BorderSide(color: AppColors.cardBorder)),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🛒 Keranjang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _cart.items.isEmpty 
                                ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('🛒', style: TextStyle(fontSize: 40)), Text('Keranjang kosong')]))
                                : ListView.builder(
                                    itemCount: _cart.items.length,
                                    itemBuilder: (context, index) {
                                      final item = _cart.items[index];
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.cardBorder),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  Text('@ ${currencyFormat.format(item.product.getPriceAfterDiscount())}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.brandOrange),
                                                  onPressed: () => _updateQuantity(item.product, item.quantity - 1),
                                                ),
                                                Text('${item.quantity}'),
                                                IconButton(
                                                  icon: const Icon(Icons.add_circle_outline, color: AppColors.brandOrange),
                                                  onPressed: () {
                                                    if (item.quantity < item.product.stock) {
                                                      _updateQuantity(item.product, item.quantity + 1);
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok tidak cukup')));
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(currencyFormat.format(item.getSubtotal()), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandOrange)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                            ),
                            if (_cart.items.isNotEmpty) ...[
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal:'),
                                  Text(currencyFormat.format(_cart.getTotal())),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('PPN 10%:'),
                                  Text(currencyFormat.format(_cart.getTotal() * AppConstants.taxRate)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.danger)),
                                  Text(currencyFormat.format(_cart.getTotal() * (1 + AppConstants.taxRate)), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.danger)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _cashController,
                                decoration: const InputDecoration(
                                  labelText: 'Uang Dibayar',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isProcessing || (double.tryParse(_cashController.text) ?? 0) < (_cart.getTotal() * (1 + AppConstants.taxRate)) ? null : _processCheckout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: _isProcessing 
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('💰 Proses Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
