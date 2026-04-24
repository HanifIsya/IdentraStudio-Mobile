import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../models/dashboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Gunakan 10.0.2.2 untuk emulator Android laptop Lenovo LOQ kamu
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Helper untuk Header Dasar
  Map<String, String> get _headers => {
        'Accept': 'application/json',
      };

  // Helper untuk Header dengan Token (Wajib untuk CRUD Admin)
  Future<Map<String, String>> _getAuthHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Fungsi Mengambil Data Layanan (Bisa diakses User & Admin)
  Future<List<ServiceModel>> fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => ServiceModel.fromJson(data)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan Koneksi: $e');
    }
  }

  // 2. Fungsi Login (Sekarang Menyimpan ROLE)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token'] ?? "");
        await prefs.setString('user_name', data['user']['name'] ?? "User");
        
        // --- LOGIKA BARU: Simpan Role (admin/user) ---
        await prefs.setString('role', data['user']['role'] ?? "user");

        return data;
      } else {
        throw Exception('Login Gagal: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  // 3. Fungsi Register
  Future<void> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Gagal mendaftar: ${response.body}');
      }
    } catch (e) {
      throw Exception('Kesalahan pendaftaran: $e');
    }
  }

  // 4. Fungsi Mengambil Data Dashboard
  Future<DashboardData> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return DashboardData.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Gagal memuat Dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan Koneksi Dashboard: $e');
    }
  }

  // =========================================================
  // KODE BARU: CRUD SERVICES (KHUSUS ADMIN)
  // =========================================================

  // A. Tambah Layanan Baru
  Future<bool> addService(String nama, String deskripsi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: await _getAuthHeaders(),
        body: {
          'nama_layanan': nama,
          'deskripsi': deskripsi,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // B. Update Layanan
  Future<bool> updateService(int id, String nama, String deskripsi) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/services/$id'),
        headers: await _getAuthHeaders(),
        body: {
          'nama_layanan': nama,
          'deskripsi': deskripsi,
        },
      );

print("LOG UPDATE: ${response.statusCode}");
    print("LOG BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // C. Hapus Layanan
  Future<bool> deleteService(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/services/$id'),
        headers: await _getAuthHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}