import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart'; // <--- Tambahkan import untuk dashboard admin
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      // 1. Panggil fungsi login dan simpan hasilnya di variabel 'response'
      final response = await _apiService.login(_emailController.text, _passController.text);
      
      // 2. Ambil data role dari response Laravel
      // Sesuai dengan ApiService kita, role ada di dalam data['user']['role']
      String role = response['user']['role'] ?? 'user';

      if (mounted) {
        // 3. Logika Percabangan Navigasi berdasarkan Role
        if (role == 'admin') {
          // Jika Admin, arahkan ke Admin Dashboard
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen())
          );
        } else {
          // Jika User biasa, arahkan ke Dashboard Screen utama
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const DashboardScreen())
          );
        }
      }
    } catch (e) {
      // Tampilkan pesan error jika login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email atau Password salah atau terjadi masalah koneksi!")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Background Hitam Identra
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Text("IDENTRA\nSTUDIO.", 
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
            const SizedBox(height: 60),
            const Center(
              child: Column(
                children: [
                  Text("Selamat\nDatang", textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.1)),
                  SizedBox(height: 15),
                  Text("Silahkan masuk ke akun Identra Studio\nAnda.", textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 50),
            _buildLabel("EMAIL ADDRESS"),
            _buildTextField(_emailController, "User@gmail.com", false),
            const SizedBox(height: 20),
            _buildLabel("PASSWORD"),
            _buildTextField(_passController, "••••••••••••", true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("Masuk Sekarang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerRight,
              child: Text("Lupa password?", style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum bergabung dengan kami? ", style: TextStyle(color: Colors.white70, fontSize: 12)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: const Text("DAFTAR AKUN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Helper untuk Label dan TextField tetap sama ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}