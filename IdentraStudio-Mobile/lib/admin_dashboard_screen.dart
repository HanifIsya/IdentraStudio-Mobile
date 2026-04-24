import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'admin_services_screen.dart';
// Import halaman lain jika sudah ada (misal halaman CRUD Service Admin)


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  String adminName = "Admin";

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  void _loadAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('user_name') ?? "Admin Identra";
    });
  }

  // List halaman untuk Admin
  List<Widget> _getAdminPages() {
    return [
      _buildAdminHome(), // Indeks 0: Dashboard Admin
      const AdminServicesScreen(), // Indeks 1: CRUD Services
      const Center(child: Text("All Customer Chats")),  // Indeks 2
      const Center(child: Text("All Project Control")), // Indeks 3
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
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 1. KONTEN UTAMA DASHBOARD ADMIN
  // -------------------------------------------------------------------------
  Widget _buildAdminHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Business Overview"),
                _buildBusinessOverview(),
                const SizedBox(height: 25),
                _sectionTitle("Quick Actions"),
                _buildQuickActions(),
                const SizedBox(height: 25),
                _sectionTitle("Customer Chats"),
                _buildChatList(),
                const SizedBox(height: 25),
                _sectionTitle("Project Control"),
                _buildProjectControl(),
                const SizedBox(height: 120), // Ruang untuk Nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 2. WIDGET HELPERS (DESAIN SESUAI GAMBAR)
  // -------------------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'), // Avatar dummy
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ADMIN PANEL", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(adminName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.notifications_none, color: Colors.white),
          const SizedBox(width: 15),
          const Icon(Icons.bar_chart_rounded, color: Colors.white),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _buildBusinessOverview() {
    return Row(
      children: [
        _overviewCard("TOTAL REVENUE", "\$42.8k", Icons.account_balance_wallet, const Color(0xFF1E1E1E)),
        const SizedBox(width: 15),
        _overviewCard("ACTIVE PROJECTS", "24", Icons.rocket_launch, const Color(0xFF1E1E1E)),
      ],
    );
  }

  Widget _overviewCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.greenAccent, size: 28),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionItem(Icons.add_box_outlined, "New Service"),
        _actionItem(Icons.campaign_outlined, "Broadcast"),
        _actionItem(Icons.people_outline, "Staff"),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildChatList() {
    return Column(
      children: [
        _chatTile("James Smith", "Is the cinematic pack available?", "10:45 AM", "2"),
        _chatTile("Maria Lopez", "Thank you for the fast delivery!", "Yesterday", null),
      ],
    );
  }

  Widget _chatTile(String name, String msg, String time, String? count) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: Text(name[0])),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            if (count != null) Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10))),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectControl() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Motion Graphics\nDesign", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Chip(label: Text("In Progress", style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 15),
          const Text("Order #8821 • Client: TechCorp", style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: 0.6, backgroundColor: Colors.white12, color: Colors.white, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(15)), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Update Status", style: TextStyle(color: Colors.white)), Icon(Icons.keyboard_arrow_down, color: Colors.white)]))),
              const SizedBox(width: 15),
              Container(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: const Text("Update", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 3. BOTTOM NAV LOGIC
  // -------------------------------------------------------------------------
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(35)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.grid_view_rounded, "DASHBOARD", 0),
          _navItem(Icons.shopping_bag_outlined, "SERVICES", 1),
          _navItem(Icons.chat_bubble_outline, "CHATS", 2),
          _navItem(Icons.check_box_outlined, "PROJECTS", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.white : Colors.white38, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}