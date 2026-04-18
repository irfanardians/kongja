// Flutter translation of cocoa/src/app/pages/Chat.tsx
//
// Semua aksi dan input harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET/POST /chat/:id
//
// Komponen reusable dibuat di folder components terpisah.

import 'package:flutter/material.dart';

import 'user_ui_shared.dart';

class _ChatMessage {
  const _ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  final int id;
  final String text;
  final String sender;
  final String timestamp;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final host = demoUserHosts.first;
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(id: 1, text: "Hi! How's your day? 😊", sender: 'host', timestamp: '04:52'),
    const _ChatMessage(id: 2, text: 'Hey Clara! My day was pretty busy.', sender: 'user', timestamp: '04:53'),
    const _ChatMessage(id: 3, text: "I'd love to hear more about it! 😊", sender: 'host', timestamp: '04:54'),
    const _ChatMessage(id: 4, text: 'Taking a break now.', sender: 'user', timestamp: '04:55'),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          id: _messages.length + 1,
          text: _messageController.text.trim(),
          sender: 'user',
          timestamp: TimeOfDay.now().format(context),
        ),
      );
      _messageController.clear();
    });
  }

  Future<void> _openGiftSheet() async {
    final gifts = const [
      ('Rose', '🌹'),
      ('Coffee', '☕'),
      ('Cake', '🍰'),
      ('Teddy', '🧸'),
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Send Gift', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: gifts
                    .map(
                      (gift) => InkWell(
                        onTap: () => Navigator.pop(context, '${gift.$1} ${gift.$2}'),
                        child: Container(
                          width: 92,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EA),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Text(gift.$2, style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: 8),
                              Text(gift.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _messages.add(
          _ChatMessage(
            id: _messages.length + 1,
            text: 'Sent a $selected',
            sender: 'user',
            timestamp: TimeOfDay.now().format(context),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8A573A), Color(0xFFB17443)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30),
                  ),
                  Stack(
                    children: [
                      CircleAvatar(radius: 20, backgroundImage: NetworkImage(host.imageUrl)),
                      const Positioned(right: -2, bottom: -2, child: UserFlagBadge(countryCode: 'PH')),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(host.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(host.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0x8A6C422A), borderRadius: BorderRadius.circular(999)),
                    child: const Text('04:52', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.sender == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF2C2A29) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(22),
                          topRight: const Radius.circular(22),
                          bottomLeft: Radius.circular(isUser ? 22 : 6),
                          bottomRight: Radius.circular(isUser ? 6 : 22),
                        ),
                        boxShadow: isUser
                            ? null
                            : const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(color: isUser ? Colors.white : const Color(0xFF2B2826), fontSize: 15),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE9E4DE))),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            filled: true,
                            fillColor: const Color(0xFFF4F4F4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: _sendMessage,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2A29),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(84, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _openGiftSheet,
                        icon: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF4C4844)),
                        label: const Text('Send Gift', style: TextStyle(color: Color(0xFF4C4844))),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.mic_rounded, color: Color(0xFF4C4844)),
                        label: const Text('Voice Note', style: TextStyle(color: Color(0xFF4C4844))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
