import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/chat_service.dart';
import '../../core/services/telephone_session_service.dart';
import '../shared/activity_session_screen.dart';
import '../shared/telephone_session_screen.dart';
import '../user/user_ui_shared.dart';
import '../shared/loading_splash.dart';
import 'talent_chat_screen.dart';
import 'talent_ui_shared.dart';

enum _TalentActivityType { message, phone, video }

class _TalentActivity {
  const _TalentActivity({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    required this.unread,
    required this.status,
    required this.lastEarning,
    required this.type,
    this.countryCode = 'US',
    this.remainingLabel,
    this.chatSession,
    this.telephoneSession,
  });

  final int id;
  final String name;
  final String message;
  final String time;
  final String avatar;
  final int unread;
  final String status;
  final String lastEarning;
  final _TalentActivityType type;
  final String countryCode;
  final String? remainingLabel;
  final ChatSessionSummary? chatSession;
  final TelephoneSessionListItem? telephoneSession;
}

class TalentMessagesScreen extends StatefulWidget {
  const TalentMessagesScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  State<TalentMessagesScreen> createState() => _TalentMessagesScreenState();
}

class _TalentMessagesScreenState extends State<TalentMessagesScreen> {
  String activeTab = 'all';
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<void>? _sessionSubscription;
  Timer? _refreshTimer;
  List<ChatSessionSummary> _chatSessions = const [];
  List<TelephoneSessionListItem> _telephoneSessions = const [];
  bool _isLoadingSessions = false;

