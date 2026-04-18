// Flutter translation of cocoa/src/app/pages/TalentMessages.tsx

import 'package:flutter/material.dart';

import 'talent_ui_shared.dart';

class _TalentConversation {
  const _TalentConversation({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    required this.unread,
    required this.status,
    required this.lastEarning,
  });

  final int id;
  final String name;
  final String message;
  final String time;
  final String avatar;
  final int unread;
  final String status;
  final String lastEarning;
}

class TalentMessagesScreen extends StatefulWidget {
  const TalentMessagesScreen({Key? key}) : super(key: key);

  @override
  State<TalentMessagesScreen> createState() => _TalentMessagesScreenState();
}

class _TalentMessagesScreenState extends State<TalentMessagesScreen> {
  String activeTab = 'all';
  final TextEditingController _searchController = TextEditingController();

  final conversations = const [
    _TalentConversation(id: 1, name: 'Sarah Johnson', message: 'Thank you for the chat!', time: '2 min ago', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', unread: 2, status: 'active', lastEarning: '50 coins'),
    _TalentConversation(id: 2, name: 'Mike Chen', message: 'Are you available now?', time: '15 min ago', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', unread: 1, status: 'active', lastEarning: '35 coins'),
    _TalentConversation(id: 3, name: 'Emma Wilson', message: 'Great conversation!', time: '1 hr ago', avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', unread: 0, status: 'active', lastEarning: '120 coins'),
    _TalentConversation(id: 4, name: 'David Lee', message: 'See you next time!', time: '2 hrs ago', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', unread: 0, status: 'archived', lastEarning: '80 coins'),
    _TalentConversation(id: 5, name: 'Lisa Anderson', message: 'Thanks for your time', time: '3 hrs ago', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', unread: 0, status: 'archived', lastEarning: '95 coins'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = conversations.where((conv) {
      final matchesTab = activeTab == 'all' || conv.status == activeTab;
      final matchesQuery = query.isEmpty || conv.name.toLowerCase().contains(query) || conv.message.toLowerCase().contains(query);
      return matchesTab && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: talentBg,
      bottomNavigationBar: const TalentBottomNav(currentRoute: '/talent-messages'),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [talentAmberDark, talentAmber], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Messages', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA79F97)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TalentSectionCard(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          _tabButton('all', 'All'),
                          _tabButton('active', 'Active'),
                          _tabButton('archived', 'Archived'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No conversations found', style: TextStyle(color: Color(0xFF8B837D))))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final conv = filtered[index];
                            return TalentSectionCard(
                              padding: const EdgeInsets.all(14),
                              child: InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open chat with ${conv.name}')));
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Row(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        CircleAvatar(radius: 28, backgroundImage: NetworkImage(conv.avatar)),
                                        Positioned(
                                          right: -2,
                                          bottom: -2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                                            child: const Text('US', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                          ),
                                        ),
                                        if (conv.unread > 0)
                                          Positioned(
                                            top: -4,
                                            right: -2,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: const BoxDecoration(color: Color(0xFFE34B57), shape: BoxShape.circle),
                                              child: Center(child: Text('${conv.unread}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
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
                                              Expanded(child: Text(conv.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                                              Text(conv.time, style: const TextStyle(fontSize: 12, color: Color(0xFFAAA39C))),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            conv.message,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14, color: conv.unread > 0 ? const Color(0xFF272421) : const Color(0xFF89827C), fontWeight: conv.unread > 0 ? FontWeight.w600 : FontWeight.w400),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: conv.status == 'active' ? const Color(0xFFEAF8EF) : const Color(0xFFF3F0EC),
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                                child: Text(conv.status == 'active' ? 'Active' : 'Archived', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: conv.status == 'active' ? const Color(0xFF2FA655) : const Color(0xFF8A837D))),
                                              ),
                                              const SizedBox(width: 8),
                                              Text('🪙 ${conv.lastEarning}', style: const TextStyle(fontSize: 12, color: Color(0xFF2FA655), fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded, color: Color(0xFF8C857E))),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String value, String label) {
    final isActive = activeTab == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => activeTab = value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? talentAmberDark : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isActive ? Colors.white : const Color(0xFF6F6862), fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
