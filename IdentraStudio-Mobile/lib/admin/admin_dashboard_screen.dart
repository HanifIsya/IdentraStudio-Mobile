// lib/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '/login_screen.dart';
import 'admin_services_screen.dart';
import 'admin_project_files_screen.dart';
import 'admin_project_detail_screen.dart'; // Import halaman detail project admin

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;
  String _adminName = "Admin";

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  void _loadAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminName = prefs.getString('user_name') ?? "Admin";
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // --- DAFTAR HALAMAN ADMIN ---
  List<Widget> _getAdminPages() {
    return [
      _buildAdminHome(),                 // Indeks 0: Home Dashboard Lengkap
      const AdminServicesScreen(),       // Indeks 1: Manage Services
      _buildProjectFilesSelectorPage(),  // Indeks 2: File Vault & Upload Asset
      _buildAllProjectsControlPage(),    // Indeks 3: Status Proyek & Detail Control
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _getAdminPages(),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 25,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  // --- TAB 0: HOME ADMIN DASHBOARD LENGKAP ---
  Widget _buildAdminHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile Admin
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFFD4AF37),
                  child: Icon(Icons.admin_panel_settings, color: Colors.black, size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, $_adminName",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Administrator Portal • IdentraStudio",
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  onPressed: _logout,
                )
              ],
            ),
          ),
          const SizedBox(height: 25),

          const Text("Overview Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          // Cards Ringkasan Real-time
          FutureBuilder<List<dynamic>>(
            future: _apiService.getProjects(),
            builder: (context, snapshot) {
              int totalProjects = snapshot.data?.length ?? 0;
              int activeProjects = snapshot.data?.where((p) => (p['status'] ?? '').toString().toLowerCase() != 'completed').length ?? 0;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Total Order", "$totalProjects", Icons.assignment_outlined, Colors.black)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildStatCard("Dalam Proses", "$activeProjects", Icons.pending_actions_rounded, const Color(0xFFD4AF37))),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 25),

          const Text("Proyek Terbaru", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          // List Preview Proyek Terbaru di Home
          FutureBuilder<List<dynamic>>(
            future: _apiService.getProjects(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.black)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: const Center(child: Text("Belum ada proyek aktif.", style: TextStyle(color: Colors.grey, fontSize: 13))),
                );
              }

              final recentProjects = snapshot.data!.take(3).toList();

              return Column(
                children: recentProjects.map((p) {
                  final String serviceName = p['service']?['nama_layanan'] ?? 'Service Project';
                  final String clientName = p['user']?['name'] ?? 'Klien';
                  final String status = p['status'] ?? 'pending';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFF1F1F1),
                          child: Icon(Icons.work_outline, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("Klien: $clientName • #${p['id']}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status.toLowerCase() == 'completed' ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: status.toLowerCase() == 'completed' ? Colors.green : Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
    );
  }

  // --- TAB 2: SELEKTOR RUANG FILE VAULT ---
  Widget _buildProjectFilesSelectorPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("PROJECT FILE VAULT", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _apiService.getProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada project aktif.", style: TextStyle(color: Colors.grey)));
          }

          final projects = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final p = projects[index];
              final String serviceName = p['service']?['nama_layanan'] ?? 'Project Service';
              final String clientName = p['user']?['name'] ?? 'Klien';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.folder_copy_outlined, color: Color(0xFFD4AF37), size: 20),
                  ),
                  title: Text(serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("Klien: $clientName • Proyek #${p['id']}", style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminProjectFilesScreen(
                          projectId: p['id'],
                          namaLayanan: serviceName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- TAB 3: DAFTAR SEMUA PROYEK (DIARAHKAN KE ADMIN PROJECT DETAIL SCREEN) ---
  Widget _buildAllProjectsControlPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("ALL ACTIVE PROJECTS", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _apiService.getProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada proyek.", style: TextStyle(color: Colors.grey)));
          }

          final projects = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final p = projects[index];
              final String serviceName = p['service']?['nama_layanan'] ?? 'Project Service';
              final String clientName = p['user']?['name'] ?? 'Klien';
              final String status = p['status'] ?? 'pending';

              return Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      // DIUBAH: Mengarah ke AdminProjectDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminProjectDetailScreen(
                            project: p,
                          ),
                        ),
                      ).then((_) {
                        // Refresh halaman ketika kembali dari detail
                        setState(() {});
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status.toLowerCase() == 'completed' ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: status.toLowerCase() == 'completed' ? Colors.green : Colors.amber.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Client: $clientName • ID Proyek: #${p['id']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- BOTTOM NAVIGATION BAR KUSTOM ADMIN ---
  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.grid_view_rounded, "HOME", 0),
          _navItem(Icons.design_services, "SERVICES", 1),
          _navItem(Icons.folder_open_rounded, "FILES", 2),
          _navItem(Icons.assignment_turned_in, "PROJECTS", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white54,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}