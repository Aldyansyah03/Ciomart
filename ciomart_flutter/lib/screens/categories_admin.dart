import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';

class CategoriesAdminScreen extends StatefulWidget {
  const CategoriesAdminScreen({super.key});

  @override
  State<CategoriesAdminScreen> createState() => _CategoriesAdminScreenState();
}

class _CategoriesAdminScreenState extends State<CategoriesAdminScreen> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.get('/categories') as List;
      setState(() {
        _categories = data.map((json) => Category.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat kategori: $e', isError: true);
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

  Future<void> _deleteCategory(int id) async {
    try {
      await _apiService.delete('/categories/$id');
      _showSnackBar('Kategori berhasil dihapus');
      _loadCategories();
    } catch (e) {
      _showSnackBar('Gagal menghapus kategori: $e', isError: true);
    }
  }

  void _showCategoryDialog([Category? category]) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(text: category?.description ?? '');
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? '✏️ Edit Kategori' : '➕ Tambah Kategori',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Kategori', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Nama Kategori (contoh: Snack)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Deskripsi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Deskripsi singkat kategori...',
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
                final name = nameController.text.trim();
                final desc = descController.text.trim();

                if (name.isEmpty) {
                  _showSnackBar('Nama kategori tidak boleh kosong', isError: true);
                  return;
                }

                Navigator.pop(context);
                final payload = {
                  'name': name,
                  'description': desc,
                };

                try {
                  if (isEdit) {
                    await _apiService.put('/categories/${category.id}', payload);
                    _showSnackBar('Kategori berhasil diperbarui');
                  } else {
                    await _apiService.post('/categories', payload);
                    _showSnackBar('Kategori berhasil ditambahkan');
                  }
                  _loadCategories();
                } catch (e) {
                  _showSnackBar('Gagal menyimpan kategori: $e', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandOrange, foregroundColor: Colors.white),
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
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
              const Expanded(child: AppHeader(title: 'Kelola Kategori')),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🏷️', style: TextStyle(fontSize: 60)),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada kategori',
                              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : isMobile
                        ? ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: AppColors.cardBg,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 1,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(cat.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  subtitle: cat.description != null && cat.description!.isNotEmpty
                                      ? Text(cat.description!, style: GoogleFonts.inter(color: AppColors.textSecondary))
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showCategoryDialog(cat),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: AppColors.danger),
                                        onPressed: () => _confirmDelete(cat),
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
                                    DataColumn(label: Text('ID', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Nama Kategori', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Deskripsi', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Aksi', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: _categories.map((cat) {
                                    return DataRow(cells: [
                                      DataCell(Text('${cat.id}')),
                                      DataCell(Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(cat.description ?? '-')),
                                      DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showCategoryDialog(cat),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: AppColors.danger),
                                            onPressed: () => _confirmDelete(cat),
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

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text('⚠️ Hapus Kategori'),
          content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (category.id != null) {
                  _deleteCategory(category.id!);
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
