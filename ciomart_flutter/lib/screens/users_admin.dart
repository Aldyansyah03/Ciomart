import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../widgets/app_header.dart';

class UsersAdminScreen extends StatefulWidget {
  const UsersAdminScreen({super.key});

  @override
  State<UsersAdminScreen> createState() => _UsersAdminScreenState();
}

class _UsersAdminScreenState extends State<UsersAdminScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.get('/users') as List;
      setState(() {
        _users = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat pengguna: $e', isError: true);
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

  Future<void> _deleteUser(int id) async {
    try {
      await _apiService.delete('/users/$id');
      _showSnackBar('Pengguna berhasil dihapus');
      _loadUsers();
    } catch (e) {
      _showSnackBar('Gagal menghapus pengguna: $e', isError: true);
    }
  }

  void _showUserDialog([Map<String, dynamic>? user]) {
    final nameController = TextEditingController(text: user?.containsKey('full_name') == true ? user!['full_name'] : '');
    final usernameController = TextEditingController(text: user?.containsKey('username') == true ? user!['username'] : '');
    final passwordController = TextEditingController();
    
    String selectedRole = user?.containsKey('role') == true ? user!['role'] : 'CASHIER';
    final isEdit = user != null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit ? '✏️ Edit Pengguna' : '➕ Tambah Pengguna',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama Lengkap', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Nama Lengkap (contoh: Ahmad Dani)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Username', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username login...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEdit ? 'Password Baru (kosongkan jika tidak diubah)' : 'Password', 
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password login...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Peran (Role)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: const [
                        DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                        DropdownMenuItem(value: 'CASHIER', child: Text('CASHIER')),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedRole = val ?? 'CASHIER';
                        });
                      },
                      decoration: InputDecoration(
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
                    final username = usernameController.text.trim();
                    final password = passwordController.text.trim();

                    if (name.isEmpty || username.isEmpty) {
                      _showSnackBar('Nama lengkap dan username tidak boleh kosong', isError: true);
                      return;
                    }
                    if (!isEdit && password.isEmpty) {
                      _showSnackBar('Password tidak boleh kosong untuk pengguna baru', isError: true);
                      return;
                    }

                    Navigator.pop(context);
                    final payload = {
                      'full_name': name,
                      'username': username,
                      'role': selectedRole,
                      if (password.isNotEmpty) 'password': password,
                    };

                    try {
                      if (isEdit) {
                        final id = int.tryParse(user['id']?.toString() ?? '') ?? 0;
                        await _apiService.put('/users/$id', payload);
                        _showSnackBar('Pengguna berhasil diperbarui');
                      } else {
                        await _apiService.post('/users', payload);
                        _showSnackBar('Pengguna berhasil ditambahkan');
                      }
                      _loadUsers();
                    } catch (e) {
                      _showSnackBar('Gagal menyimpan pengguna: $e', isError: true);
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

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
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
              const Expanded(child: AppHeader(title: 'Kelola Pengguna')),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('👥', style: TextStyle(fontSize: 60)),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada pengguna',
                              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : isMobile
                        ? ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              final role = user['role'] ?? 'CASHIER';
                              final isAdmin = role == 'ADMIN';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: AppColors.cardBg,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 1,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(user['full_name'] ?? '-', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('@${user['username'] ?? '-'}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isAdmin ? AppColors.brandOrange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          role,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isAdmin ? AppColors.brandOrange : Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showUserDialog(user),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: AppColors.danger),
                                        onPressed: () => _confirmDelete(user),
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
                                    DataColumn(label: Text('Nama Lengkap', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Username', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Role / Peran', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Aksi', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: _users.map((user) {
                                    final role = user['role'] ?? 'CASHIER';
                                    final isAdmin = role == 'ADMIN';

                                    return DataRow(cells: [
                                      DataCell(Text('${user['id']}')),
                                      DataCell(Text(user['full_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text('@${user['username'] ?? '-'}')),
                                      DataCell(Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isAdmin ? AppColors.brandOrange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          role,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isAdmin ? AppColors.brandOrange : Colors.green,
                                          ),
                                        ),
                                      )),
                                      DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showUserDialog(user),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: AppColors.danger),
                                            onPressed: () => _confirmDelete(user),
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

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text('⚠️ Hapus Pengguna'),
          content: Text('Apakah Anda yakin ingin menghapus pengguna "${user['full_name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final id = int.tryParse(user['id']?.toString() ?? '');
                if (id != null) {
                  _deleteUser(id);
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
