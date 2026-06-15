import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';
import '../widgets/stat_card.dart';
import 'products_admin.dart';
import 'categories_admin.dart';
import 'users_admin.dart';
import 'reports_admin.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _apiService.get('/dashboard/stats');
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat statistik: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(title: 'Admin Dashboard'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Dashboard Admin',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selamat datang di sistem manajemen CIOMART',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      shrinkWrap: true,
                      childAspectRatio: 1.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          title: 'Total Produk',
                          value: '${_stats['totalProducts'] ?? 0}',
                          icon: '📦',
                        ),
                        StatCard(
                          title: 'Kategori',
                          value: '${_stats['totalCategories'] ?? 0}',
                          icon: '🏷️',
                          themeColor: AppColors.success,
                        ),
                        StatCard(
                          title: 'Penjualan Hari Ini (${_stats['todaySales'] ?? 0} transaksi)',
                          value: NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_stats['todayRevenue'] ?? 0),
                          icon: '💰',
                        ),
                        StatCard(
                          title: 'Stok Menipis (< 20)',
                          value: '${_stats['lowStock'] ?? 0}',
                          icon: '⚠️',
                          themeColor: (_stats['lowStock'] ?? 0) > 0 ? AppColors.danger : AppColors.success,
                        ),
                      ],
                    ),

                  const SizedBox(height: 48),

                  GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    shrinkWrap: true,
                    childAspectRatio: 1.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _MenuCard(
                        title: 'Kelola Produk',
                        description: 'Tambah, edit, dan hapus produk. Atur stok dan harga barang.',
                        icon: '📦',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsAdminScreen())),
                      ),
                      _MenuCard(
                        title: 'Kelola Kategori',
                        description: 'Manajemen kategori produk untuk pengelompokan barang.',
                        icon: '🏷️',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesAdminScreen())),
                      ),
                      _MenuCard(
                        title: 'Laporan Penjualan',
                        description: 'Lihat laporan penjualan harian, bulanan, dan statistik.',
                        icon: '📊',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsAdminScreen())),
                      ),
                      _MenuCard(
                        title: 'Kelola Pengguna',
                        description: 'Manajemen akun admin dan kasir dalam sistem.',
                        icon: '👥',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UsersAdminScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.brandYellow.withOpacity(0.28),
                      AppColors.brandOrange.withOpacity(0.14)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.brandOrange.withOpacity(0.18)),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
