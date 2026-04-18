// Flutter translation of cocoa/src/app/pages/Messages.tsx
//
// Semua aksi dan input harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET /messages
//
// Komponen reusable dibuat di folder components terpisah.

import 'package:flutter/material.dart';

import 'user_ui_shared.dart';

class _Conversation {
  const _Conversation({
    required this.hostId,
    required this.lastMessage,
    required this.timestamp,
    required this.unread,
    required this.isActive,
    this.remainingMinutes,
  });

  final int hostId;
  final String lastMessage;
  final String timestamp;
  final bool unread;
  final bool isActive;
  final int? remainingMinutes;
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  DemoUserHost? selectedHost;
  bool showExpiredModal = false;
  bool showAlert = false;

  final conversations = const [
    _Conversation(hostId: 1, lastMessage: "I'd love to hear more about it! 😊", timestamp: '2m ago', unread: true, isActive: true, remainingMinutes: 5),
    _Conversation(hostId: 2, lastMessage: 'Thanks for chatting today!', timestamp: '1h ago', unread: false, isActive: false),
    _Conversation(hostId: 4, lastMessage: 'See you soon! 💕', timestamp: '3h ago', unread: true, isActive: true, remainingMinutes: 10),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = conversations.where((conversation) {
      final host = demoUserHosts.firstWhere((item) => item.id == conversation.hostId);
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) return true;
      return host.name.toLowerCase().contains(query) || conversation.lastMessage.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const UserBottomNav(currentRoute: '/messages'),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Messages', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA5A09A)),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE9E4DE)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE9E4DE)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final conversation = filtered[index];
                      final host = demoUserHosts.firstWhere((item) => item.id == conversation.hostId);
                      return InkWell(
                        onTap: () {
                          if (conversation.isActive) {
                            Navigator.pushNamed(context, '/chat');
                          } else {
                            setState(() {
                              selectedHost = host;
                              showExpiredModal = true;
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFF0ECE8))),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(radius: 28, backgroundImage: NetworkImage(host.imageUrl)),
                                  Positioned(right: 0, bottom: 0, child: UserFlagBadge(countryCode: host.countryCode)),
                                  if (host.isOnline)
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF37C35B),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(host.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                                        Text(conversation.timestamp, style: const TextStyle(fontSize: 12, color: Color(0xFF9B948D))),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      conversation.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: conversation.unread ? const Color(0xFF2E2B28) : const Color(0xFF8A847E),
                                        fontWeight: conversation.unread ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          conversation.isActive ? Icons.message_rounded : Icons.schedule_rounded,
                                          size: 14,
                                          color: conversation.isActive ? const Color(0xFF2FA655) : const Color(0xFFB2AAA1),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          conversation.isActive
                                              ? 'Active - ${conversation.remainingMinutes}m left'
                                              : 'Chat expired',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: conversation.isActive ? const Color(0xFF2FA655) : const Color(0xFFB2AAA1),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (conversation.unread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: const BoxDecoration(color: userAmberDark, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (showAlert)
              Positioned(
                left: 24,
                right: 24,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: const Color(0xFFD54646), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('You have unread messages!', style: TextStyle(color: Colors.white))),
                      IconButton(
                        onPressed: () => setState(() => showAlert = false),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            if (showExpiredModal && selectedHost != null)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0x80000000),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(color: Color(0xFFFFEDD9), shape: BoxShape.circle),
                            child: const Icon(Icons.schedule_rounded, size: 34, color: Color(0xFFD18734)),
                          ),
                          const SizedBox(height: 14),
                          const Text('Chat Session Expired', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            'Your chat session with ${selectedHost!.name} has ended.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF817A74)),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFFF3E4), Color(0xFFFFE8D2)]),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(radius: 24, backgroundImage: NetworkImage(selectedHost!.imageUrl)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(selectedHost!.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      const Text('Continue chatting', style: TextStyle(color: Color(0xFF847D76), fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Text('🪙 ${selectedHost!.pricePerMin} / min', style: const TextStyle(fontWeight: FontWeight.w700, color: userAmberDark)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                setState(() => showExpiredModal = false);
                                Navigator.pushNamed(context, '/chat');
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: userAmberDark,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Yes, Start New Chat'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => setState(() => showExpiredModal = false),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side: const BorderSide(color: Color(0xFFE8E1D8)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('No, Maybe Later'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 24,
              bottom: 100,
              child: FloatingActionButton.small(
                backgroundColor: userAmberDark,
                foregroundColor: Colors.white,
                onPressed: () => setState(() => showAlert = !showAlert),
                child: const Icon(Icons.notifications_active_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
