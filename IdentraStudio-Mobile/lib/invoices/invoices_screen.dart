// lib/invoices/invoices_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  void _fetchInvoices() async {
    try {
      var data = await _apiService.getInvoices();
      setState(() {
        _invoices = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _downloadPdfInvoice(String pdfUrl) async {
    final Uri url = Uri.parse(pdfUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar('Gagal membuka/mengunduh dokumen PDF Invoice.');
    }
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
        title: const Text(
          'RIWAYAT PEMBAYARAN',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : _invoices.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada transaksi pembayaran.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _fetchInvoices(),
                  color: const Color(0xFFD4AF37),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = _invoices[index];
                      final List<dynamic> layananList = invoice['layanan_list'] ?? [];

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
                            // Header Invoice ID & Badge Status Lunas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    invoice['invoice_id'] ?? '-',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'PAID',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              invoice['tanggal'] ?? '',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                            ),
                            const Divider(color: Colors.white10, height: 25),

                            // Rincian Layanan yang Dibeli
                            const Text(
                              'Layanan Terkait:',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: layananList.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: Color(0xFFD4AF37), size: 14),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.toString(),
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Tombol Download PDF Invoice
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: OutlinedButton.icon(
                                onPressed: () => _downloadPdfInvoice(invoice['pdf_url']),
                                icon: const Icon(Icons.picture_as_pdf, size: 18),
                                label: const Text(
                                  'DOWNLOAD INVOICE PDF',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFD4AF37),
                                  side: const BorderSide(color: Color(0xFFD4AF37)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
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