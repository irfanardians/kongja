import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/config/api_config.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/telephone_session_service.dart';
import '../../core/services/talent_public_profile_service.dart';
import '../shared/activity_session_screen.dart';
import '../shared/loading_splash.dart';
import '../shared/telephone_session_screen.dart';
import 'chat_screen.dart';
import 'user_ui_shared.dart';

const Color _userInboxHeaderStart = Color(0xFF8A573A);
const Color _userInboxHeaderEnd = Color(0xFFB17443);
const Color _userInboxSurface = Color(0xFFF5F1E8);

enum _UserActivityType { message, phone, video }

class _UserActivity {
  const _UserActivity({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    required this.unread,
    required this.status,
    required this.trailingLabel,
    required this.type,
    this.country = '',
    this.countryCode = 'US',
    this.remainingLabel,
    this.chatSession,
    this.telephoneSession,
    this.host,
  });

  final int id;
  final String name;
  final String message;
  final String time;
  final String avatar;
  final int unread;
  final String status;
  final String trailingLabel;
  final _UserActivityType type;
  final String country;
  final String countryCode;
  final String? remainingLabel;
  final ChatSessionSummary? chatSession;
  final TelephoneSessionListItem? telephoneSession;
  final DemoUserHost? host;
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<void>? _sessionSubscription;
  Timer? _refreshTimer;
  List<ChatSessionSummary> _chatSessions = const [];
  List<TelephoneSessionListItem> _telephoneSessions = const [];
  Map<String, TalentPublicProfileData> _talentProfilesByAccountId = const {};
  bool _isLoadingSessions = false;
  String _activeTab = 'all';

  final List<_UserActivity> _activities = <_UserActivity>[
    const _UserActivity(
      id: 1001,
      name: 'Clara',
      message: 'Video call is still running.',
      time: '4 min ago',
      avatar:
          'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=800',
      unread: 0,
      status: 'active',
      trailingLabel: '260 coins',
      type: _UserActivityType.video,
      countryCode: 'PH',
      remainingLabel: '12 min left',
    ),
    const _UserActivity(
      id: 1002,
      name: 'Emma',
      message: 'Phone call still active.',
      time: '12 min ago',
      avatar:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
      unread: 0,
      status: 'active',
      trailingLabel: '180 coins',
      type: _UserActivityType.phone,
      countryCode: 'US',
      remainingLabel: '8 min left',
    ),
    const _UserActivity(
      id: 1003,
      name: 'Sophie',
      message: 'Phone session ended earlier today.',
      time: '1 hr ago',
      avatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
      unread: 0,
      status: 'archived',
      trailingLabel: '180 coins',
      type: _UserActivityType.phone,
      countryCode: 'ID',
    ),
    const _UserActivity(
      id: 1004,
      name: 'Lia',
      message: 'Archived video call. Start again to reconnect.',
      time: 'Yesterday',
      avatar:
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
      unread: 0,
      status: 'archived',
      trailingLabel: '320 coins',
      type: _UserActivityType.video,
      countryCode: 'TH',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    userTabRouteNotifier.addListener(_handleTabVisibilityChanged);
    _loadActivities();
    _sessionSubscription = ChatService.realtime.sessionStream.listen((_) {
      if (!mounted) {
        return;
      }
      _loadActivities(forceRefresh: true);
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted || userTabRouteNotifier.value != '/messages') {
        return;
      }
      _loadActivities(forceRefresh: true);
    });
    unawaited(ChatService.realtime.connect());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    userTabRouteNotifier.removeListener(_handleTabVisibilityChanged);
    _sessionSubscription?.cancel();
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  late final WidgetsBindingObserver _lifecycleObserver =
      _MessagesLifecycleObserver(onResumed: () {
        if (!mounted) {
          return;
        }
        _loadActivities(forceRefresh: true);
      });

  void _handleTabVisibilityChanged() {
    if (!mounted || userTabRouteNotifier.value != '/messages') {
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
      final talentProfilesByAccountId = await _loadTalentProfilesForSessions(
        sessions,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _chatSessions = sessions;
        _telephoneSessions = telephoneSessions;
        _talentProfilesByAccountId = talentProfilesByAccountId;
        _isLoadingSessions = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoadingSessions = false);
    }
  }

  Future<Map<String, TalentPublicProfileData>> _loadTalentProfilesForSessions(
    List<ChatSessionSummary> sessions, {
    required bool forceRefresh,
  }) async {
    final accountIds = sessions
        .map((session) => session.counterpartAccountId.trim())
        .where((accountId) => accountId.isNotEmpty)
        .toSet();

    if (accountIds.isEmpty) {
      return _talentProfilesByAccountId;
    }

    final nextProfiles = Map<String, TalentPublicProfileData>.from(
      _talentProfilesByAccountId,
    );

    await Future.wait(
      accountIds.map((accountId) async {
        if (!forceRefresh && nextProfiles.containsKey(accountId)) {
          return;
        }

        try {
          final profile = await TalentPublicProfileService.getTalentProfile(
            accountId,
            forceRefresh: forceRefresh,
          );
          nextProfiles[accountId] = profile;
        } catch (_) {
          // Keep chat sessions usable even when profile enrichment fails.
        }
      }),
    );

    return nextProfiles;
  }

  String _countryFromLocation(String location) {
    final parts = location
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '';
    }
    return parts.last;
  }

