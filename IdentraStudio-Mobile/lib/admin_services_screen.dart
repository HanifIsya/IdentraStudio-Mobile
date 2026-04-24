import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/service_model.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  // 1. Fungsi mengambil data layanan terbaru
  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.fetchServices();
      setState(() => _services = data);
    } catch (e) {
      _showSnackBar("Gagal memuat data: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk menampilkan pesan snackbar
  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // --- PERBAIKAN: Posisi FloatingActionButton agar di atas Bottom Nav ---
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), 
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () => _showFormDialog(null),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : _services.isEmpty
                    ? const Center(child: Text("Belum ada layanan."))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120), // Padding bawah lebih besar
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          return _buildServiceAdminCard(_services[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // --- HEADER ADMIN ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35), 
          bottomRight: Radius.circular(35),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.settings_suggest, color: Colors.white, size: 28),
          SizedBox(width: 15),
          Text(
            "Manage Services",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- CARD LAYANAN VERSI ADMIN ---
  Widget _buildServiceAdminCard(ServiceModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE8DEFF),
            child: Icon(Icons.design_services, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaLayanan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(item.deskripsi, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: () => _showFormDialog(item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(item.id),
          ),
        ],
      ),
    );
  }

  // --- DIALOG FORM (CREATE & UPDATE) ---
  void _showFormDialog(ServiceModel? service) {
    final nameController = TextEditingController(text: service?.namaLayanan);
    final descController = TextEditingController(text: service?.deskripsi);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service == null ? "Add New Service" : "Edit Service",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTextField(nameController, "Service Name"),
            const SizedBox(height: 15),
            _buildTextField(descController, "Description", maxLines: 3),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  // --- PERBAIKAN: Inisialisasi success agar tidak Null ---
                  bool success = false; 

                  try {
                    if (service == null) {
                      success = await _apiService.addService(nameController.text, descController.text);
                    } else {
                      success = await _apiService.updateService(service.id, nameController.text, descController.text);
                    }

                    // Cek mounted agar tidak error saat pindah halaman
                    if (!mounted) return;

                    if (success) {
                      Navigator.pop(context); // Tutup Dialog
                      _loadServices();        // Refresh list
                      _showSnackBar("Berhasil disimpan!", Colors.green);
                    } else {
                      _showSnackBar("Gagal menyimpan! Cek Log di VS Code.", Colors.red);
                    }
                  } catch (e) {
                    _showSnackBar("Terjadi kesalahan: $e", Colors.red);
                  }
                },
                child: const Text("Save Service", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  // --- KONFIRMASI HAPUS ---
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Layanan?"),
        content: const Text("Data yang dihapus tidak bisa dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              try {
                bool success = await _apiService.deleteService(id);
                if (!mounted) return;
                if (success) {
                  Navigator.pop(context);
                  _loadServices();
                  _showSnackBar("Berhasil dihapus!", Colors.black);
                }
              } catch (e) {
                _showSnackBar("Gagal menghapus: $e", Colors.red);
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}