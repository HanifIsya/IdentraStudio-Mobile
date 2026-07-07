// lib/projects/projects_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Sesuaikan path ApiService kamu
import 'chat_room_screen.dart';
import 'project_files_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjectsData();
  }

  void _fetchProjectsData() async {
    try {
      var data = await _apiService.getProjects();
      setState(() {
        _projects = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'briefing': return Colors.blueAccent;
      case 'design': return Colors.purpleAccent;
      case 'development': return Colors.orangeAccent;
      case 'testing': return Colors.cyanAccent;
      case 'done': return Colors.greenAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'PROJECT SAYA',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : _projects.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada project aktif.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _fetchProjectsData(),
                  color: const Color(0xFFD4AF37),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _projects.length,
                    itemBuilder: (context, index) {
                      final project = _projects[index];
                      // Ambil data relation service yang di-load dari Laravel
                      final String namaLayanan = project['service'] != null 
                          ? project['service']['nama_layanan'] 
                          : 'Layanan Identra';
                      final String status = project['status'] ?? 'briefing';
                      final int progressPercent = project['progress_percent'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    namaLayanan,
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project['external_id'] ?? '-',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                            ),
                            const Divider(color: Colors.white10, height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Progress Kerja', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(
                                  '$progressPercent%',
                                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progressPercent / 100,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProjectFilesScreen(
                                            projectId: project['id'],
                                            namaLayanan: namaLayanan,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.folder_open, size: 16),
                                    label: const Text('ASSET FILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white24),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatRoomScreen(
                                            projectId: project['id'],
                                            namaLayanan: namaLayanan,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                    label: const Text('HUBUNGI ADMIN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD4AF37),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}