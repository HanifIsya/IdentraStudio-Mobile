// lib/projects/chat_room_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

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

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _initChatData();
  }

  Future<void> _initChatData() async {
    await _loadCurrentUser();
    await _fetchMessages();
  }

  // 1. Ambil ID User yang Sedang Login dari SharedPreferences
  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('user_id') ?? 0;
    });
  }

  // 2. Ambil Daftar Pesan dari API
  Future<void> _fetchMessages() async {
    try {
      final messages = await _apiService.getProjectMessages(widget.projectId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat pesan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 3. Kirim Pesan Baru
  Future<void> _sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      bool success = await _apiService.sendProjectMessage(widget.projectId, text);
      if (success) {
        await _fetchMessages(); // Refresh obrolan
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim pesan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  // Helper untuk Scroll ke Bawah
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

  // Helper Format Jam sederhana
  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.namaLayanan,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              "Project Workspace Chat #${widget.projectId}",
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
            onPressed: _fetchMessages,
          )
        ],
      ),
      body: Column(
        children: [
          // ===================================================================
          // AREA DAFTAR CHAT
          // ===================================================================
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada pesan. Mulai obrolan sekarang!",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchMessages,
                        color: const Color(0xFFD4AF37),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];

                            // KUNCI MEMBEDAKAN SISI CHAT (ME vs OTHER)
                            final int senderId = msg['user_id'] ?? msg['sender_id'] ?? 0;
                            final bool isMe = (senderId == _currentUserId);

                            final String senderName = msg['user']?['name'] ?? 'Pengirim';

                            return _buildChatBubble(
                              message: msg['message'] ?? '',
                              time: _formatTime(msg['created_at']),
                              senderName: senderName,
                              isMe: isMe,
                            );
                          },
                        ),
                      ),
          ),

          // ===================================================================
          // AREA INPUT PESAN DI BOTTOM
          // ===================================================================
          Container(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "Ketik pesan...",
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: _isSending ? null : _sendMessage,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    child: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BUBBLE CHAT
  Widget _buildChatBubble({
    required String message,
    required String time,
    required String senderName,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFD4AF37) // Warna Gold/Kuning untuk Pesan Saya
              : const Color(0xFF1A1A1A), // Warna Dark Grey untuk Pesan Lawan
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          border: Border.all(
            color: isMe ? Colors.transparent : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Label Nama Pengirim jika pesan dari Lawan
            if (!isMe) ...[
              Text(
                senderName,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
            ],

            // Text Pesan
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.black : Colors.white,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),

            // Time Stamp
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.black54 : Colors.white38,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}