// lib/admin/admin_project_detail_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../projects/chat_room_screen.dart'; // Sudah disesuaikan ke chat_room_screen.dart

class AdminProjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const AdminProjectDetailScreen({super.key, required this.project});

  @override
  State<AdminProjectDetailScreen> createState() => _AdminProjectDetailScreenState();
}

class _AdminProjectDetailScreenState extends State<AdminProjectDetailScreen> {
  final ApiService _apiService = ApiService();
  late Map<String, dynamic> _currentProject;

  @override
  void initState() {
    super.initState();
    _currentProject = Map<String, dynamic>.from(widget.project);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.greenAccent;
      case 'in_progress':
        return Colors.lightBlueAccent;
      case 'review':
        return Colors.orangeAccent;
      case 'cancelled':
        return Colors.redAccent;
      case 'briefing':
      default:
        return const Color(0xFFD4AF37);
    }
  }

  void _showUpdateProgressModal() {
    String selectedStatus = _currentProject['status'] ?? 'briefing';
    double currentProgress = double.tryParse(_currentProject['progress_percent']?.toString() ?? '0') ?? 0.0;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KONTROL PROGRESS PROJECT',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 10),

                  // Dropdown Status Selector
                  const Text('Status Project:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStatus,
                        dropdownColor: Colors.black,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: const [
                          DropdownMenuItem(value: 'briefing', child: Text('Briefing (Pengumpulan Data)')),
                          DropdownMenuItem(value: 'in_progress', child: Text('In Progress (Pengerjaan)')),
                          DropdownMenuItem(value: 'review', child: Text('Review (Pemeriksaan Klien)')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed (Selesai)')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled (Dibatalkan)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedStatus = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Slider Persentase Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress Pengerjaan:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        '${currentProgress.toInt()}%',
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Slider(
                    value: currentProgress,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: const Color(0xFFD4AF37),
                    inactiveColor: Colors.white12,
                    label: '${currentProgress.toInt()}%',
                    onChanged: (val) {
                      setModalState(() => currentProgress = val);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              try {
                                bool success = await _apiService.updateProjectStatus(
                                  _currentProject['id'],
                                  selectedStatus,
                                  currentProgress.toInt(),
                                );
                                if (success && mounted) {
                                  setState(() {
                                    _currentProject['status'] = selectedStatus;
                                    _currentProject['progress_percent'] = currentProgress.toInt();
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Status & Progress project berhasil diperbarui!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String serviceName = _currentProject['service']?['nama_layanan'] ?? 'Project Service';
    final String clientName = _currentProject['user']?['name'] ?? 'Klien';
    final String clientEmail = _currentProject['user']?['email'] ?? '-';
    final String invoiceId = _currentProject['external_id'] ?? '-';
    final String status = _currentProject['status'] ?? 'briefing';
    final int progress = int.tryParse(_currentProject['progress_percent']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'MANAJEMEN PROJECT',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Informasi Utamanya
            Container(
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
                          serviceName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 10),

                  // Detail Klien & Invoice
                  _infoRow(Icons.person_outline, 'Klien', clientName),
                  const SizedBox(height: 10),
                  _infoRow(Icons.email_outlined, 'Email', clientEmail),
                  const SizedBox(height: 10),
                  _infoRow(Icons.receipt_long_outlined, 'Invoice ID', invoiceId),
                  const SizedBox(height: 20),

                  // Progress Bar Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress Status', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('$progress%', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress / 100.0,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tombol Aksi Kontrol Status & Progress
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _showUpdateProgressModal,
                icon: const Icon(Icons.tune_rounded, size: 20),
                label: const Text('UPDATE STATUS & PROGRESS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text('Aksi & Workspace Project', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Navigation Cards ke Chat Room
            _actionCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Workspace Chat Room',
              subtitle: 'Buka obrolan & konsultasi dengan klien',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                      projectId: _currentProject['id'],
                      namaLayanan: serviceName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _actionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      ),
    );
  }
}