import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'models/dashboard_model.dart';
import 'services_screen.dart';
import 'chats_screen.dart';    // <--- IMPORT BARU
import 'projects_screen.dart'; // <--- IMPORT BARU

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

  // List semua halaman yang sudah terintegrasi
  List<Widget> _getPages() {
    return [
      _buildDashboardContent(), // Indeks 0: Dashboard
      const ServicesScreen(),   // Indeks 1: Services
      const ChatsScreen(),      // Indeks 2: Chats (Sudah Aktif)
      const ProjectsScreen(),   // Indeks 3: Projects (Sudah Aktif)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: Stack(
        children: [
          // Menampilkan halaman sesuai menu yang diklik
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
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(userName),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Chat"),
                    _buildChatTile(data.chat),
                    const SizedBox(height: 25),
                    _sectionTitle("Order Service"),
                    _buildOrderCard(data.orders),
                    const SizedBox(height: 25),
                    _buildBestOfferCard(data.bestOffer),
                    const SizedBox(height: 25),
                    _sectionTitle("Transaction History"),
                    _buildTransactionCard(data.transactions),
                    const SizedBox(height: 120),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFE8DEFF),
                child: Text("HI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("User", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.bar_chart, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _buildChatTile(Map? chat) {
    if (chat == null) return const Text("No Chat Data");
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(backgroundColor: Color(0xFFE8DEFF), child: Text("ML")),
        title: Text(chat['sender_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(chat['last_message'], maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Text("10:45 AM >", style: TextStyle(fontSize: 11, color: Colors.grey)),
      ),
    );
  }

  Widget _buildOrderCard(List orders) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: orders.map((order) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_open_outlined, size: 28),
                  const SizedBox(width: 12),
                  Text(order['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text("\$ ${order['price']} >", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBestOfferCard(Map? offer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Best Offers!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const Text("Sale end in 0:39:40", style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: const Color(0xFFE5B994), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.videocam_outlined, size: 40),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer?['title'] ?? "Premium Pack", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Text("Film Production", style: TextStyle(color: Colors.white60, fontSize: 12)),
                    const Text("\$ 99", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTransactionCard(List transactions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: transactions.map((tx) => ListTile(
          leading: const Icon(Icons.receipt_long),
          title: Text(tx['invoice_number'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(tx['title']),
          trailing: const Icon(Icons.chevron_right),
        )).toList(),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // LOGIKA BOTTOM NAV
  // -------------------------------------------------------------------------
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D), 
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: const Offset(0, 4))],
      ),
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
      onTap: () {
        setState(() => _selectedIndex = index);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white38, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}