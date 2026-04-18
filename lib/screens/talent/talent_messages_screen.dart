import 'package:flutter/material.dart';

import '../../shared/demo_schedule_store.dart';
import '../shared/activity_session_screen.dart';
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
    this.isScheduleMessage = false,
    this.remainingLabel,
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
  final bool isScheduleMessage;
  final String? remainingLabel;
}

class TalentMessagesScreen extends StatefulWidget {
  const TalentMessagesScreen({Key? key}) : super(key: key);

  @override
  State<TalentMessagesScreen> createState() => _TalentMessagesScreenState();
}

class _TalentMessagesScreenState extends State<TalentMessagesScreen> {
  static const String _currentTalentHostName = 'Clara';

  String activeTab = 'all';
  final TextEditingController _searchController = TextEditingController();

  final activities = const [
    _TalentActivity(
      id: 1,
      name: 'Sarah Johnson',
      message: 'Thank you for the chat!',
      time: '2 min ago',
      avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      unread: 2,
      status: 'active',
      lastEarning: '50 coins',
      type: _TalentActivityType.message,
      remainingLabel: '5 min left',
    ),
    _TalentActivity(
      id: 2,
      name: 'Mike Chen',
      message: 'Phone call still running.',
      time: '15 min ago',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      unread: 1,
      status: 'active',
      lastEarning: '35 coins',
      type: _TalentActivityType.phone,
      remainingLabel: '8 min left',
    ),
    _TalentActivity(
      id: 3,
      name: 'Emma Wilson',
      message: 'Video session is live now.',
      time: '1 hr ago',
      avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      unread: 0,
      status: 'active',
      lastEarning: '120 coins',
      type: _TalentActivityType.video,
      remainingLabel: '14 min left',
    ),
    _TalentActivity(
      id: 4,
      name: 'David Lee',
      message: 'See you next time!',
      time: '2 hrs ago',
      avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      unread: 0,
      status: 'archived',
      lastEarning: '80 coins',
      type: _TalentActivityType.message,
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
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_TalentActivity> _scheduleActivities() {
    final acceptedRequests = demoScheduleStore
        .requestsForHost(_currentTalentHostName)
        .where((request) => request.status == DemoMeetRequestStatus.accepted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return acceptedRequests.map((request) {
      final isActive = demoScheduleStore.canHostOpenEventChat(
        hostName: _currentTalentHostName,
        userName: request.userName,
      );

      return _TalentActivity(
        id: 1000 + request.id,
        name: request.userName,
        message:
            'Schedule chat for ${request.eventType} on ${request.dateLabel} at ${request.startTimeLabel}.',
        time: request.requestedAtLabel,
        avatar: request.userAvatar,
        unread: isActive ? 1 : 0,
        status: isActive ? 'active' : 'archived',
        lastEarning: '${request.coins} coins',
        type: _TalentActivityType.message,
        countryCode: request.countryCode,
        isScheduleMessage: true,
        remainingLabel: isActive
            ? 'Chat tersedia H-3 sampai H+1 acara'
            : null,
      );
    }).toList(growable: false);
  }

  Future<void> _handleActivityTap(_TalentActivity activity) async {
    if (activity.status != 'active') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            activity.isScheduleMessage
                ? 'Schedule chat dengan ${activity.name} hanya aktif pada H-3 sampai H+1 acara.'
                : '${_typeLabel(activity.type)} with ${activity.name} is no longer active.',
          ),
        ),
      );
      return;
    }

    switch (activity.type) {
      case _TalentActivityType.message:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => TalentChatScreen(
              userName: activity.name,
              userAvatar: activity.avatar,
              lastMessage: activity.message,
              earningLabel: activity.lastEarning,
              lastSeenLabel: activity.time,
            ),
          ),
        );
      case _TalentActivityType.phone:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ActivitySessionScreen(
              peerName: activity.name,
              peerAvatar: activity.avatar,
              sessionMode: ActivitySessionMode.phone,
              contextLabel: 'Phone session with ${activity.name}',
              statusLabel: 'Phone call is active',
              trailingLabel: activity.lastEarning,
            ),
          ),
        );
      case _TalentActivityType.video:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
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
    if (activity.isScheduleMessage) {
      return Icons.event_available_rounded;
    }

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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DemoMeetRequest>>(
      valueListenable: demoScheduleStore,
      builder: (context, _, __) {
        final query = _searchController.text.toLowerCase();
        final allActivities = [..._scheduleActivities(), ...activities];
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
          bottomNavigationBar: const TalentBottomNav(currentRoute: '/talent-messages'),
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
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Activity',
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search activity...',
                              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA79F97)),
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
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No activity found',
                                style: TextStyle(color: Color(0xFF8B837D)),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final activity = filtered[index];
                                final typeColor = _typeColor(activity.type);

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
                                            CircleAvatar(radius: 28, backgroundImage: NetworkImage(activity.avatar)),
                                            Positioned(
                                              right: -2,
                                              bottom: -2,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                                                child: Text(activity.countryCode, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                              ),
                                            ),
                                            if (activity.unread > 0)
                                              Positioned(
                                                top: -4,
                                                right: -2,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: const BoxDecoration(color: Color(0xFFE34B57), shape: BoxShape.circle),
                                                  child: Center(child: Text('${activity.unread}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
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
                                                  Expanded(child: Text(activity.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                                                  Text(activity.time, style: const TextStyle(fontSize: 12, color: Color(0xFFAAA39C))),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                activity.message,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 14, color: activity.unread > 0 ? const Color(0xFF272421) : const Color(0xFF89827C), fontWeight: activity.unread > 0 ? FontWeight.w600 : FontWeight.w400),
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: typeColor.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(999),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(_activityIcon(activity), size: 14, color: typeColor),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          _typeLabel(activity.type),
                                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: typeColor),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: activity.status == 'active' ? const Color(0xFFEAF8EF) : const Color(0xFFF3F0EC),
                                                      borderRadius: BorderRadius.circular(999),
                                                    ),
                                                    child: Text(
                                                      activity.status == 'active' ? 'Active' : 'Archived',
                                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: activity.status == 'active' ? const Color(0xFF2FA655) : const Color(0xFF8A837D)),
                                                    ),
                                                  ),
                                                  Text(
                                                    activity.status == 'active'
                                                        ? (activity.remainingLabel ?? 'Active now')
                                                        : (activity.isScheduleMessage ? 'Chat aktif hanya H-3 sampai H+1 acara' : 'Archived activity'),
                                                    style: TextStyle(fontSize: 12, color: activity.status == 'active' ? const Color(0xFF2FA655) : const Color(0xFF8A837D), fontWeight: FontWeight.w700),
                                                  ),
                                                  Text('🪙 ${activity.lastEarning}', style: const TextStyle(fontSize: 12, color: Color(0xFF2FA655), fontWeight: FontWeight.w700)),
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
      },
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
