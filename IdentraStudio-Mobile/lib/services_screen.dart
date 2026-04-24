// import 'package:flutter/material.dart';

// // ─────────────────────────────────────────
// // MODEL DATA LAYANAN
// // ─────────────────────────────────────────

// class ServiceItemModel {
//   final IconData icon;
//   final String title;
//   final String subtitle;

//   const ServiceItemModel({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });
// }

// // ─────────────────────────────────────────
// // DUMMY DATA (ganti dengan data dari backend)
// // ─────────────────────────────────────────

// const List<ServiceItemModel> _dummyServices = [
//   ServiceItemModel(
//     icon: Icons.computer_outlined,
//     title: 'Website Design',
//     subtitle: 'Create your own website',
//   ),
//   ServiceItemModel(
//     icon: Icons.edit_outlined,
//     title: 'Logo Creation',
//     subtitle: 'Design a custom logo',
//   ),
//   ServiceItemModel(
//     icon: Icons.phone_android_outlined,
//     title: 'App Development',
//     subtitle: 'Build a mobile app',
//   ),
//   ServiceItemModel(
//     icon: Icons.brush_outlined,
//     title: 'Graphic Design',
//     subtitle: 'Get creative visuals',
//   ),
//   ServiceItemModel(
//     icon: Icons.videocam_outlined,
//     title: 'Premium Pack',
//     subtitle: 'Film Production',
//   ),
//   ServiceItemModel(
//     icon: Icons.camera_alt_outlined,
//     title: 'Basic Pack Film',
//     subtitle: 'FullHD Output',
//   ),
// ];

// // ─────────────────────────────────────────
// // SERVICES SCREEN
// // ─────────────────────────────────────────

// class ServicesScreen extends StatefulWidget {
//   const ServicesScreen({super.key});

//   @override
//   State<ServicesScreen> createState() => _ServicesScreenState();
// }

// class _ServicesScreenState extends State<ServicesScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<ServiceItemModel> _filteredServices = _dummyServices;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String query) {
//     // TODO: ganti dengan pencarian dari backend jika diperlukan
//     setState(() {
//       _filteredServices = _dummyServices
//           .where((s) =>
//               s.title.toLowerCase().contains(query.toLowerCase()) ||
//               s.subtitle.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Search Bar ──
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _onSearchChanged,
//               decoration: InputDecoration(
//                 hintText: 'Search Services....',
//                 hintStyle:
//                     const TextStyle(color: Colors.grey, fontSize: 13),
//                 prefixIcon:
//                     const Icon(Icons.search, color: Colors.grey, size: 20),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 12),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),

//           // ── Daftar Layanan ──
//           Expanded(
//             child: ListView.separated(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               itemCount: _filteredServices.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (context, index) {
//                 final service = _filteredServices[index];
//                 return _ServiceCard(service: service);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ServiceCard extends StatelessWidget {
//   final ServiceItemModel service;

//   const _ServiceCard({required this.service});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: const Color(0xFF1C1C1E),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(service.icon, color: Colors.white, size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   service.title,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 14),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   service.subtitle,
//                   style: const TextStyle(
//                       color: Colors.grey, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
//         ],
//       ),
//     );
//   }
// }


// lib/services_screen.dart

// import 'package:flutter/material.dart';
// import 'models/service_model.dart';
// import 'services/api_service.dart';

// class ServicesScreen extends StatefulWidget {
//   const ServicesScreen({super.key});

//   @override
//   State<ServicesScreen> createState() => _ServicesScreenState();
// }

// class _ServicesScreenState extends State<ServicesScreen> {
//   final ApiService _apiService = ApiService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Identra Studio Services"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: FutureBuilder<List<ServiceModel>>(
//         future: _apiService.fetchServices(), // Memanggil fungsi dari API
//         builder: (context, snapshot) {
//           // 1. Jika data sedang loading
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } 
//           // 2. Jika terjadi error
//           else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } 
//           // 3. Jika data kosong
//           else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("Tidak ada layanan tersedia."));
//           }

//           // 4. Jika data berhasil didapat, tampilkan dalam ListView
//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) {
//               final item = snapshot.data![index];
//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 child: ListTile(
//                   leading: CircleAvatar(child: Text("${index + 1}")),
//                   title: Text(item.namaLayanan, style: const TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Text(item.deskripsi),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }




// lib/services_screen.dart

// import 'package:flutter/material.dart';
// import 'models/service_model.dart';
// import 'services/api_service.dart';

