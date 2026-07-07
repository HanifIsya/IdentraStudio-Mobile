// lib/models/service_model.dart

class ServiceModel {
  final int id;
  final String namaLayanan;
  final String deskripsi;
  final String harga; // Tambahan properti harga sesuai database Identra Website

  ServiceModel({
    required this.id, 
    required this.namaLayanan, 
    required this.deskripsi,
    required this.harga, // Wajib diisi saat inisialisasi objek
  });

  // Fungsi untuk konversi dari JSON ke Objek Dart
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      // Pastikan 'nama_layanan' sesuai dengan yang muncul di database browser kamu
      namaLayanan: json['nama_layanan'], 
      deskripsi: json['deskripsi'],
      // Mengamankan konversi tipe data dari backend (int/double dipaksa menjadi String aman)
      harga: json['harga']?.toString() ?? json['Harga']?.toString() ?? '0',
    );
  }

  // Tambahan Fungsi untuk konversi dari Objek ke JSON String (Wajib untuk sistem Cart lokal)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_layanan': namaLayanan,
      'deskripsi': deskripsi,
      'harga': harga,
    };
  }
}