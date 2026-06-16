import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';
import '../widgets/stat_card.dart';

class ReportsAdminScreen extends StatefulWidget {
  const ReportsAdminScreen({super.key});

  @override
  State<ReportsAdminScreen> createState() => _ReportsAdminScreenState();
}

class _ReportsAdminScreenState extends State<ReportsAdminScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _sales = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      final salesData = await _apiService.get('/sales') as List;
      final statsData = await _apiService.get('/dashboard/stats') as Map<String, dynamic>;
      
      setState(() {
        _sales = List<Map<String, dynamic>>.from(salesData);
        _stats = statsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat laporan: $e', isError: true);
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

  Future<void> _showSaleDetails(Map<String, dynamic> saleSummary) async {
    final id = saleSummary['id'];
    
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: AppColors.cardBg,
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Memuat rincian transaksi...'),
            ],
          ),
        );
      },
    );

    try {
      final saleDetails = await _apiService.get('/sales/$id') as Map<String, dynamic>;
      Navigator.pop(context); // Close loading dialog
      
      _showReceiptDialog(saleDetails);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showSnackBar('Gagal memuat rincian transaksi: $e', isError: true);
    }
  }

  void _showReceiptDialog(Map<String, dynamic> saleDetails) {
    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final sale = saleDetails['sale'] as Map<String, dynamic>;
    final items = saleDetails['items'] as List;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              const Text('🏪 CIOMART', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text('Nota Penjualan #${sale['sale_number']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text('Tanggal: ${sale['sale_date']}', style: const TextStyle(fontSize: 12)),
                  Text('Kasir ID: ${sale['cashier_id']}', style: const TextStyle(fontSize: 12)),
                  const Divider(),
                  const Text('ITEM BELANJA:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...items.map((item) {
                    final qty = item['quantity'];
                    final price = double.tryParse(item['product_price'].toString()) ?? 0.0;
                    final subtotal = double.tryParse(item['subtotal'].toString()) ?? 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['product_name']} (x$qty)', 
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(currencyFormatter.format(subtotal), style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  _buildReceiptRow('Subtotal', double.tryParse(sale['subtotal'].toString()) ?? 0.0, currencyFormatter),
                  if (sale['discount_amount'] != null && (double.tryParse(sale['discount_amount'].toString()) ?? 0.0) > 0)
                    _buildReceiptRow('Diskon', -(double.tryParse(sale['discount_amount'].toString()) ?? 0.0), currencyFormatter, color: AppColors.danger),
                  _buildReceiptRow('PPN (10%)', double.tryParse(sale['tax_amount'].toString()) ?? 0.0, currencyFormatter),
                  const Divider(),
                  _buildReceiptRow('TOTAL', double.tryParse(sale['total'].toString()) ?? 0.0, currencyFormatter, isBold: true),
                  _buildReceiptRow('TUNAI', double.tryParse(sale['cash_paid'].toString()) ?? 0.0, currencyFormatter),
                  _buildReceiptRow('KEMBALIAN', double.tryParse(sale['cash_change'].toString()) ?? 0.0, currencyFormatter, color: Colors.green),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandOrange, foregroundColor: Colors.white),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, double value, NumberFormat formatter, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          Text(
            formatter.format(value), 
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
              fontSize: 13,
              color: color,
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

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
              const Expanded(child: AppHeader(title: 'Laporan Penjualan')),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Stats Overview
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                        child: GridView.count(
                          crossAxisCount: isMobile ? 2 : 4,
                          crossAxisSpacing: isMobile ? 12 : 24,
                          mainAxisSpacing: isMobile ? 12 : 24,
                          shrinkWrap: true,
                          childAspectRatio: isMobile ? 1.05 : 1.5,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            StatCard(
                              title: 'Transaksi Hari Ini',
                              value: '${_stats['todaySales'] ?? 0}',
                              icon: '📈',
                            ),
                            StatCard(
                              title: 'Pendapatan Hari Ini',
                              value: currencyFormatter.format(_stats['todayRevenue'] ?? 0),
                              icon: '💰',
                              themeColor: AppColors.brandOrange,
                            ),
                            StatCard(
                              title: 'Total Transaksi (Semua)',
                              value: '${_sales.length}',
                              icon: '🛍️',
                              themeColor: AppColors.success,
                            ),
                            StatCard(
                              title: 'Total Omzet (Semua)',
                              value: currencyFormatter.format(
                                _sales.fold<double>(0.0, (sum, sale) => sum + (double.tryParse(sale['total']?.toString() ?? '0') ?? 0.0))
                              ),
                              icon: '💵',
                              themeColor: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                      
                      // Transactions Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '📜 Riwayat Transaksi Penjualan',
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      // Sales History List
                      Expanded(
                        child: _sales.isEmpty
                            ? Center(
                                child: Text(
                                  'Belum ada transaksi penjualan yang tercatat.',
                                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                                ),
                              )
                            : isMobile
                                ? ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _sales.length,
                                    itemBuilder: (context, index) {
                                      final sale = _sales[index];
                                      final total = double.tryParse(sale['total'].toString()) ?? 0.0;
                                      
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        color: AppColors.cardBg,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 1,
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('#${sale['sale_number']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                              Text(currencyFormatter.format(total), style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.brandOrange)),
                                            ],
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 6.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Tanggal: ${sale['sale_date']}', style: const TextStyle(fontSize: 11)),
                                                Text('Kasir ID: ${sale['cashier_id']}', style: const TextStyle(fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          onTap: () => _showSaleDetails(sale),
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
                                            DataColumn(label: Text('Nota #', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Tanggal', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Kasir ID', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Subtotal', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Diskon', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Total', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Aksi', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                          ],
                                          rows: _sales.map((sale) {
                                            final subtotal = double.tryParse(sale['subtotal'].toString()) ?? 0.0;
                                            final discount = double.tryParse(sale['discount_amount'].toString()) ?? 0.0;
                                            final total = double.tryParse(sale['total'].toString()) ?? 0.0;

                                            return DataRow(cells: [
                                              DataCell(Text('${sale['sale_number']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                              DataCell(Text('${sale['sale_date']}')),
                                              DataCell(Text('User #${sale['cashier_id']}')),
                                              DataCell(Text(currencyFormatter.format(subtotal))),
                                              DataCell(Text(currencyFormatter.format(discount), style: TextStyle(color: discount > 0 ? AppColors.danger : Colors.black))),
                                              DataCell(Text(currencyFormatter.format(total), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandOrange))),
                                              DataCell(ElevatedButton(
                                                onPressed: () => _showSaleDetails(sale),
                                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandOrange, foregroundColor: Colors.white),
                                                child: const Text('Detail'),
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
          ),
        ],
      ),
    );
  }
}
