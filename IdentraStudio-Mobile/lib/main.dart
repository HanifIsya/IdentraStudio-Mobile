// lib/main.dart

import 'package:flutter/material.dart';
import 'login_screen.dart'; // Sesuaikan path jika lokasi login_screen.dart kamu berbeda (misal: 'login_screen.dart')
import 'dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Identra Studio',
      
      // Tema Aplikasi
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEFEFEF),
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          primary: Colors.black,
          secondary: const Color(0xFFD4AF37),
        ),
        useMaterial3: true,
      ),

      // Entry Point Pertama Aplikasi
      home: const LoginScreen(),

      // Pendaftaran Named Routes (Menyelesaikan error navigator logout)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}