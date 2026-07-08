// lib/admin/admin_project_files_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class AdminProjectFilesScreen extends StatefulWidget {
  final int projectId;
  final String namaLayanan;

  const AdminProjectFilesScreen({
    super.key,
    required this.projectId,
    required this.namaLayanan,
  });

  @override
  State<AdminProjectFilesScreen> createState() => _AdminProjectFilesScreenState();
}

class _AdminProjectFilesScreenState extends State<AdminProjectFilesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _files = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    try {
      final data = await _apiService.getProjectFiles(widget.projectId);
      if (mounted) {
        setState(() {
          _files = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      // 1. Buka File Picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      // Cek apakah pengguna membatalkan pilihan file
      if (result == null || result.files.isEmpty) {
        debugPrint("Pengguna membatalkan pemilihan file.");
        return;
      }

      String? filePath = result.files.single.path;

      if (filePath == null || filePath.isEmpty) {
        _showSnackBar("Gagal membaca jalur (path) file.", Colors.orange);
        return;
      }

      // 2. Set Status Loading
      setState(() => _isUploading = true);

      // 3. Eksekusi Upload ke ApiService
      bool success = await _apiService.uploadProjectFile(widget.projectId, filePath);

      if (!mounted) return;

      if (success) {
        _showSnackBar("File berhasil diunggah!", Colors.green);
        _fetchFiles(); // Refresh daftar file
      } else {
        _showSnackBar("Gagal mengunggah file. Cek batas ukuran server.", Colors.red);
      }

    } catch (e) {
      debugPrint("Error Upload File: $e");
      if (mounted) {
        _showSnackBar("Terjadi kesalahan: $e", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _downloadOrOpenFile(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.namaLayanan, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Asset Files Vault #${widget.projectId}", style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
            onPressed: _fetchFiles,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: _isUploading ? null : _pickAndUploadFile,
        icon: _isUploading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : const Icon(Icons.upload_file_rounded, color: Colors.black),
        label: Text(
          _isUploading ? "UPLOADING..." : "UPLOAD FILE",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _files.isEmpty
              ? const Center(child: Text("Belum ada file terunggah pada project ini.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1E1E1E),
                          child: Icon(Icons.insert_drive_file_outlined, color: Color(0xFFD4AF37)),
                        ),
                        title: Text(
                          file['file_name'] ?? 'File',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "Oleh: ${file['uploaded_by']} • ${file['file_size']} • ${file['created_at']}",
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_rounded, color: Colors.black),
                          onPressed: () => _downloadOrOpenFile(file['file_url']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}