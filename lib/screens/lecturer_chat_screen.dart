import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/network/api_client.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_model.dart';
import 'lecturer_home_screen.dart';
import 'lecturer_schedule_screen.dart';
import 'lecturer_announcement_screen.dart';

class LecturerChatScreen extends StatefulWidget {
  const LecturerChatScreen({Key? key}) : super(key: key);

  @override
  State<LecturerChatScreen> createState() => _LecturerChatScreenState();
}

class _LecturerChatScreenState extends State<LecturerChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final int _selectedIndex = 3;
  final ApiClient _api = ApiClient();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      body: Stack(
        children: [

          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffD4F2FE), Color(0xffF8F9FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
                  child: Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400, width: 0.8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),

                // List Room Chat
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.rooms.isEmpty) {
                        return const Center(
                          child: Text(
                            'No chats available',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: provider.rooms.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final room = provider.rooms[index];
                          return _buildChatItem(room);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // MENAMBAHKAN BOTTOM NAVIGATION BAR KHUSUS LECTURER
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildChatItem(ChatRoomModel room) {
    final isGroup = room.type == 'GROUP_COURSE';
    final hasUnread = room.unreadCount > 0; // 💡 Cek status unread

    return InkWell(
      onTap: () async {
        // 💡 1. Jika ada unread, hapus indikator di UI seketika & hit endpoint mark as read
        if (room.unreadCount > 0) {
          setState(() {
            room.unreadCount = 0;
          });
          try {
            await _api.post('/chat/rooms/${room.id}/read', {});
          } catch (_) {}
        }

        Provider.of<ChatProvider>(context, listen: false).clearMessages();

        // 💡 2. Masuk ke ruang chat
        await Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => LecturerChatRoomScreen(room: room),
          ),
        );

        // 💡 3. Refresh list room saat kembali dari room chat
        if (!mounted) return;
        Provider.of<ChatProvider>(context, listen: false).loadRooms();
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            // Avatar Lingkaran Abu-abu sesuai Prototype
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xffE2E2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isGroup ? Icons.groups_outlined : Icons.person_outline,
                color: Colors.black87,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Nama Room & Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600, // 💡 Teks tebal jika unread
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    room.lastMessage ?? 'No messages yet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                      color: hasUnread ? Colors.black87 : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 💡 Timestamp & Unread Badge di Sebelah Kanan
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (room.lastMessageAt != null)
                  Text(
                    _formatTime(room.lastMessageAt!),
                    style: TextStyle(
                      fontSize: 11,
                      color: hasUnread ? const Color(0xFF2551E0) : Colors.grey,
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2551E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      room.unreadCount > 99 ? '99+' : '${room.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final icons = [
      Icons.home,
      Icons.calendar_month,
      Icons.chat_bubble,
      Icons.campaign
    ];

    const currentActiveIndex = 2;

    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final selected = currentActiveIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => const LecturerHomeScreen(),
                  ),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => const LecturerScheduleScreen(),
                  ),
                );
              } else if (index == 2) {
                // Halaman Chat saat ini
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => const LecturerAnnouncementScreen(),
                  ),
                );
              }
            },
            child: Icon(
              icons[index],
              color: selected ? const Color(0xFF4097FC) : Colors.black54,
            ),
          );
        }),
      ),
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }
}

// ===================================================================
// LECTURER CHAT ROOM SCREEN (KONTEN PESAN INDIVIDUAL/GROUP UNTUK DOSEN)
// ===================================================================

class LecturerChatRoomScreen extends StatefulWidget {
  final ChatRoomModel room;
  const LecturerChatRoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<LecturerChatRoomScreen> createState() => _LecturerChatRoomScreenState();
}

class _LecturerChatRoomScreenState extends State<LecturerChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false)
          .loadMessages(widget.room.id)
          .then((_) => _scrollToBottom());
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    final provider = Provider.of<ChatProvider>(context, listen: false);
    await provider.sendMessage(widget.room.id, content);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffD4F2FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.room.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet', style: TextStyle(color: Colors.grey)),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final msg = provider.messages[index];
                    final isMe = msg.senderId == currentUserId;
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<ChatProvider>(
                  builder: (context, provider, _) => IconButton(
                    icon: provider.isSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.send, color: Color(0xff3B44CB)),
                    onPressed: provider.isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 4),
              child: Text(
                msg.senderName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xff3B44CB) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isMe ? null : Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              msg.content,
              style: TextStyle(fontSize: 14, color: isMe ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(msg.createdAt),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}