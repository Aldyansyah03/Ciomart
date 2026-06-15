import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../utils/constants.dart';

class UsersAdminScreen extends StatelessWidget {
  const UsersAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
              const Expanded(child: AppHeader(title: 'Kelola Pengguna')),
            ],
          ),
          const Expanded(
            child: Center(
              child: Text('Halaman Kelola Pengguna (Under Construction)'),
            ),
          )
        ],
      )
    );
  }
}
