// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../models/dashboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Alamat IP server backend Laravel development Anda
  static const String baseUrl = 'https://identra-mobile-deploy-production.up.railway.app/api';
  static const String storageUrl = 'https://identra-mobile-deploy-production.up.railway.app/storage';

  // Helper untuk Header Dasar
  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  // Helper untuk Header dengan Token (Wajib untuk Transaksi & Protected Routes)
  Future<Map<String, String>> _getAuthHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Fungsi Mengambil Data Layanan
  Future<List<ServiceModel>> fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: {'Accept': 'application/json'},
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

  // 2. Fungsi Login
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
        await prefs.setString('user_name', data['user']['name'] ?? data['user']['Nama'] ?? "User");
        await prefs.setString('role', data['user']['role'] ?? "user");
        
        if (data['user']['User_ID'] != null) {
          await prefs.setInt('user_id', data['user']['User_ID']);
        }

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

  // 5. Fungsi Pemrosesan Checkout Keranjang ke Xendit
  Future<String> processCheckout(List<int> serviceIds) async {
    try {
      final authHeaders = await _getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: {
          ...authHeaders,
          'Content-Type': 'application/json', 
        },
        body: jsonEncode({
          'service_ids': serviceIds, 
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 210) {
        if (responseData['invoice_url'] != null) {
          return responseData['invoice_url'].toString();
        } else {
          throw Exception('Backend tidak mengembalikan invoice_url pembayaran.');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Gagal memproses checkout di server.');
      }
    } catch (e) {
      throw Exception('Gagal Checkout: $e');
    }
  }

  // =========================================================
  // INTEGRASI: MULTI-ROOM PROJECTS & CHAT SYSTEM RIIL
  // =========================================================

  // GET: Fetch Semua Projects (Otomatis menyesuaikan Role User vs Admin)
  Future<List<dynamic>> getProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        
        // Cek jika response dibungkus key 'data'
        if (body is Map && body.containsKey('data')) {
          return body['data'];
        } else if (body is List) {
          return body;
        }
        return [];
      } else {
        throw Exception('Gagal memuat daftar project.');
      }
    } catch (e) {
      throw Exception('Kesalahan Koneksi Project: $e');
    }
  }

  // 7. GET: Memuat Riwayat Chat Spesifik Berdasarkan ID Room Project
  Future<List<dynamic>> getChatMessages(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/messages'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return body['data']; 
      } else {
        var body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Gagal memuat riwayat obrolan.');
      }
    } catch (e) {
      throw Exception('Kesalahan Koneksi Chat: $e');
    }
  }

  // 8. POST: Mengirim Pesan Chat Baru ke Room Project Tertentu
  Future<dynamic> sendChatMessage(int projectId, String message) async {
    try {
      final authHeaders = await _getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/messages'),
        headers: {
          ...authHeaders,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      var body = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return body['data']; 
      } else {
        throw Exception(body['message'] ?? 'Gagal mengirim pesan.');
      }
    } catch (e) {
      throw Exception('Kesalahan Pengiriman Chat: $e');
    }
  }

  // =========================================================
  // INTEGRASI: WORKSPACE FILE MANAGEMENT PER PROJECT
  // =========================================================

  // 9. GET: Mengambil Riwayat File Pendukung/Hasil Akhir Proyek
  // GET: Fetch File List
  Future<List<dynamic>> getProjectFiles(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/files'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return body['data'] ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Gagal memuat file: $e');
    }
  }

  // POST: Upload File via Multipart
  Future<bool> uploadProjectFile(int projectId, String filePath) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/projects/$projectId/files'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Cek Log di Debug Console VS Code
      print("Status Code Upload: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error Upload: $e");
      return false;
    }
  }

  // 11. Fungsi Logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // =========================================================
  // CRUD SERVICES (KHUSUS ADMIN)
  // =========================================================

  // Tambah Service Baru (Create)
  Future<bool> addService(String name, String desc, double harga) async {
    try {
      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: headers,
        body: jsonEncode({
          'nama_layanan': name,
          'deskripsi': desc,
          'harga': harga,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Gagal menambah service: $e');
    }
  }

  // Update Service (Edit)
  Future<bool> updateService(int id, String name, String desc, double harga) async {
    try {
      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.put(
        Uri.parse('$baseUrl/services/$id'),
        headers: headers,
        body: jsonEncode({
          'nama_layanan': name,
          'deskripsi': desc,
          'harga': harga,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Gagal memperbarui service: $e');
    }
  }

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

  Future<List<dynamic>> getInvoices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invoices'),
        headers: await _getAuthHeaders(),
      );

      var body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body['data'];
      } else {
        throw Exception(body['message'] ?? 'Gagal memuat riwayat invoice.');
      }
    } catch (e) {
      throw Exception('Kesalahan Koneksi Invoice: $e');
    }
  }

  // Update Status & Progress Project oleh Admin
  Future<bool> updateProjectStatus(int projectId, String status, int progressPercent) async {
    try {
      // 1. Ambil token header dasar
      final headers = await _getAuthHeaders();
      
      // 2. Wajib set header JSON
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';

      // 3. Kirim request dengan jsonEncode
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId'),
        headers: headers,
        body: jsonEncode({
          '_method': 'PUT',
          'status': status,
          'progress_percent': progressPercent,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        var body = jsonDecode(response.body);
        
        // Menampilkan pesan error validasi detail jika ada
        if (body['errors'] != null) {
          throw Exception('Validasi Gagal: ${body['errors']}');
        }
        throw Exception(body['message'] ?? 'Gagal memperbarui status (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Kesalahan Koneksi Update Project: $e');
    }
  }

  // GET: Mengambil daftar pesan room chat berdasarkan projectId
  Future<List<dynamic>> getProjectMessages(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/messages'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body is Map && body.containsKey('data')) {
          return body['data'];
        } else if (body is List) {
          return body;
        }
        return [];
      } else {
        throw Exception('Gagal memuat pesan chat (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Kesalahan Koneksi Chat: $e');
    }
  }

  // POST: Mengirim pesan baru ke room chat
  Future<bool> sendProjectMessage(int projectId, String message) async {
    try {
      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';

      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/messages'),
        headers: headers,
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        var body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Gagal mengirim pesan');
      }
    } catch (e) {
      throw Exception('Kesalahan Pengiriman Chat: $e');
    }
  }

  
  

}