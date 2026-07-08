// lib/models/service_model.dart

class ServiceModel {
  final int id;
  final String namaLayanan;
  final String deskripsi;
  final String harga; // Properti harga sesuai database Identra

  ServiceModel({
    required this.id, 
    required this.namaLayanan, 
    required this.deskripsi,
    required this.harga,
  });

  // Fungsi untuk konversi dari JSON ke Objek Dart
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      
      // Menangani variasi nama field dari backend Laravel
      namaLayanan: json['nama_layanan'] ?? json['namaLayanan'] ?? json['title'] ?? json['name'] ?? '', 
      
      deskripsi: json['deskripsi'] ?? json['description'] ?? '',
      
      // Mengamankan konversi tipe data angka/string dari backend
      harga: json['harga']?.toString() ?? 
             json['Harga']?.toString() ?? 
             json['price']?.toString() ?? 
             '0',
    );
  }

  // Fungsi untuk konversi dari Objek ke JSON (Wajib untuk Cart / Local Storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_layanan': namaLayanan,
      'deskripsi': deskripsi,
      'harga': harga,
    };
  }
}