  final activities = const [
    _TalentActivity(
      id: 2,
      name: 'Mike Chen',
      message: 'Phone call still running.',
      time: '15 min ago',
      avatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      unread: 1,
      status: 'active',
      lastEarning: '35 coins',
      type: _TalentActivityType.phone,
      countryCode: 'US',
      remainingLabel: '8 min left',
    ),
    _TalentActivity(
      id: 3,
      name: 'Emma Wilson',
      message: 'Video session is live now.',
      time: '1 hr ago',
      avatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      unread: 0,
      status: 'active',
      lastEarning: '120 coins',
      type: _TalentActivityType.video,
      countryCode: 'GB',
      remainingLabel: '14 min left',
    ),
    _TalentActivity(
      id: 5,
      name: 'Lisa Anderson',
      message: 'Thanks for your time',
      time: '3 hrs ago',
      avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
      unread: 0,
      status: 'archived',
      lastEarning: '95 coins',
      type: _TalentActivityType.video,
      countryCode: 'CA',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    talentTabRouteNotifier.addListener(_handleTabVisibilityChanged);
    _loadActivities();
    _sessionSubscription = ChatService.realtime.sessionStream.listen((_) {
      if (!mounted) {
        return;
      }
      _loadActivities(forceRefresh: true);
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted || talentTabRouteNotifier.value != '/talent-messages') {
        return;
      }
      _loadActivities(forceRefresh: true);
    });
    unawaited(ChatService.realtime.connect());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    talentTabRouteNotifier.removeListener(_handleTabVisibilityChanged);
    _sessionSubscription?.cancel();
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  late final WidgetsBindingObserver _lifecycleObserver =
      _TalentMessagesLifecycleObserver(onResumed: () {
        if (!mounted) {
          return;
        }
        _loadActivities(forceRefresh: true);
      });

  void _handleTabVisibilityChanged() {
    if (!mounted || talentTabRouteNotifier.value != '/talent-messages') {
      return;
    }
    _loadActivities(forceRefresh: true);
  }

  Future<void> _loadActivities({bool forceRefresh = false}) async {
    setState(() => _isLoadingSessions = true);
    try {
      final results = await Future.wait<dynamic>([
        ChatService.getChatSessions(forceRefresh: forceRefresh),
        TelephoneSessionService.getSessions(forceRefresh: forceRefresh),
      ]);
      final sessions = results[0] as List<ChatSessionSummary>;
      final telephoneSessions = results[1] as List<TelephoneSessionListItem>;
      if (!mounted) {
        return;
      }

      setState(() {
        _chatSessions = sessions;
        _telephoneSessions = telephoneSessions;
        _isLoadingSessions = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoadingSessions = false);
    }
  }

  _TalentActivity _chatActivityFromSession(ChatSessionSummary session) {
    final normalizedStatus = session.status.trim().toLowerCase();
    final isOpenable = session.isActiveNow;

    final statusLabel = !session.isActiveNow
        ? 'Chat expired'
        : switch (normalizedStatus) {
            'pending' => 'Menunggu balasan talent',
            'confirmed' => 'Chat aktif',
            'active' => 'Chat aktif',
            '' => 'Chat aktif',
            _ => 'Chat aktif',
          };

    return _TalentActivity(
      id: session.roomId.hashCode,
      name: session.counterpartName.trim().isNotEmpty
          ? session.counterpartName
          : 'Chat User',
      message: session.lastMessageText.trim().isNotEmpty
          ? session.lastMessageText
          : 'User memulai room chat baru.',
      time: session.lastMessageTimeLabel.trim().isNotEmpty
          ? session.lastMessageTimeLabel
          : 'Baru saja',
      avatar: session.counterpartAvatarUrl,
      unread: session.unreadCount,
      status: isOpenable ? 'active' : 'archived',
      lastEarning: isOpenable ? 'Realtime chat' : 'Expired chat',
      type: _activityTypeFromChannel(session.channelType),
      countryCode: session.counterpartCountryCode.trim().isNotEmpty
          ? session.counterpartCountryCode.trim().toUpperCase()
          : 'US',
      remainingLabel: statusLabel,
      chatSession: session,
    );
  }

  _TalentActivityType _activityTypeFromChannel(String channelType) {
    switch (channelType.trim().toLowerCase()) {
      case 'telephone':
      case 'voice':
        return _TalentActivityType.phone;
      case 'video':
        return _TalentActivityType.video;
      default:
        return _TalentActivityType.message;
    }
  }

  _TalentActivity _telephoneActivityFromSession(TelephoneSessionListItem session) {
    final now = DateTime.now();
    final isExpired = session.validUntil != null && now.isAfter(session.validUntil!);
    final isCompleted = session.status.trim().toLowerCase() == 'completed' ||
        session.closedReason.trim().toLowerCase() == 'manual_end_transaction';
    final isArchived = isExpired || isCompleted;

    final message = switch (session.callStatus.trim().toLowerCase()) {
      'ringing' => 'User sedang memanggil.',
      'ongoing' => 'Telephone call sedang aktif.',
      'ended' => 'Panggilan selesai, kuota masih tersisa.',
      _ => isArchived
          ? 'Sesi telephone sudah tidak aktif.'
          : (session.status.trim().toLowerCase() == 'pending'
                ? 'Menunggu konfirmasi talent.'
                : 'Sesi telephone siap dipakai.'),
    };

    return _TalentActivity(
      id: session.roomId.hashCode,
      name: session.counterpartName.trim().isNotEmpty
          ? session.counterpartName
          : 'Telephone User',
      message: message,
      time: _activityTimeLabel(session.updatedAt),
      avatar: session.counterpartAvatarUrl,
      unread: 0,
      status: isArchived ? 'archived' : 'active',
      lastEarning: isArchived ? 'Telephone archived' : 'Telephone session',
      type: _TalentActivityType.phone,
      countryCode: session.counterpartCountryCode.trim().isNotEmpty
          ? session.counterpartCountryCode.trim().toUpperCase()
          : 'US',
      remainingLabel: isExpired
          ? 'Sesi hangus 24 jam'
          : 'Sisa ${_durationLabel(session.remainingDurationSeconds)}',
      telephoneSession: session,
    );
  }

  Future<void> _handleActivityTap(_TalentActivity activity) async {
    if (activity.status != 'active') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_typeLabel(activity.type)} with ${activity.name} is no longer active.',
          ),
        ),
      );
      return;
    }

    switch (activity.type) {
      case _TalentActivityType.message:
        final session = activity.chatSession;
        if (session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Room chat untuk aktivitas ini belum tersedia.'),
            ),
          );
          return;
        }
        await Navigator.of(context).push(
          buildLoadingSplashRoute<void>(
            settings: const RouteSettings(name: '/talent-chat-session'),
            builder: (context) => TalentChatScreen(session: session),
          ),
        );
      case _TalentActivityType.phone:
        final telephoneSession = activity.telephoneSession;
        if (telephoneSession == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session telephone untuk aktivitas ini belum tersedia.'),
            ),
          );
          return;
        }
        await Navigator.of(context).push(
          buildLoadingSplashRoute<void>(
            settings: const RouteSettings(name: '/talent-phone-session'),
            builder: (context) => TelephoneSessionScreen(
              roomId: telephoneSession.roomId,
              fallbackPeerName: activity.name,
              fallbackPeerAvatar: activity.avatar,
            ),
          ),
        );
        if (!mounted) {
          return;
        }
        await _loadActivities(forceRefresh: true);
      case _TalentActivityType.video:
        await Navigator.of(context).push(
          buildLoadingSplashRoute<void>(
            settings: const RouteSettings(name: '/talent-video-session'),
            builder: (context) => ActivitySessionScreen(
              peerName: activity.name,
              peerAvatar: activity.avatar,
              sessionMode: ActivitySessionMode.video,
              contextLabel: 'Video session with ${activity.name}',
              statusLabel: 'Video call is active',
              trailingLabel: activity.lastEarning,
            ),
          ),
        );
    }
  }

  String _typeLabel(_TalentActivityType type) {
    switch (type) {
      case _TalentActivityType.message:
        return 'Message';
      case _TalentActivityType.phone:
        return 'Phone';
      case _TalentActivityType.video:
        return 'Video Call';
    }
  }

  IconData _typeIcon(_TalentActivityType type) {
    switch (type) {
      case _TalentActivityType.message:
        return Icons.message_rounded;
      case _TalentActivityType.phone:
        return Icons.call_rounded;
      case _TalentActivityType.video:
        return Icons.videocam_rounded;
    }
  }

  IconData _activityIcon(_TalentActivity activity) {
    return _typeIcon(activity.type);
  }

  Color _typeColor(_TalentActivityType type) {
    switch (type) {
      case _TalentActivityType.message:
        return const Color(0xFF2FA655);
      case _TalentActivityType.phone:
        return const Color(0xFF3B82F6);
      case _TalentActivityType.video:
        return const Color(0xFFDB2777);
    }
  }

  String _activityTimeLabel(DateTime? value) {
    if (value == null) {
      return 'Baru saja';
    }

    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    }
    return '${difference.inDays} day ago';
  }

  String _durationLabel(int totalSeconds) {
    final minutes = (totalSeconds / 60).ceil();
    if (minutes <= 0) {
      return '00 min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final allActivities = <_TalentActivity>[
      ..._telephoneSessions.map(_telephoneActivityFromSession),
      ..._chatSessions.map(_chatActivityFromSession),
      ...activities.where((activity) => activity.type != _TalentActivityType.phone),
    ];
    final filtered = allActivities.where((activity) {
      final matchesTab = activeTab == 'all' || activity.status == activeTab;
      final matchesQuery =
          query.isEmpty ||
          activity.name.toLowerCase().contains(query) ||
          activity.message.toLowerCase().contains(query) ||
          _typeLabel(activity.type).toLowerCase().contains(query);
      return matchesTab && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: talentBg,
      bottomNavigationBar: widget.showBottomNav
          ? const TalentBottomNav(currentRoute: '/talent-messages')
          : null,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [talentAmberDark, talentAmber],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search activity...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFFA79F97),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
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
                  child: _isLoadingSessions && filtered.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                      ? RefreshIndicator(
                            onRefresh: () =>
                              _loadActivities(forceRefresh: true),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            children: const [
                              SizedBox(height: 160),
                              Center(
                                child: Text(
                                  'Belum ada room chat.',
                                  style: TextStyle(color: Color(0xFF8B837D)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                            onRefresh: () =>
                              _loadActivities(forceRefresh: true),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final activity = filtered[index];
                              final typeColor = _typeColor(activity.type);
                              final avatarProvider =
                                  activity.avatar.trim().isNotEmpty
                                  ? NetworkImage(activity.avatar)
                                  : null;

                              return TalentSectionCard(
                                padding: const EdgeInsets.all(14),
                                child: InkWell(
                                  onTap: () => _handleActivityTap(activity),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Row(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          CircleAvatar(
                                            radius: 28,
                                            backgroundColor: const Color(
                                              0xFFF4E4D3,
                                            ),
                                            backgroundImage: avatarProvider,
                                            child: avatarProvider == null
                                                ? Text(
                                                    activity.name.isNotEmpty
                                                        ? activity.name[0]
                                                              .toUpperCase()
                                                        : '?',
                                                    style: const TextStyle(
                                                      color: Color(0xFF8A573A),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          Positioned(
                                            right: -2,
                                            bottom: -2,
                                            child: UserFlagBadge(
                                              countryCode: activity.countryCode,
                                              size: 22,
                                              borderWidth: 2,
                                              innerPadding: 2,
                                            ),
                                          ),
                                          if (activity.unread > 0)
                                            Positioned(
                                              top: -4,
                                              right: -2,
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE34B57),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${activity.unread}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    activity.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  activity.time,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFFAAA39C),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              activity.message,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: activity.unread > 0
                                                    ? const Color(0xFF272421)
                                                    : const Color(0xFF89827C),
                                                fontWeight: activity.unread > 0
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: typeColor.withValues(
                                                      alpha: 0.12,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        _activityIcon(activity),
                                                        size: 14,
                                                        color: typeColor,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        _typeLabel(
                                                          activity.type,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: typeColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        activity.status ==
                                                            'active'
                                                        ? const Color(
                                                            0xFFEAF8EF,
                                                          )
                                                        : const Color(
                                                            0xFFF3F0EC,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    activity.status == 'active'
                                                        ? 'Active'
                                                        : 'Archived',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          activity.status ==
                                                              'active'
                                                          ? const Color(
                                                              0xFF2FA655,
                                                            )
                                                          : const Color(
                                                              0xFF8A837D,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  activity.status == 'active'
                                                      ? (activity
                                                                .remainingLabel ??
                                                            'Realtime update aktif')
                                                      : 'Archived activity',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        activity.status ==
                                                            'active'
                                                        ? const Color(
                                                            0xFF2FA655,
                                                          )
                                                        : const Color(
                                                            0xFF8A837D,
                                                          ),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  activity.lastEarning,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF2FA655),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.tune_rounded,
                                          color: Color(0xFF8C857E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF6F6862),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TalentMessagesLifecycleObserver with WidgetsBindingObserver {
  _TalentMessagesLifecycleObserver({required this.onResumed});

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
