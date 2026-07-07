// lib/projects/project_files_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import library file_picker
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class ProjectFilesScreen extends StatefulWidget {
  final int projectId;
  final String namaLayanan;

  const ProjectFilesScreen({
    super.key,
    required this.projectId,
    required this.namaLayanan,
  });

  @override
  State<ProjectFilesScreen> createState() => _ProjectFilesScreenState();
}

class _ProjectFilesScreenState extends State<ProjectFilesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _files = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _fetchProjectFiles();
  }

  void _loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _currentUserId = prefs.getInt('user_id'));
  }

  void _fetchProjectFiles() async {
    try {
      var data = await _apiService.getProjectFiles(widget.projectId);
      setState(() {
        _files = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // FUNGSI UTAMA YANG SUDAH DIPERBAIKI SESUAI VERSI FILE_PICKER ANDA
  void _handlePickAndUploadFile() async {
    try {
      // Menggunakan sintaksis versi lama sesuai instruksi eror Anda
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      // Pada versi lama, terkadang return type-nya adalah FilePickerResult atau Map.
      // Kita pastikan membaca path dari file yang dipilih dengan aman.
      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);
        await _apiService.uploadProjectFile(widget.projectId, result.files.single.path!);
        _showSnackBar('File berhasil diunggah ke proyek!');
        _fetchProjectFiles(); // Refresh daftar file setelah sukses
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memilih/mengunggah file: $e');
    }
  }

  void _downloadFile(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar('Tidak dapat mengunduh berkas.');
    }
  }

  IconData _getFileIcon(String? ext) {
    String type = ext?.toLowerCase() ?? '';
    if (type == 'pdf') return Icons.picture_as_pdf;
    if (['jpg', 'jpeg', 'png'].contains(type)) return Icons.image;
    if (['zip', 'rar'].contains(type)) return Icons.archive;
    return Icons.insert_drive_file;
  }

  void _showSnackBar(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.namaLayanan, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Aset & File Proyek #${widget.projectId}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 24),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    'Silakan unggah berkas pendukung brief di sini. Anda juga bisa mengunduh berkas hasil akhir pengerjaan dari tim kami.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : _files.isEmpty
                    ? Center(child: Text('Belum ada file yang diunggah.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          final bool isMe = file['uploaded_by'] == 'client';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF151515),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isMe ? Colors.white10 : const Color(0xFFD4AF37).withOpacity(0.1),
                                  child: Icon(_getFileIcon(file['file_type']), color: isMe ? Colors.white70 : const Color(0xFFD4AF37), size: 20),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file['file_name'] ?? '',
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${file['file_size']} • Oleh ${isMe ? 'Saya' : 'Admin'}',
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white60, size: 22),
                                  onPressed: () => _downloadFile(file['file_path']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
            color: Colors.black,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _handlePickAndUploadFile,
                icon: const Icon(Icons.upload_file, color: Colors.black, size: 18),
                label: const Text('UNGGAH ASET BARU', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}