// class ServicesScreen extends StatefulWidget {
//   const ServicesScreen({super.key});

//   @override
//   State<ServicesScreen> createState() => _ServicesScreenState();
// }

// class _ServicesScreenState extends State<ServicesScreen> {
//   final ApiService _apiService = ApiService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFEFEFEF), // Warna background abu-abu muda
//       body: Column(
//         children: [
//           // 1. Black Rounded Header
//           const CustomHeader(),

//           // 2. White Search Bar
//           const CustomSearchBar(),

//           // 3. Service List Area
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: FutureBuilder<List<ServiceModel>>(
//                 future: _apiService.fetchServices(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text("Error: ${snapshot.error}"));
//                   } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Center(child: Text("Tidak ada layanan tersedia."));
//                   }

//                   final services = snapshot.data!;

//                   return ListView.builder(
//                     itemCount: services.length,
//                     itemBuilder: (context, index) {
//                       final item = services[index];
//                       // Berikan margin bawah antar card
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 15.0),
//                         child: ServiceCard(item: item),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       // 4. Black Rounded Bottom Navigation Bar
//       bottomNavigationBar: const CustomBottomNavBar(),
//     );
//   }
// }

// // --- Custom Widget Components ---

// class CustomHeader extends StatelessWidget {
//   const CustomHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 60, 20, 20), // Padding untuk status bar
//       decoration: const BoxDecoration(
//         color: Colors.black, // Warna hitam
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30), // Rounded corners di bawah
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Profile dan Nama
//           Row(
//             children: [
//               const CircleAvatar(
//                 radius: 25,
//                 backgroundColor: Color(0xFFE8DEFF), // Warna ungu muda avatar
//                 child: Text("LH", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
//               ),
//               const SizedBox(width: 15),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text("User", style: TextStyle(color: Colors.white70, fontSize: 14)),
//                   Text("Lee chanyeol", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ],
//           ),
//           // Ikon Notifikasi dan Grafik
//           Row(
//             children: [
//               Stack(
//                 children: [
//                   const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       width: 10,
//                       height: 10,
//                       decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(width: 15),
//               const Icon(Icons.bar_chart_outlined, color: Colors.white, size: 28),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CustomSearchBar extends StatelessWidget {
//   const CustomSearchBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 15),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 5,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: const TextField(
//           decoration: InputDecoration(
//             border: InputBorder.none,
//             icon: Icon(Icons.search, color: Colors.black54),
//             hintText: "Search Services....",
//             hintStyle: TextStyle(color: Colors.black38),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ServiceCard extends StatelessWidget {
//   final ServiceModel item;

//   const ServiceCard({super.key, required this.item});

//   // Fungsi helper untuk menentukan ikon berdasarkan nama layanan dari Laravel
//   IconData _getIconData(String serviceName) {
//     String nameLower = serviceName.toLowerCase();
//     if (nameLower.contains('website')) {
//       return Icons.computer;
//     } else if (nameLower.contains('logo')) {
//       return Icons.track_changes; // Mendekati ikon di gambar
//     } else if (nameLower.contains('app development')) {
//       return Icons.smartphone;
//     } else if (nameLower.contains('graphic')) {
//       return Icons.image_aspect_ratio_outlined;
//     } else if (nameLower.contains('film') || nameLower.contains('production')) {
//       return Icons.movie;
//     } else if (nameLower.contains('pack')) {
//       return Icons.camera_alt;
//     }
//     // Ikon default jika tidak ada kecocokan
//     return Icons.design_services;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Ikon Layanan (Dinamic berdasarkan nama dari Laravel)
//           Icon(_getIconData(item.namaLayanan), size: 35, color: Colors.black),
//           const SizedBox(width: 15),
//           // Teks Judul dan Deskripsi
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.namaLayanan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
//                 const SizedBox(height: 5),
//                 Text(item.deskripsi, style: const TextStyle(fontSize: 13, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CustomBottomNavBar extends StatelessWidget {
//   const CustomBottomNavBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.black, // Warna hitam
//         borderRadius: BorderRadius.circular(30), // Rounded corners
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavItem(Icons.grid_view, "DASHBOARD", false),
//           _buildNavItem(Icons.shopping_bag_outlined, "SERVICES", true), // Dipilih
//           _buildNavItem(Icons.chat_bubble_outline, "CHATS", false),
//           _buildNavItem(Icons.check_box_outlined, "PROJECTS", false),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, bool isSelected) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 24),
//         const SizedBox(height: 5),
//         Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : Colors.white60,
//             fontSize: 10,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         if (isSelected)
//           const SizedBox(height: 2),
//         if (isSelected)
//           Container(
//             width: 15,
//             height: 2,
//             decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
//           ),
//       ],
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'models/service_model.dart';
// import 'services/api_service.dart';

