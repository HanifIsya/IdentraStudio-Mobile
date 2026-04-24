import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// MODEL DATA CHAT
// ─────────────────────────────────────────

class ChatContactModel {
  final String name;
  final String avatarUrl; // kosong = gunakan initials
  final String initials;
  final bool isOnline;

  const ChatContactModel({
    required this.name,
    this.avatarUrl = '',
    required this.initials,
    required this.isOnline,
  });
}

class ChatMessageModel {
  final String text;
  final bool isSentByMe;
  final String time;

  const ChatMessageModel({
    required this.text,
    required this.isSentByMe,
    required this.time,
  });
}

// ─────────────────────────────────────────
// DUMMY DATA (ganti dengan data dari backend)
// ─────────────────────────────────────────

const _dummyContact = ChatContactModel(
  name: 'Shavira Elvaretta',
  initials: 'SE',
  isOnline: true,
);

const List<ChatMessageModel> _dummyMessages = [
  ChatMessageModel(
    text:
        'Hi Shavira! I\'ve just reviewed the latest wireframes you uploaded to our Projects tab.',
    isSentByMe: false,
    time: '10:30',
  ),
  ChatMessageModel(
    text: 'Hi there! Did you go right here. What do you care about the minimapplication sprint?',
    isSentByMe: false,
    time: '10:31',
  ),
  ChatMessageModel(
    text:
        'I quite like the minimalist approach, but he wanted the "Call to Action" button on the hero section might be a bit too small to see the plain.',
    isSentByMe: true,
    time: '10:33',
  ),
  ChatMessageModel(
    text:
        'Thanks for the update! We can definitely reconsider the padding and font sizes to make it more mobile-friendly. Would you like me to send a quick mockup of the change by this afternoon?',
    isSentByMe: false,
    time: '10:35',
  ),
  ChatMessageModel(
    text: 'Yes, please! That would be great.',
    isSentByMe: true,
    time: '10:36',
  ),
];

// ─────────────────────────────────────────
// CHATS SCREEN
// ─────────────────────────────────────────

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInChat = false; // Toggle antara list & detail chat

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInChat ? _buildChatDetail() : _buildChatList();
  }

  // ── Daftar Chat ──
  Widget _buildChatList() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Text('Chats',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: buka new chat dari backend
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ New Chat',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E53),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          // ── Tabs ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: 'All Chats'),
                Tab(text: 'Active (1)'),
                Tab(text: 'Unread (1)'),
              ],
            ),
          ),

          // ── Search ──
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Chats....',
                hintStyle:
                    const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Label ──
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Chat Support',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 10),

          // ── Item Chat ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => setState(() => _isInChat = true),
              child: _buildChatItem(_dummyContact),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatContactModel contact) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF7C6AF5),
                child: Text(contact.initials,
                    style: const TextStyle(color: Colors.white)),
              ),
              if (contact.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                contact.isOnline ? 'currently online' : 'offline',
                style: TextStyle(
                    color: contact.isOnline ? Colors.green : Colors.grey,
                    fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Detail Chat ──
  Widget _buildChatDetail() {
    return SafeArea(
      child: Column(
        children: [
          // ── App Bar ──
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isInChat = false),
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 12),
                const Text('Chats',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // ── Pesan ──
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _dummyMessages.length,
              itemBuilder: (context, index) {
                final msg = _dummyMessages[index];
                return _buildBubble(msg);
              },
            ),
          ),

          // ── Input ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1C1C1E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessageModel msg) {
    return Align(
      alignment:
          msg.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: msg.isSentByMe
              ? const Color(0xFF4A90D9)
              : const Color(0xFF4A4E53),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isSentByMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isSentByMe ? 4 : 16),
          ),
        ),
        child: Text(
          msg.text,
          style:
              const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
        ),
      ),
    );
  }
}
