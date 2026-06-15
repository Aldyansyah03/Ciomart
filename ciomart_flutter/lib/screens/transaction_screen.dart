import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionViewModel()..loadData(),
      child: const _TransactionScreenView(),
    );
  }
}

class _TransactionScreenView extends StatefulWidget {
  const _TransactionScreenView();

  @override
  State<_TransactionScreenView> createState() => _TransactionScreenViewState();
}

class _TransactionScreenViewState extends State<_TransactionScreenView> {
  final TextEditingController _cashController = TextEditingController();

  void _processCheckout() async {
    final viewModel = context.read<TransactionViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    
    final cashPaid = double.tryParse(_cashController.text) ?? 0;
    final cashier = authViewModel.currentUser;
    
    if (cashier == null) return;

    final sale = await viewModel.processCheckout(cashier, cashPaid);
    
    if (!mounted) return;
    
    if (sale != null) {
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
                viewModel.clearCart();
                _cashController.clear();
                viewModel.loadData();
                Navigator.of(context).pop();
              },
              child: const Text('OK & Transaksi Baru'),
            )
          ],
        ),
      );
    } else if (viewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.error!), backgroundColor: AppColors.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, _) {
          
          if (viewModel.error != null && !viewModel.isProcessing) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               if (mounted && viewModel.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.error!), backgroundColor: AppColors.danger));
                  viewModel.error = null;
               }
             });
          }

          return Column(
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
                child: viewModel.isLoading 
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
                                      value: viewModel.selectedCategoryId,
                                      hint: const Text('Semua Kategori'),
                                      items: [
                                        const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                                        ...viewModel.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                                      ],
                                      onChanged: (val) => viewModel.filterByCategory(val),
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
                                    itemCount: viewModel.filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = viewModel.filteredProducts[index];
                                      return InkWell(
                                        onTap: () => viewModel.addToCart(product),
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
                                  child: viewModel.cart.items.isEmpty 
                                    ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('🛒', style: TextStyle(fontSize: 40)), Text('Keranjang kosong')]))
                                    : ListView.builder(
                                        itemCount: viewModel.cart.items.length,
                                        itemBuilder: (context, index) {
                                          final item = viewModel.cart.items[index];
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
                                                      onPressed: () => viewModel.updateQuantity(item.product, item.quantity - 1),
                                                    ),
                                                    Text('${item.quantity}'),
                                                    IconButton(
                                                      icon: const Icon(Icons.add_circle_outline, color: AppColors.brandOrange),
                                                      onPressed: () => viewModel.updateQuantity(item.product, item.quantity + 1),
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
                                if (viewModel.cart.items.isNotEmpty) ...[
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Subtotal:'),
                                      Text(currencyFormat.format(viewModel.cart.getTotal())),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('PPN 10%:'),
                                      Text(currencyFormat.format(viewModel.cart.getTotal() * AppConstants.taxRate)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.danger)),
                                      Text(currencyFormat.format(viewModel.cart.getTotal() * (1 + AppConstants.taxRate)), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.danger)),
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
                                      onPressed: viewModel.isProcessing || (double.tryParse(_cashController.text) ?? 0) < (viewModel.cart.getTotal() * (1 + AppConstants.taxRate)) ? null : _processCheckout,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.danger,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: viewModel.isProcessing 
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
          );
        }
      ),
    );
  }
}