// class ServicesScreen extends StatefulWidget {
//   const ServicesScreen({super.key});

//   @override
//   State<ServicesScreen> createState() => _ServicesScreenState();
// }

// class _ServicesScreenState extends State<ServicesScreen> {
//   final ApiService _apiService = ApiService();
//   String userName = "Loading..."; // Variabel penampung nama dari database

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData(); // Mengambil nama saat halaman dibuka
//   }

//   // Fungsi untuk mengambil nama yang tersimpan di memori HP
//   void _loadUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       // 'user_name' adalah key yang kita simpan di api_service.dart
//       userName = prefs.getString('user_name') ?? "Identra User";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFEFEFEF),
//       body: Column(
//         children: [
//           // 1. Header Dinamis (Mengirim variabel userName)
//           CustomHeader(name: userName),

//           // 2. Search Bar
//           const CustomSearchBar(),

//           // 3. Area List Layanan
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: FutureBuilder<List<ServiceModel>>(
//                 future: _apiService.fetchServices(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text("Error: ${snapshot.error}"));
//                   } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Center(child: Text("Tidak ada layanan."));
//                   }

//                   final services = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: services.length,
//                     itemBuilder: (context, index) {
//                       final item = services[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 15.0),
//                         child: ServiceCard(item: item),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
     
//     );
//   }
// }

// // --- Komponen Header (Sudah diperbaiki agar tidak merah) ---
// class CustomHeader extends StatelessWidget {
//   final String name; // Deklarasi variabel name

//   // Constructor untuk menerima data name dari luar
//   const CustomHeader({super.key, required this.name});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
//       decoration: const BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               const CircleAvatar(
//                 radius: 25,
//                 backgroundColor: Color(0xFFE8DEFF),
//                 child: Text("HI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//               ),
//               const SizedBox(width: 15),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("User", style: TextStyle(color: Colors.white70, fontSize: 14)),
//                   // SEKARANG MENGGUNAKAN VARIABEL name
//                   Text(
//                     name, 
//                     style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
//         ],
//       ),
//     );
//   }
// }

// // --- Komponen Search Bar ---
// class CustomSearchBar extends StatelessWidget {
//   const CustomSearchBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 15),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: const TextField(
//           decoration: InputDecoration(
//             border: InputBorder.none,
//             icon: Icon(Icons.search, color: Colors.black54),
//             hintText: "Search Services....",
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- Komponen Card Layanan ---
// class ServiceCard extends StatelessWidget {
//   final ServiceModel item;
//   const ServiceCard({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.design_services, size: 35, color: Colors.black),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.namaLayanan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 const SizedBox(height: 5),
//                 Text(item.deskripsi, style: const TextStyle(fontSize: 13, color: Colors.black54)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/service_model.dart';
import 'services/api_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ApiService _apiService = ApiService();
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Identra User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: Column(
        children: [
          CustomHeader(name: userName),
          const CustomSearchBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FutureBuilder<List<ServiceModel>>(
                future: _apiService.fetchServices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.black));
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Tidak ada layanan."));
                  }

                  final services = snapshot.data!;
                  return ListView.builder(
                    // --- KUNCI PERBAIKAN DI SINI ---
                    // Memberikan padding bawah sebesar 120 agar item terakhir tidak tertutup Navigasi
                    padding: const EdgeInsets.only(top: 10, bottom: 120), 
                    physics: const BouncingScrollPhysics(), // Biar scroll lebih halus ala iOS
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final item = services[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: ServiceCard(item: item),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Komponen Header (Tetap Sama) ---
class CustomHeader extends StatelessWidget {
  final String name;
  const CustomHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
                  const Text("User", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}

// --- Komponen Search Bar (Tetap Sama) ---
class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: const TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.black54),
            hintText: "Search Services....",
          ),
        ),
      ),
    );
  }
}

// --- Komponen Card Layanan (Tetap Sama) ---
class ServiceCard extends StatelessWidget {
  final ServiceModel item;
  const ServiceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.design_services, size: 35, color: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaLayanan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(item.deskripsi, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}