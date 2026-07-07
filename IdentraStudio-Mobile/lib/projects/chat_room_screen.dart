// lib/projects/chat_room_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // Memastikan path ApiService sesuai

class ChatRoomScreen extends StatefulWidget {
  final int projectId;
  final String namaLayanan;

  const ChatRoomScreen({
    super.key,
    required this.projectId,
    required this.namaLayanan,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ProjectsScreenState {}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<dynamic> _messages = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _fetchChatHistory();
  }

  // 1. Ambil ID User yang login dari SharedPreferences untuk membedakan balon chat kiri/kanan
  void _loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('user_id');
    });
  }

  // 2. Ambil riwayat chat riil dari server Laravel
  void _fetchChatHistory() async {
    try {
      var data = await _apiService.getChatMessages(widget.projectId);
      setState(() {
        _messages = data;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 3. Mengirim pesan baru ke database Laravel
  void _handleSendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      var newMsg = await _apiService.sendChatMessage(widget.projectId, text);
      setState(() {
        _messages.add(newMsg); // Langsung selipkan pesan baru ke UI secara real-time
      });
      _scrollToBottom();
    } catch (e) {
      _showSnackBar('Gagal mengirim pesan: $e');
    }
  }

  // Helper agar otomatis scroll ke chat paling bawah/baru
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      DateTime parsed = DateTime.parse(timestamp).toLocal();
      return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.namaLayanan,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Room ID: #${widget.projectId}',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _fetchChatHistory, // Tombol refresh manual untuk menarik chat baru
          )
        ],
      ),
      body: Column(
        children: [
          // Bagian Tampilan Utama Riwayat Chat
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada obrolan. Silakan kirim pesan brief awal.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final chat = _messages[index];
                          
                          // Jika sender_id sama dengan user_id yang login, letakkan di KANAN (emas)
                          // Jika tidak sama, berarti dikirim oleh Admin, letakkan di KIRI (abu-abu gelap)
                          final bool isMe = chat['sender_id'] == _currentUserId;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFFD4AF37) : const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat['message'] ?? '',
                                    style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 14),
                                  ),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      _formatTime(chat['created_at']),
                                      style: TextStyle(color: isMe ? Colors.black54 : Colors.white54, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Bagian Input Bar di Bagian Bawah
          Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan brief...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                      fillColor: const Color(0xFF1A1A1A),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: const Color(0xFFD4AF37),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black, size: 18),
                    onPressed: _handleSendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}