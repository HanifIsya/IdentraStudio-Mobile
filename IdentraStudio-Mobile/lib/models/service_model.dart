// lib/models/service_model.dart

class ServiceModel {
  final int id;
  final String namaLayanan;
  final String deskripsi;

  ServiceModel({
    required this.id, 
    required this.namaLayanan, 
    required this.deskripsi
  });

  // Fungsi untuk konversi dari JSON ke Objek Dart
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      // Pastikan 'nama_layanan' sesuai dengan yang muncul di browser kamu tadi
      namaLayanan: json['nama_layanan'], 
      deskripsi: json['deskripsi'],
    );
  }
}