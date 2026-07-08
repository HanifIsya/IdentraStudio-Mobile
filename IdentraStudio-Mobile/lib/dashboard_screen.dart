// lib/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'models/dashboard_model.dart';
import 'services_screen.dart';
import 'invoices/invoices_screen.dart';
import 'projects/projects_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  String userName = "Loading...";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => userName = prefs.getString('user_name') ?? "Identra User");
  }

  // -------------------------------------------------------------------------
  // LOGOUT DIALOG & LOGIC
  // -------------------------------------------------------------------------
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Konfirmasi Logout",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: const Text(
            "Apakah Anda yakin ingin keluar dari akun IdentraStudio?",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Hapus token & session simpanan

                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("LOGOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getPages() {
    return [
      _buildDashboardContent(), // Indeks 0: Dashboard
      const ServicesScreen(),   // Indeks 1: Services Catalog
      const InvoicesScreen(),   // Indeks 2: Invoices
      const ProjectsScreen(),   // Indeks 3: Projects Workspace
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _getPages(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // KONTEN UTAMA DASHBOARD
  // -------------------------------------------------------------------------
  Widget _buildDashboardContent() {
    return FutureBuilder<DashboardData>(
      future: _apiService.fetchDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 100),
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    "Gagal memuat data: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text("Coba Lagi"),
                  )
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(userName),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================================
                    // SECTION 1: EKSPLORASI LAYANAN (BISA DIGESER HORIZONTAL)
                    // =========================================================
                    _sectionTitle("Layanan Unggulan"),
                    _buildHorizontalServicesSlider(data.bestOffer),
                    const SizedBox(height: 25),

                    // =========================================================
                    // SECTION 2: PROJECT WORKSPACE AKTIF
                    // =========================================================
                    _sectionTitle("Project Workspace Aktif"),
                    _buildActiveProjectsCard(data.orders),
                    const SizedBox(height: 25),

                    // =========================================================
                    // SECTION 3: RIWAYAT TRANSAKSI TERBARU
                    // =========================================================
                    _sectionTitle("Riwayat Transaksi Terbaru"),
                    _buildTransactionCard(data.transactions),
                    
                    const SizedBox(height: 120), // Spacing bottom nav
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // WIDGET UI HELPERS
  // -------------------------------------------------------------------------

  Widget _buildHeader(String name) {
    String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "U";

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35), 
          bottomRight: Radius.circular(35)
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFD4AF37),
                child: Text(
                  initial, 
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selamat Datang,", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    name, 
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ],
          ),
          
          // Tombol Logout User
          InkWell(
            onTap: _showLogoutDialog,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2), 
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
  );

  // WIDGET SLIDER LAYANAN UNGGULAN (DAPAT DIGESER KE SAMPING)
  Widget _buildHorizontalServicesSlider(Map<String, dynamic>? fallbackOffer) {
    final List<Map<String, dynamic>> servicesList = [
      {
        'title': fallbackOffer?['title'] ?? 'Website Design',
        'description': fallbackOffer?['description'] ?? 'Desain website modern, responsif & profesional.',
        'icon': Icons.web_rounded,
      },
      {
        'title': 'Mobile App Development',
        'description': 'Aplikasi iOS & Android berperforma tinggi.',
        'icon': Icons.phone_android_rounded,
      },
      {
        'title': 'UI/UX Brand Redesign',
        'description': 'Tingkatkan estetika & retensi pengguna produk Anda.',
        'icon': Icons.palette_outlined,
      },
      {
        'title': 'Cloud & API Integration',
        'description': 'Integrasi backend & arsitektur sistem skala besar.',
        'icon': Icons.cloud_done_outlined,
      },
    ];

    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: servicesList.length,
        itemBuilder: (context, index) {
          final service = servicesList[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    color: const Color(0xFFD4AF37),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        service['title'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['description'].toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // KARTU WORKSPACE PROJECT AKTIF
  Widget _buildActiveProjectsCard(List orders) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text(
          "Belum ada project aktif. Silakan pesan layanan di menu Services.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: orders.map((order) {
          return InkWell(
            onTap: () => setState(() => _selectedIndex = 3),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.folder_open_outlined, color: Colors.black, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['title'] ?? 'Project Service', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                          ),
                          Text(
                            "Status: ${order['status'] ?? 'Active'}", 
                            style: const TextStyle(color: Colors.grey, fontSize: 11)
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // RIWAYAT TRANSAKSI REAL
  Widget _buildTransactionCard(List transactions) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text(
          "Belum ada riwayat transaksi.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: transactions.map((tx) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFF5F5F5),
              child: Icon(Icons.receipt_long_outlined, color: Colors.black, size: 20),
            ),
            title: Text(
              tx['invoice_number'] ?? tx['external_id'] ?? 'INV-UNKNOWN', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
            ),
            subtitle: Text(
              tx['title'] ?? 'Pembayaran Layanan', 
              style: const TextStyle(fontSize: 11)
            ),
            trailing: InkWell(
              onTap: () => setState(() => _selectedIndex = 2),
              child: const Icon(Icons.chevron_right, color: Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  // LOGIKA BOTTOM NAV
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), 
        borderRadius: BorderRadius.circular(35),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.grid_view_rounded, "DASHBOARD", 0),
          _navItem(Icons.shopping_bag_outlined, "SERVICES", 1),
          _navItem(Icons.receipt_long_outlined, "INVOICES", 2),
          _navItem(Icons.work_outline, "PROJECTS", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? const Color(0xFFD4AF37) : Colors.white38, size: 22),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: isActive ? const Color(0xFFD4AF37) : Colors.white38, 
                fontSize: 9, 
                fontWeight: FontWeight.bold
              )
            ),
          ],
        ),
      ),
    );
  }
}