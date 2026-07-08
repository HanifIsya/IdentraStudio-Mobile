// lib/services_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import '../services/cart_screen.dart'; 
import 'dart:convert';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ApiService _apiService = ApiService();
  String userName = "Loading...";
  String searchQuery = "";
  int _cartBadgeCount = 0; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateCartBadge(); 
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Identra User";
    });
  }

  void _updateCartBadge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cart_items') ?? [];
    setState(() {
      _cartBadgeCount = cartItemsJson.length;
    });
  }

  void _addToCart(ServiceModel item) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> cartItemsJson = prefs.getStringList('cart_items') ?? [];
      
      bool isAlreadyInCart = false;
      for (var jsonStr in cartItemsJson) {
        var existingItem = jsonDecode(jsonStr);
        if (existingItem['id'] == item.id) {
          isAlreadyInCart = true;
          break;
        }
      }

      if (isAlreadyInCart) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.namaLayanan} sudah ada di keranjang Anda!'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      } else {
        cartItemsJson.add(jsonEncode(item.toJson()));
        await prefs.setStringList('cart_items', cartItemsJson);
        _updateCartBadge(); 

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil menambahkan ${item.namaLayanan} ke keranjang!'),
              backgroundColor: const Color(0xFFD4AF37), 
              action: SnackBarAction(
                label: 'LIHAT',
                textColor: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  ).then((_) => _updateCartBadge()); 
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: Column(
        children: [
          CustomHeader(
            name: userName,
            badgeCount: _cartBadgeCount,
            onCartPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              ).then((_) => _updateCartBadge());
            },
          ),
          
          CustomSearchBar(
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
          
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

                  final services = snapshot.data!.where((item) {
                    return item.namaLayanan.toLowerCase().contains(searchQuery) ||
                           item.deskripsi.toLowerCase().contains(searchQuery);
                  }).toList();

                  if (services.isEmpty) {
                    return const Center(child: Text("Layanan tidak ditemukan."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 120), 
                    physics: const BouncingScrollPhysics(),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final item = services[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: ServiceCard(
                          item: item,
                          onOrderPressed: () => _addToCart(item),
                        ),
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

// ─────────────────────────────────────────────────────────
// KOMPONEN CUSTOM WIDGET (DAPAT DISESUAIKAN DENGAN DASHBOARD)
// ─────────────────────────────────────────────────────────

class CustomHeader extends StatelessWidget {
  final String name;
  final int badgeCount;
  final VoidCallback onCartPressed;

  const CustomHeader({
    super.key, 
    required this.name,
    required this.badgeCount,
    required this.onCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil inisial nama pertama
    String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "U";

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
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
                  style: const TextStyle(
                    color: Colors.black, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 18
                  )
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selamat Datang,", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    name, 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ],
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
                onPressed: onCartPressed,
              ),
              if (badgeCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37), 
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const CustomSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: TextField(
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.black54),
            hintText: "Search Services...",
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel item;
  final VoidCallback onOrderPressed;
  
  const ServiceCard({
    super.key, 
    required this.item,
    required this.onOrderPressed,
  });

  String _formatRupiah(String hargaStr) {
    try {
      double value = double.parse(hargaStr);
      return "Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    } catch (e) {
      return "Rp $hargaStr";
    }
  }

  IconData _getIconData(String serviceName) {
    String nameLower = serviceName.toLowerCase();
    if (nameLower.contains('website') || nameLower.contains('web')) {
      return Icons.computer;
    } else if (nameLower.contains('logo')) {
      return Icons.track_changes;
    } else if (nameLower.contains('app') || nameLower.contains('mobile')) {
      return Icons.smartphone;
    } else if (nameLower.contains('graphic') || nameLower.contains('design')) {
      return Icons.image_aspect_ratio_outlined;
    } else if (nameLower.contains('film') || nameLower.contains('production') || nameLower.contains('video')) {
      return Icons.movie;
    }
    return Icons.design_services;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(_getIconData(item.namaLayanan), size: 35, color: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaLayanan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  item.deskripsi, 
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatRupiah(item.harga),
                  style: const TextStyle(color: Color(0xFFB8860B), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onOrderPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Pilih", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}