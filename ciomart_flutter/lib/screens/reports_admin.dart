import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../utils/constants.dart';

class ReportsAdminScreen extends StatelessWidget {
  const ReportsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
              const Expanded(child: AppHeader(title: 'Laporan Penjualan')),
            ],
          ),
          const Expanded(
            child: Center(
              child: Text('Halaman Laporan Penjualan (Under Construction)'),
            ),
          )
        ],
      )
    );
  }
}