  DemoUserHost _resolveHost(ChatSessionSummary session) {
    final profile =
        _talentProfilesByAccountId[session.counterpartAccountId.trim()];
    DemoUserHost? matchedHost;
    for (final host in demoUserHosts) {
      if (session.counterpartAccountId.trim().isNotEmpty &&
          host.accountId.trim().isNotEmpty &&
          host.accountId == session.counterpartAccountId) {
        matchedHost = host;
        break;
      }
    }

    if (matchedHost == null) {
      for (final host in demoUserHosts) {
        if (host.name.trim().toLowerCase() ==
            session.counterpartName.trim().toLowerCase()) {
          matchedHost = host;
          break;
        }
      }
    }

    final displayName = session.counterpartName.trim().isNotEmpty
        ? session.counterpartName
        : (profile?.stageName.trim().isNotEmpty == true
          ? profile!.stageName
          : (matchedHost?.name ?? 'Talent'));
    final avatarUrl = profile?.avatarUrl.trim().isNotEmpty == true
        ? ApiConfig.resolveExternalUrl(profile!.avatarUrl)
        : (session.counterpartAvatarUrl.trim().isNotEmpty
          ? ApiConfig.resolveExternalUrl(session.counterpartAvatarUrl)
          : (matchedHost?.imageUrl ?? ''));
    final country = profile?.country.trim().isNotEmpty == true
        ? profile!.country.trim()
        : (session.counterpartCountry.trim().isNotEmpty
          ? session.counterpartCountry.trim()
          : _countryFromLocation(matchedHost?.location ?? ''));
    final countryCode = profile?.country.trim().isNotEmpty == true
        ? (profile!.countryCode.trim().isNotEmpty
              ? profile.countryCode.trim().toUpperCase()
              : _countryCodeFromCountryName(profile.country))
        : (session.counterpartCountryCode.trim().isNotEmpty
          ? session.counterpartCountryCode.trim().toUpperCase()
          : (matchedHost?.countryCode ?? 'US'));

    return DemoUserHost(
      id: session.roomId.hashCode,
      accountId: session.counterpartAccountId.isNotEmpty
          ? session.counterpartAccountId
          : (matchedHost?.accountId ?? ''),
      name: displayName,
      age: profile?.age ?? matchedHost?.age ?? 0,
      city: profile?.city.trim().isNotEmpty == true
          ? profile!.city.trim()
          : (matchedHost?.city ?? 'Unknown City'),
      countryCode: countryCode,
      description: profile?.bio.trim().isNotEmpty == true
          ? profile!.bio.trim()
          : (matchedHost?.description ?? 'Chat talent'),
      imageUrl: avatarUrl,
      pricePerMin: profile?.servicePrices['chat'] ?? matchedHost?.pricePerMin ?? 0,
      tierLabel: profile?.level.trim().isNotEmpty == true
          ? _capitalize(profile!.level)
          : (matchedHost?.tierLabel ?? 'Basic'),
      rating: profile?.rating ?? matchedHost?.rating ?? 0,
      reviewCount: profile?.reviewCount ?? matchedHost?.reviewCount ?? 0,
      badges: profile != null
          ? [
              if (profile.verificationStatus.trim().isNotEmpty)
                _capitalize(profile.verificationStatus),
              ...profile.specialties.take(2),
            ]
          : (matchedHost?.badges ?? const []),
      portfolio: profile?.portfolioUrls ?? matchedHost?.portfolio ?? const [],
      isOnline: profile?.isOnline ?? matchedHost?.isOnline ?? true,
      location: [
            profile?.city.trim().isNotEmpty == true
                ? profile!.city.trim()
                : (matchedHost?.city ?? ''),
            country,
          ]
          .where((part) => part.trim().isNotEmpty)
          .join(', '),
      biography: profile?.bio ?? matchedHost?.biography ?? '',
      languages: profile?.languages ?? matchedHost?.languages ?? const [],
      specialties: profile?.specialties ?? matchedHost?.specialties ?? const [],
      servicePrices: profile?.servicePrices ?? matchedHost?.servicePrices ?? const {},
    );
  }

