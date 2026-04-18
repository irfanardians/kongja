import 'package:flutter/material.dart';

class _TalentChatMessage {
  const _TalentChatMessage({
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

class TalentChatScreen extends StatefulWidget {
  const TalentChatScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.earningLabel,
    required this.lastSeenLabel,
  });

  final String userName;
  final String userAvatar;
  final String lastMessage;
  final String earningLabel;
  final String lastSeenLabel;

  @override
  State<TalentChatScreen> createState() => _TalentChatScreenState();
}

class _TalentChatScreenState extends State<TalentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final List<_TalentChatMessage> _messages = [
    _TalentChatMessage(
      id: 1,
      text: 'Hi ${widget.userName.split(' ').first}, thanks for joining today.',
      sender: 'talent',
      timestamp: '04:52',
    ),
    _TalentChatMessage(
      id: 2,
      text: widget.lastMessage,
      sender: 'user',
      timestamp: '04:53',
    ),
    _TalentChatMessage(
      id: 3,
      text: 'Your current earning from this chat is ${widget.earningLabel}.',
      sender: 'talent',
      timestamp: '04:54',
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _messages.add(
        _TalentChatMessage(
          id: _messages.length + 1,
          text: _messageController.text.trim(),
          sender: 'talent',
          timestamp: TimeOfDay.now().format(context),
        ),
      );
      _messageController.clear();
    });
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
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.userAvatar),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Last active ${widget.lastSeenLabel}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x8A6C422A),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.earningLabel,
                      style: const TextStyle(color: Colors.white),
                    ),
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
                  final isTalent = message.sender == 'talent';
                  return Align(
                    alignment: isTalent
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isTalent
                            ? const Color(0xFF2C2A29)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(22),
                          topRight: const Radius.circular(22),
                          bottomLeft: Radius.circular(isTalent ? 22 : 6),
                          bottomRight: Radius.circular(isTalent ? 6 : 22),
                        ),
                        boxShadow: isTalent
                            ? null
                            : const [
                                BoxShadow(
                                  color: Color(0x10000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: TextStyle(
                              color: isTalent
                                  ? Colors.white
                                  : const Color(0xFF2B2826),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message.timestamp,
                            style: TextStyle(
                              color: isTalent
                                  ? Colors.white70
                                  : const Color(0xFF8B837D),
                              fontSize: 11,
                            ),
                          ),
                        ],
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
              child: Row(
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text('Send'),
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