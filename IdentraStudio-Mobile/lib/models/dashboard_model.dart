// lib/models/dashboard_model.dart

class DashboardData {
  final Map<String, dynamic>? chat;
  final List<dynamic> orders;
  final Map<String, dynamic>? bestOffer;
  final List<dynamic> transactions;

  DashboardData({
    required this.chat,
    required this.orders,
    required this.bestOffer,
    required this.transactions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // Kita ambil data dari dalam key 'data' sesuai struktur DashboardController
    var content = json['data'];
    return DashboardData(
      chat: content['chat'],
      orders: content['orders'] ?? [],
      bestOffer: content['best_offer'],
      transactions: content['transactions'] ?? [],
    );
  }
}