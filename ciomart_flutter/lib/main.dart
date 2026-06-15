import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/constants.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/cashier_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const CiomartApp(),
    ),
  );
}

class CiomartApp extends StatelessWidget {
  const CiomartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIOMART System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandOrange),
        useMaterial3: true,
      ),
      home: Consumer<AuthViewModel>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return const LoginScreen();
          }
          if (auth.currentUser?.role == 'ADMIN') {
            return const AdminDashboard();
          }
          return const CashierDashboard();
        },
      ),
    );
  }
}