  String _countryCodeFromCountryName(String country) {
    const overrides = {
      'indonesia': 'ID',
      'philippines': 'PH',
      'thailand': 'TH',
      'vietnam': 'VN',
      'japan': 'JP',
      'united states': 'US',
      'usa': 'US',
      'united kingdom': 'GB',
      'great britain': 'GB',
      'canada': 'CA',
      'singapore': 'SG',
      'malaysia': 'MY',
      'south korea': 'KR',
    };

    final normalized = country.trim().toLowerCase();
    final override = overrides[normalized];
    if (override != null) {
      return override;
    }

    final letters = normalized.replaceAll(RegExp(r'[^a-z]'), '');
    if (letters.length >= 2) {
      return letters.substring(0, 2).toUpperCase();
    }
    return 'US';
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  _UserActivityType _activityTypeFromChannel(String channelType) {
    switch (channelType.trim().toLowerCase()) {
      case 'telephone':
      case 'voice':
        return _UserActivityType.phone;
      case 'video':
        return _UserActivityType.video;
      default:
        return _UserActivityType.message;
    }
  }

  _UserActivity _telephoneActivityFromSession(TelephoneSessionListItem session) {
    final now = DateTime.now();
    final isExpired = session.validUntil != null && now.isAfter(session.validUntil!);
    final isCompleted = session.status.trim().toLowerCase() == 'completed' ||
        session.closedReason.trim().toLowerCase() == 'manual_end_transaction';
    final isArchived = isExpired || isCompleted;

    final message = switch (session.callStatus.trim().toLowerCase()) {
      'ringing' => 'Sedang memanggil talent.',
      'ongoing' => 'Telephone call sedang aktif.',
      'ended' => 'Panggilan selesai, kuota masih bisa dipakai.',
      _ => isArchived
          ? 'Sesi telephone sudah tidak aktif.'
          : (session.status.trim().toLowerCase() == 'pending'
                ? 'Menunggu konfirmasi talent.'
                : 'Sesi telephone siap dipakai.'),
    };

    return _UserActivity(
      id: session.roomId.hashCode,
      name: session.counterpartName.trim().isNotEmpty
          ? session.counterpartName
          : 'Telephone Talent',
      message: message,
      time: _activityTimeLabel(session.updatedAt),
      avatar: session.counterpartAvatarUrl.trim(),
      unread: 0,
      status: isArchived ? 'archived' : 'active',
      trailingLabel: isArchived ? 'Telephone archived' : 'Telephone session',
      type: _UserActivityType.phone,
      countryCode: session.counterpartCountryCode.trim().isNotEmpty
          ? session.counterpartCountryCode.trim().toUpperCase()
          : 'US',
      remainingLabel: isExpired
          ? 'Sesi hangus 24 jam'
          : 'Sisa ${_durationLabel(session.remainingDurationSeconds)}',
      telephoneSession: session,
    );
  }

  _UserActivity _chatActivityFromSession(ChatSessionSummary session) {
    final normalizedStatus = session.status.trim().toLowerCase();
    final isOpenable = session.isActiveNow;
    final host = _resolveHost(session);
    final statusLabel = !session.isActiveNow
        ? 'Chat expired'
        : switch (normalizedStatus) {
            'pending' => 'Menunggu balasan talent',
            'confirmed' => 'Chat aktif',
            'active' => 'Chat aktif',
            '' => 'Chat aktif',
            _ => 'Chat aktif',
          };

    return _UserActivity(
      id: session.roomId.hashCode,
      name: session.counterpartName.trim().isNotEmpty
          ? session.counterpartName
          : host.name,
      message: session.lastMessageText.trim().isNotEmpty
          ? session.lastMessageText
          : 'Percakapan chat siap dibuka.',
      time: session.lastMessageTimeLabel.trim().isNotEmpty
          ? session.lastMessageTimeLabel
          : 'Baru saja',
        avatar: host.imageUrl,
      unread: session.unreadCount,
      status: isOpenable ? 'active' : 'archived',
      trailingLabel: isOpenable ? 'Realtime chat' : 'Expired chat',
      type: _activityTypeFromChannel(session.channelType),
        country: host.location.isNotEmpty ? _countryFromLocation(host.location) : '',
        countryCode: host.countryCode,
      remainingLabel: statusLabel,
      chatSession: session,
      host: host,
    );
  }

  Future<void> _openActivity(_UserActivity activity) async {
    if (activity.status != 'active' && activity.type != _UserActivityType.message) {
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
      case _UserActivityType.message:
        var session = activity.chatSession;
        final host = activity.host ?? demoUserHosts.first;
        if (session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Room chat untuk aktivitas ini belum tersedia.'),
            ),
          );
          return;
        }

        if (activity.status != 'active') {
          final shouldReactivate = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Lanjutkan sesi chat?'),
                content: Text(
                  'Chat dengan ${activity.name} sudah expired. Apakah Anda ingin melakukan sesi ulang?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Ya, lanjutkan'),
                  ),
                ],
              );
            },
          );

          if (shouldReactivate != true || !mounted) {
            return;
          }

          try {
            await ChatService.reactivateRoom(session.roomId);
            final refreshedSessions = await ChatService.getChatSessions(
              forceRefresh: true,
            );
            session = refreshedSessions.firstWhere(
              (candidate) => candidate.roomId == session!.roomId,
              orElse: () => session!,
            );
            if (!mounted) {
              return;
            }
            setState(() {
              _chatSessions = refreshedSessions;
            });
          } on Exception catch (error) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
            return;
          }
        }

        await Navigator.of(context).push(
          buildLoadingSplashRoute<void>(
            settings: const RouteSettings(name: '/chat-session'),
            builder: (context) => ChatScreen(host: host, session: session),
          ),
        );
      case _UserActivityType.phone:
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
            settings: const RouteSettings(name: '/phone-session'),
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
      case _UserActivityType.video:
        await Navigator.of(context).push(
          buildLoadingSplashRoute<void>(
            settings: const RouteSettings(name: '/video-session'),
            builder: (context) => ActivitySessionScreen(
              peerName: activity.name,
              peerAvatar: activity.avatar,
              sessionMode: ActivitySessionMode.video,
              contextLabel: 'Video session with ${activity.name}',
              statusLabel: 'Video call is active',
              trailingLabel: activity.trailingLabel,
            ),
          ),
        );
    }
  }

  String _typeLabel(_UserActivityType type) {
    switch (type) {
      case _UserActivityType.message:
        return 'Message';
      case _UserActivityType.phone:
        return 'Phone';
      case _UserActivityType.video:
        return 'Video Call';
    }
  }

  IconData _typeIcon(_UserActivityType type) {
    switch (type) {
      case _UserActivityType.message:
        return Icons.message_rounded;
      case _UserActivityType.phone:
        return Icons.call_rounded;
      case _UserActivityType.video:
        return Icons.videocam_rounded;
    }
  }

  Color _typeColor(_UserActivityType type) {
    switch (type) {
      case _UserActivityType.message:
        return const Color(0xFF2FA655);
      case _UserActivityType.phone:
        return const Color(0xFF3B82F6);
      case _UserActivityType.video:
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
    final allActivities = <_UserActivity>[
      ..._telephoneSessions.map(_telephoneActivityFromSession),
      ..._chatSessions.map(_chatActivityFromSession),
      ..._activities.where((activity) => activity.type != _UserActivityType.phone),
    ];
    final filtered = allActivities.where((activity) {
      final matchesTab = _activeTab == 'all' || activity.status == _activeTab;
      final matchesQuery =
          query.isEmpty ||
          activity.name.toLowerCase().contains(query) ||
          activity.message.toLowerCase().contains(query) ||
          _typeLabel(activity.type).toLowerCase().contains(query);
      return matchesTab && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: _userInboxSurface,
      bottomNavigationBar: widget.showBottomNav
          ? const UserBottomNav(currentRoute: '/messages')
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_userInboxHeaderStart, _userInboxHeaderEnd],
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
                    'Notifikasi',
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
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
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
                      onRefresh: () => _loadActivities(forceRefresh: true),
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
                      onRefresh: () => _loadActivities(forceRefresh: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final activity = filtered[index];
                          final typeColor = _typeColor(activity.type);
                          final avatarProvider = activity.avatar.trim().isNotEmpty
                              ? NetworkImage(activity.avatar)
                              : null;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => _openActivity(activity),
                              borderRadius: BorderRadius.circular(18),
                              child: Row(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor:
                                            const Color(0xFFF4E4D3),
                                        backgroundImage: avatarProvider,
                                        child: avatarProvider == null
                                            ? Text(
                                                activity.name.isNotEmpty
                                                    ? activity.name[0]
                                                          .toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: Color(0xFF8A573A),
                                                  fontWeight: FontWeight.w700,
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
                                                  fontWeight: FontWeight.w700,
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
                                                  fontWeight: FontWeight.w700,
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
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _typeIcon(activity.type),
                                                    size: 14,
                                                    color: typeColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _typeLabel(activity.type),
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
                                                color: activity.status ==
                                                        'active'
                                                    ? const Color(0xFFEAF8EF)
                                                    : const Color(0xFFF3F0EC),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                activity.status == 'active'
                                                    ? 'Active'
                                                    : 'Archived',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: activity.status ==
                                                          'active'
                                                      ? const Color(0xFF2FA655)
                                                      : const Color(0xFF8A837D),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              activity.status == 'active'
                                                  ? (activity.remainingLabel ??
                                                      'Realtime update aktif')
                                                  : 'Archived activity',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: activity.status ==
                                                        'active'
                                                    ? const Color(0xFF2FA655)
                                                    : const Color(0xFF8A837D),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              activity.trailingLabel,
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
      ),
    );
  }

  Widget _tabButton(String value, String label) {
    final isActive = _activeTab == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? _userInboxHeaderStart : Colors.transparent,
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

class _MessagesLifecycleObserver with WidgetsBindingObserver {
  _MessagesLifecycleObserver({required this.onResumed});

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}