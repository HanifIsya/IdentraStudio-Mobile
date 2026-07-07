// lib/services/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // MENGIMPOR LAUNCHER BROWSER AUTOMATIS
import '../models/service_model.dart';
import 'api_service.dart'; 
import 'dart:convert';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();
  List<ServiceModel> _cartItems = [];
  bool _isLoading = true;
  bool _isProcessingCheckout = false; 

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cart_items') ?? [];

    List<ServiceModel> tempItems = [];
    for (var jsonStr in cartItemsJson) {
      try {
        var mapped = jsonDecode(jsonStr);
        tempItems.add(ServiceModel.fromJson(mapped));
      } catch (e) {
        // Lewati jika parse gagal
      }
    }

    setState(() {
      _cartItems = tempItems;
      _isLoading = false;
    });
  }

  void _removeItem(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cart_items') ?? [];
    
    cartItemsJson.removeWhere((jsonStr) {
      var item = jsonDecode(jsonStr);
      return item['id'] == id;
    });

    await prefs.setStringList('cart_items', cartItemsJson);
    _loadCartItems();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layanan berhasil dihapus dari keranjang.'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var item in _cartItems) {
      total += double.tryParse(item.harga) ?? 0;
    }
    return total;
  }

  String _formatRupiah(double value) {
    return "Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // Fungsi Meluncurkan Halaman Pembayaran Xendit
  Future<void> _launchPaymentUrl(String urlString, ScaffoldMessengerState messenger) async {
    final Uri url = Uri.parse(urlString);
    try {
      // Membuka tautan menggunakan external browser HP agar mendukung semua jenis e-wallet/bank app redirect
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka browser pembayaran.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal memuat halaman: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleCheckout() {
    if (_cartItems.isEmpty) return;

    List<int> serviceIds = _cartItems.map((item) => item.id).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Konfirmasi Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Apakah Anda yakin ingin memesan ${_cartItems.length} layanan dengan total ${_formatRupiah(_calculateTotalPrice())}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(this.context);
              
              Navigator.pop(context); 
              setState(() => _isProcessingCheckout = true);
              
              try {
                // 1. Kirim request ke backend Laravel
                String invoiceUrl = await _apiService.processCheckout(serviceIds);
                
                // 2. Jika sukses, hapus isi keranjang lokal di HP
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('cart_items');
                
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Invoice berhasil dibuat! Membuka gerbang pembayaran...'),
                    backgroundColor: Colors.green,
                  ),
                );

                // 3. KUNCI EKSEKUSI: Panggil fungsi meluncurkan halaman pembayaran Xendit secara real-time!
                await _launchPaymentUrl(invoiceUrl, scaffoldMessenger);
                
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Checkout gagal: ${e.toString().replaceAll('Exception: ', '')}'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() => _isProcessingCheckout = false);
                  _loadCartItems(); 
                }
              }
            },
            child: const Text('PROSES', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalHarga = _calculateTotalPrice();

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text(
          'KERANJANG SAYA',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading || _isProcessingCheckout
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 65, color: Colors.grey.shade400),
                      const SizedBox(height: 15),
                      const Text(
                        'Keranjang Anda masih kosong.',
                        style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          double itemHarga = double.tryParse(item.harga) ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3))
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.design_services, size: 30, color: Colors.black),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.namaLayanan,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatRupiah(itemHarga),
                                        style: const TextStyle(color: Color(0xFFB8860B), fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                  onPressed: () => _removeItem(item.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL EST.', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                _formatRupiah(totalHarga),
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: totalHarga == 0 ? null : _handleCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              disabledBackgroundColor: Colors.grey.shade800,
                            ),
                            child: const Text(
                              'CHECKOUT',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}