import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/chat_notification_service.dart';
import '../../core/services/chat_service.dart';
import '../../core/config/api_config.dart';
import 'user_ui_shared.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.session, this.host});

  final ChatSessionSummary? session;
  final DemoUserHost? host;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Duration _duplicateSendWindow = Duration(seconds: 20);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageData> _messages = [];
  final Set<String> _pendingMessageKeys = <String>{};
  final Set<String> _failedMessageKeys = <String>{};
  final Set<String> _readMessageKeys = <String>{};
  StreamSubscription<ChatMessageData>? _messageSubscription;
  StreamSubscription<ChatReadReceiptData>? _readReceiptSubscription;
  Timer? _pollingTimer;
  bool _isLoading = true;
  bool _isSending = false;

  DemoUserHost get _host => widget.host ?? demoUserHosts.first;
  String get _roomId => widget.session?.roomId ?? '';
  String get _counterpartAccountId =>
      widget.session?.counterpartAccountId ?? '';
  String get _currentAccountId => AuthSession.instance.accountId.trim();

  @override
  void initState() {
    super.initState();
    if (_roomId.isEmpty) {
      _isLoading = false;
      return;
    }
    ChatNotificationService.instance.setActiveRoom(_roomId);
    _subscribeRealtime();
    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    ChatNotificationService.instance.clearActiveRoom(_roomId);
    _pollingTimer?.cancel();
    _messageSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _roomId.isEmpty || _isSending) {
        return;
      }
      unawaited(_loadMessages(forceRefresh: true, showLoading: false));
    });
  }

  Future<void> _subscribeRealtime() async {
    await ChatService.realtime.connect();
    await ChatService.realtime.ensureRoomSubscription(_roomId);
    _messageSubscription = ChatService.realtime.messageStream.listen((event) {
      if (!mounted) {
        return;
      }

      if (event.roomId.isNotEmpty && event.roomId != _roomId) {
        return;
      }

      setState(() {
        _upsertMessage(
          ChatMessageData(
            id: event.id,
            roomId: _roomId,
            text: event.text,
            senderRole: event.senderRole,
            senderAccountId: event.senderAccountId,
            timestampLabel: event.timestampLabel,
            createdAt: event.createdAt,
            roomStatus: event.roomStatus,
            clientMessageId: event.clientMessageId,
          ),
        );
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      });
      _scheduleScrollToLatest();
    });
    _readReceiptSubscription = ChatService.realtime.readReceiptStream.listen((event) {
      if (!mounted || event.roomId != _roomId) {
        return;
      }

      setState(() {
        _applyReadReceipt(event);
      });
    });
  }

  Future<void> _loadMessages({
    bool forceRefresh = false,
    bool showLoading = true,
  }) async {
    if (_roomId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      final messages = await ChatService.getMessages(
        _roomId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        final mergedMessages = _mergeFetchedMessages(messages);
        _messages
          ..clear()
          ..addAll(mergedMessages..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
        _reconcileMessageStates();
        _isLoading = false;
      });
      _scheduleScrollToLatest();
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat pesan: $error')));
    }
  }

  Future<void> _sendMessage() async {
    final draft = _messageController.text.trim();
    if (draft.isEmpty || _isSending) {
      return;
    }

    if (_shouldSuppressDuplicateSend(draft)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesan yang sama baru saja dikirim.'),
        ),
      );
      return;
    }

    if (_roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room chat belum tersedia untuk percakapan ini.'),
        ),
      );
      return;
    }

    final clientMessageId = 'local-${DateTime.now().microsecondsSinceEpoch}';
    final optimisticMessage = ChatMessageData(
      id: clientMessageId,
      roomId: _roomId,
      text: draft,
      senderRole: 'user',
      senderAccountId: _currentAccountId,
      timestampLabel: _timeLabel(DateTime.now()),
      createdAt: DateTime.now(),
      roomStatus: widget.session?.status ?? '',
      clientMessageId: clientMessageId,
    );

    _messageController.clear();
    setState(() {
      _isSending = true;
      _markPending(clientMessageId);
      _upsertMessage(optimisticMessage);
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
    _scheduleScrollToLatest();
    try {
      final sentMessage = await ChatService.sendMessage(
        _roomId,
        draft,
        clientMessageId: clientMessageId,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _markSent(clientMessageId);
        _upsertMessage(
          ChatMessageData(
            id: sentMessage.id,
            roomId: _roomId,
            text: sentMessage.text,
            senderRole: sentMessage.senderRole,
            senderAccountId: sentMessage.senderAccountId,
            timestampLabel: sentMessage.timestampLabel,
            createdAt: sentMessage.createdAt,
            roomStatus: sentMessage.roomStatus,
            clientMessageId: sentMessage.clientMessageId,
          ),
        );
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _isSending = false;
      });
      _scheduleScrollToLatest();
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _markFailed(clientMessageId);
        _isSending = false;
      });
      _messageController.text = draft;
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _markFailed(clientMessageId);
        _isSending = false;
      });
      _messageController.text = draft;
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan: $error')));
    }
  }

  Future<void> _retryMessage(ChatMessageData failedMessage) async {
    if (_isSending) {
      return;
    }

    final messageKey = _messageKeyOf(failedMessage);
    setState(() {
      _isSending = true;
      _markPending(messageKey);
    });
    _scheduleScrollToLatest();

    try {
      final sentMessage = await ChatService.sendMessage(
        _roomId,
        failedMessage.text,
        clientMessageId: failedMessage.clientMessageId,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _markSent(messageKey);
        _upsertMessage(
          ChatMessageData(
            id: sentMessage.id,
            roomId: _roomId,
            text: sentMessage.text,
            senderRole: sentMessage.senderRole,
            senderAccountId: sentMessage.senderAccountId,
            timestampLabel: sentMessage.timestampLabel,
            createdAt: sentMessage.createdAt,
            roomStatus: sentMessage.roomStatus,
            clientMessageId: sentMessage.clientMessageId,
          ),
        );
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _isSending = false;
      });
      _scheduleScrollToLatest();
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _markFailed(messageKey);
        _isSending = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _markFailed(messageKey);
        _isSending = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim ulang pesan: $error')));
    }
  }

  void _upsertMessage(ChatMessageData nextMessage) {
    final existingIndex = _messages.indexWhere(
      (message) =>
          message.id == nextMessage.id ||
          (nextMessage.clientMessageId.isNotEmpty &&
              message.clientMessageId == nextMessage.clientMessageId),
    );

    if (existingIndex >= 0) {
      _messages[existingIndex] = nextMessage;
      return;
    }

    _messages.add(nextMessage);
  }

  void _markPending(String messageKey) {
    _failedMessageKeys.remove(messageKey);
    _pendingMessageKeys.add(messageKey);
  }

  void _markSent(String messageKey) {
    _pendingMessageKeys.remove(messageKey);
    _failedMessageKeys.remove(messageKey);
  }

  void _markFailed(String messageKey) {
    _pendingMessageKeys.remove(messageKey);
    _failedMessageKeys.add(messageKey);
  }

  void _reconcileMessageStates() {
    final activeKeys = _messages.map(_messageKeyOf).toSet();
    _pendingMessageKeys.removeWhere((key) => !activeKeys.contains(key));
    _failedMessageKeys.removeWhere((key) => !activeKeys.contains(key));
    _readMessageKeys.removeWhere((key) => !activeKeys.contains(key));
  }

  String _messageKeyOf(ChatMessageData message) {
    final clientMessageId = message.clientMessageId.trim();
    if (clientMessageId.isNotEmpty) {
      return clientMessageId;
    }
    return message.id;
  }

  _OutgoingMessageState _outgoingStateFor(ChatMessageData message) {
    final messageKey = _messageKeyOf(message);
    if (_failedMessageKeys.contains(messageKey)) {
      return _OutgoingMessageState.failed;
    }
    if (_pendingMessageKeys.contains(messageKey)) {
      return _OutgoingMessageState.pending;
    }
    if (_readMessageKeys.contains(messageKey)) {
      return _OutgoingMessageState.read;
    }
    if (_isReadByCounterpart(message)) {
      return _OutgoingMessageState.read;
    }
    return _OutgoingMessageState.sent;
  }

  List<ChatMessageData> _mergeFetchedMessages(List<ChatMessageData> fetchedMessages) {
    final mergedMessages = <ChatMessageData>[...fetchedMessages];
    final existingKeys = <String>{
      for (final message in mergedMessages) _messageKeyOf(message),
    };

    for (final localMessage in _messages) {
      final localState = _outgoingStateFor(localMessage);
      final shouldKeepLocal =
          localState == _OutgoingMessageState.pending ||
          localState == _OutgoingMessageState.failed;
      final messageKey = _messageKeyOf(localMessage);
      if (!shouldKeepLocal || existingKeys.contains(messageKey)) {
        continue;
      }
      mergedMessages.add(localMessage);
      existingKeys.add(messageKey);
    }

    return mergedMessages;
  }

  bool _isReadByCounterpart(ChatMessageData outgoingMessage) {
    for (final message in _messages) {
      if (_isCurrentUserMessage(message)) {
        continue;
      }
      if (!message.createdAt.isBefore(outgoingMessage.createdAt)) {
        return true;
      }
    }
    return false;
  }

  bool _shouldSuppressDuplicateSend(String draft) {
    final normalizedDraft = draft.trim();
    if (normalizedDraft.isEmpty) {
      return false;
    }

    ChatMessageData? latestOutgoing;
    ChatMessageData? latestIncoming;
    for (final message in _messages) {
      if (_isCurrentUserMessage(message)) {
        if (latestOutgoing == null ||
            message.createdAt.isAfter(latestOutgoing.createdAt)) {
          latestOutgoing = message;
        }
      } else if (latestIncoming == null ||
          message.createdAt.isAfter(latestIncoming.createdAt)) {
        latestIncoming = message;
      }
    }

    if (latestOutgoing == null) {
      return false;
    }

    final sameText = latestOutgoing.text.trim() == normalizedDraft;
    final recentEnough = DateTime.now().difference(latestOutgoing.createdAt) <=
        _duplicateSendWindow;
    final hasIncomingAfterOutgoing = latestIncoming != null &&
        latestIncoming.createdAt.isAfter(latestOutgoing.createdAt);
    return sameText && recentEnough && !hasIncomingAfterOutgoing;
  }

  void _applyReadReceipt(ChatReadReceiptData receipt) {
    ChatMessageData? boundaryMessage;
    if (receipt.lastReadMessageId.trim().isNotEmpty) {
      for (final message in _messages) {
        if (message.id == receipt.lastReadMessageId) {
          boundaryMessage = message;
          break;
        }
      }
    }

    final boundaryTime = boundaryMessage?.createdAt ?? receipt.readAt;
    for (final message in _messages) {
      if (!_isCurrentUserMessage(message)) {
        continue;
      }
      if (!message.createdAt.isAfter(boundaryTime)) {
        _readMessageKeys.add(_messageKeyOf(message));
      }
    }
  }

  String _timeLabel(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildAvatar(String imageUrl, String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final resolvedImageUrl = ApiConfig.resolveExternalUrl(imageUrl);
    final provider = _isDisplayableNetworkUrl(resolvedImageUrl)
        ? NetworkImage(resolvedImageUrl)
        : null;

    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFF4E4D3),
      backgroundImage: provider,
      child: provider == null
          ? Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF8A573A),
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }

  bool _isDisplayableNetworkUrl(String value) {
    final parsed = Uri.tryParse(value);
    if (parsed == null) {
      return false;
    }

    return parsed.hasScheme &&
        (parsed.scheme == 'http' || parsed.scheme == 'https') &&
        parsed.host.trim().isNotEmpty;
  }

  void _scheduleScrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.session?.counterpartName.trim().isNotEmpty == true
        ? widget.session!.counterpartName
        : _host.name;
    final subtitle = widget.session?.status.trim().isNotEmpty == true
        ? 'Status: ${widget.session!.status}'
        : _host.description;
    final avatarUrl =
        widget.session?.counterpartAvatarUrl.trim().isNotEmpty == true
        ? widget.session!.counterpartAvatarUrl
        : _host.imageUrl;
    final countryCode =
      widget.session?.counterpartCountryCode.trim().isNotEmpty == true
      ? widget.session!.counterpartCountryCode.trim().toUpperCase()
      : _host.countryCode;

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
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildAvatar(avatarUrl, title),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: UserFlagBadge(
                          countryCode: countryCode,
                          size: 22,
                          borderWidth: 2,
                          innerPadding: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
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
                      widget.session?.lastMessageTimeLabel ?? '--:--',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _roomId.isEmpty
                  ? const Center(
                      child: Text(
                        'Room chat backend belum tersedia untuk percakapan ini.',
                        style: TextStyle(color: Color(0xFF8B837D)),
                      ),
                    )
                  : _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada pesan di room ini.',
                        style: TextStyle(color: Color(0xFF8B837D)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          _loadMessages(forceRefresh: true, showLoading: false),
                      child: ListView.builder(
                      controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUser = _isCurrentUserMessage(message);
                          final outgoingState = isUser
                              ? _outgoingStateFor(message)
                              : null;
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: isUser && outgoingState == _OutgoingMessageState.failed
                                  ? () => _retryMessage(message)
                                  : null,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                constraints: const BoxConstraints(maxWidth: 280),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFF2C2A29)
                                      : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(22),
                                    topRight: const Radius.circular(22),
                                    bottomLeft: Radius.circular(isUser ? 22 : 6),
                                    bottomRight: Radius.circular(isUser ? 6 : 22),
                                  ),
                                  boxShadow: isUser
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
                                        color: isUser
                                            ? Colors.white
                                            : const Color(0xFF2B2826),
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (isUser && outgoingState == _OutgoingMessageState.failed)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Text(
                                          'Tap untuk kirim ulang',
                                          style: TextStyle(
                                            color: Color(0xFFFFC9C9),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          message.timestampLabel,
                                          style: TextStyle(
                                            color: isUser
                                                ? Colors.white70
                                                : const Color(0xFF8B837D),
                                            fontSize: 11,
                                          ),
                                        ),
                                        if (isUser) ...[
                                          const SizedBox(width: 6),
                                          _buildOutgoingStatusIcon(outgoingState!),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
                          textInputAction: TextInputAction.send,
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
                        child: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Send'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur gift belum tersedia di backend chat.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.card_giftcard_rounded,
                          color: Color(0xFF4C4844),
                        ),
                        label: const Text(
                          'Send Gift',
                          style: TextStyle(color: Color(0xFF4C4844)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur voice note belum tersedia di backend chat.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.mic_rounded,
                          color: Color(0xFF4C4844),
                        ),
                        label: const Text(
                          'Voice Note',
                          style: TextStyle(color: Color(0xFF4C4844)),
                        ),
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

  bool _isCurrentUserMessage(ChatMessageData message) {
    return ChatService.isMessageFromCurrentActor(
      message,
      counterpartAccountId: _counterpartAccountId,
    );
  }

  Widget _buildOutgoingStatusIcon(_OutgoingMessageState state) {
    switch (state) {
      case _OutgoingMessageState.pending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.6,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      case _OutgoingMessageState.sent:
        return const Icon(Icons.done_rounded, size: 14, color: Colors.white70);
      case _OutgoingMessageState.read:
        return const Icon(
          Icons.done_all_rounded,
          size: 16,
          color: Color(0xFF8ED2FF),
        );
      case _OutgoingMessageState.failed:
        return const Icon(
          Icons.error_outline_rounded,
          size: 14,
          color: Color(0xFFFFB4B4),
        );
    }
  }
}

enum _OutgoingMessageState { pending, sent, read, failed }
