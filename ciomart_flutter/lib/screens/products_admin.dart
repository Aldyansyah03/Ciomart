import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';

class ProductsAdminScreen extends StatefulWidget {
  const ProductsAdminScreen({super.key});

  @override
  State<ProductsAdminScreen> createState() => _ProductsAdminScreenState();
}

class _ProductsAdminScreenState extends State<ProductsAdminScreen> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final productsData = await _apiService.get('/products') as List;
      final categoriesData = await _apiService.get('/categories') as List;
      
      setState(() {
        _products = productsData.map((json) => Product.fromJson(json)).toList();
        _categories = categoriesData.map((json) => Category.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.brandOrange,
      ),
    );
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await _apiService.delete('/products/$id');
      _showSnackBar('Produk berhasil dihapus');
      _loadData();
    } catch (e) {
      _showSnackBar('Gagal menghapus produk: $e', isError: true);
    }
  }

  void _showProductDialog([Product? product]) {
    final skuController = TextEditingController(text: product?.sku ?? '');
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final discountController = TextEditingController(text: product?.discountPercentage.toString() ?? '0');
    
    int? selectedCategoryId = product?.categoryId;
    if (selectedCategoryId == null && _categories.isNotEmpty) {
      selectedCategoryId = _categories.first.id;
    }
    
    final isEdit = product != null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit ? '✏️ Edit Produk' : '➕ Tambah Produk',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SKU / Kode Barang', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: skuController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan SKU (contoh: SKU001)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Nama Produk', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Nama Produk (contoh: Kopi Kapal Api)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Kategori', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    _categories.isEmpty
                        ? const Text('Belum ada kategori. Buat kategori terlebih dahulu.')
                        : DropdownButtonFormField<int>(
                            value: selectedCategoryId,
                            items: _categories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(cat.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                selectedCategoryId = val;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Harga (Rp)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '3500',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stok', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: stockController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '100',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Diskon (%)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0 - 100',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final sku = skuController.text.trim();
                    final name = nameController.text.trim();
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    final stock = int.tryParse(stockController.text) ?? 0;
                    final discount = int.tryParse(discountController.text) ?? 0;

                    if (sku.isEmpty || name.isEmpty || selectedCategoryId == null) {
                      _showSnackBar('SKU, Nama, dan Kategori harus diisi', isError: true);
                      return;
                    }
                    if (price <= 0 || stock < 0 || discount < 0 || discount > 100) {
                      _showSnackBar('Harga/Stok/Diskon tidak valid', isError: true);
                      return;
                    }

                    Navigator.pop(context);
                    final payload = {
                      'sku': sku,
                      'name': name,
                      'price': price,
                      'stock': stock,
                      'category_id': selectedCategoryId,
                      'discount_percentage': discount,
                    };

                    try {
                      if (isEdit) {
                        await _apiService.put('/products/${product.id}', payload);
                        _showSnackBar('Produk berhasil diperbarui');
                      } else {
                        await _apiService.post('/products', payload);
                        _showSnackBar('Produk berhasil ditambahkan');
                      }
                      _loadData();
                    } catch (e) {
                      _showSnackBar('Gagal menyimpan produk: $e', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandOrange, foregroundColor: Colors.white),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_categories.isEmpty) {
            _showSnackBar('Buat kategori terlebih dahulu sebelum menambah produk!', isError: true);
          } else {
            _showProductDialog();
          }
        },
        backgroundColor: AppColors.brandOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(child: AppHeader(title: 'Kelola Produk')),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📦', style: TextStyle(fontSize: 60)),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada produk',
                              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : isMobile
                        ? ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final prod = _products[index];
                              final finalPrice = prod.getPriceAfterDiscount();
                              final hasDiscount = prod.discountPercentage > 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: AppColors.cardBg,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.brandOrange.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(prod.sku, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandOrange)),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(prod.category?.name ?? 'Kategori', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(prod.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            if (hasDiscount) ...[
                                              Row(
                                                children: [
                                                  Text(currencyFormatter.format(prod.price), style: GoogleFonts.inter(fontSize: 12, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(4)),
                                                    child: Text('${prod.discountPercentage}% OFF', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                            ],
                                            Text(currencyFormatter.format(finalPrice), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.brandOrange)),
                                            const SizedBox(height: 6),
                                            Text('Stok: ${prod.stock}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: prod.stock < 20 ? AppColors.danger : Colors.green)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showProductDialog(prod),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: AppColors.danger),
                                            onPressed: () => _confirmDelete(prod),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(32),
                            child: Card(
                              color: AppColors.cardBg,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                child: DataTable(
                                  columns: [
                                    DataColumn(label: Text('SKU', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Nama Produk', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Kategori', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Harga Normal', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Diskon', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Harga Bersih', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Stok', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Aksi', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: _products.map((prod) {
                                    final finalPrice = prod.getPriceAfterDiscount();
                                    return DataRow(cells: [
                                      DataCell(Text(prod.sku, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(prod.name)),
                                      DataCell(Text(prod.category?.name ?? '-')),
                                      DataCell(Text(currencyFormatter.format(prod.price))),
                                      DataCell(Text('${prod.discountPercentage}%')),
                                      DataCell(Text(currencyFormatter.format(finalPrice), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandOrange))),
                                      DataCell(Text('${prod.stock}', style: TextStyle(fontWeight: FontWeight.bold, color: prod.stock < 20 ? AppColors.danger : Colors.black))),
                                      DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showProductDialog(prod),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: AppColors.danger),
                                            onPressed: () => _confirmDelete(prod),
                                          ),
                                        ],
                                      )),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text('⚠️ Hapus Produk'),
          content: Text('Apakah Anda yakin ingin menghapus produk "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (product.id != null) {
                  _deleteProduct(product.id!);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
