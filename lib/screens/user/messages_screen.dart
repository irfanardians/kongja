import 'package:flutter/material.dart';

import '../../shared/demo_schedule_store.dart';
import '../shared/activity_session_screen.dart';
import 'chat_screen.dart';
import 'user_ui_shared.dart';

enum _UserActivityType { message, phone, video }

class _UserActivity {
  const _UserActivity({
    required this.hostId,
    required this.type,
    required this.lastUpdate,
    required this.timestamp,
    required this.unread,
    required this.isActive,
    required this.coinCost,
    this.remainingLabel,
  });

  final int hostId;
  final _UserActivityType type;
  final String lastUpdate;
  final String timestamp;
  final bool unread;
  final bool isActive;
  final int coinCost;
  final String? remainingLabel;
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeTab = 'all';
  DemoUserHost? selectedHost;
  _UserActivity? selectedActivity;

  final activities = const [
    _UserActivity(
      hostId: 1,
      type: _UserActivityType.message,
      lastUpdate: "I'd love to hear more about it! 😊",
      timestamp: '2m ago',
      unread: true,
      isActive: true,
      coinCost: 150,
      remainingLabel: '5 min left',
    ),
    _UserActivity(
      hostId: 1,
      type: _UserActivityType.video,
      lastUpdate: 'Video call is still running',
      timestamp: '4m ago',
      unread: false,
      isActive: true,
      coinCost: 260,
      remainingLabel: '12 min left',
    ),
    _UserActivity(
      hostId: 3,
      type: _UserActivityType.phone,
      lastUpdate: 'Phone call still active',
      timestamp: '12m ago',
      unread: false,
      isActive: true,
      coinCost: 180,
      remainingLabel: '8 min left',
    ),
    _UserActivity(
      hostId: 2,
      type: _UserActivityType.phone,
      lastUpdate: 'Phone session ended earlier today',
      timestamp: '1h ago',
      unread: false,
      isActive: false,
      coinCost: 180,
    ),
    _UserActivity(
      hostId: 4,
      type: _UserActivityType.message,
      lastUpdate: 'See you soon! 💕',
      timestamp: '3h ago',
      unread: true,
      isActive: false,
      coinCost: 120,
    ),
    _UserActivity(
      hostId: 6,
      type: _UserActivityType.video,
      lastUpdate: 'Archived video call. Start again to reconnect.',
      timestamp: 'Yesterday',
      unread: false,
      isActive: false,
      coinCost: 320,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _effectiveIsActive(_UserActivity activity, DemoUserHost host) {
    if (activity.type != _UserActivityType.message) {
      return activity.isActive;
    }

    final acceptedRequest = demoScheduleStore.latestAcceptedRequestForUserHost(
      userName: demoCurrentUserName,
      hostName: host.name,
    );
    if (acceptedRequest == null) {
      return activity.isActive;
    }

    return demoScheduleStore.canOpenEventChat(
      userName: demoCurrentUserName,
      hostName: host.name,
    );
  }

  String _activityStatusText(_UserActivity activity, DemoUserHost host) {
    if (activity.type == _UserActivityType.message) {
      final acceptedRequest = demoScheduleStore.latestAcceptedRequestForUserHost(
        userName: demoCurrentUserName,
        hostName: host.name,
      );
      if (acceptedRequest != null) {
        final isOpen = demoScheduleStore.canOpenEventChat(
          userName: demoCurrentUserName,
          hostName: host.name,
        );
        return isOpen
            ? 'Active • Chat tersedia H-3 sampai H+1 acara'
            : 'Archived • Chat hanya aktif H-3 sampai H+1 acara';
      }
    }

    return activity.isActive
        ? 'Active • ${activity.remainingLabel ?? 'Ready'}'
        : 'Archived • Reopen with ${activity.coinCost} coins';
  }

  Future<void> _openActivity(_UserActivity activity, DemoUserHost host) async {
    switch (activity.type) {
      case _UserActivityType.message:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ChatScreen(host: host),
          ),
        );
      case _UserActivityType.phone:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ActivitySessionScreen(
              peerName: host.name,
              peerAvatar: host.imageUrl,
              sessionMode: ActivitySessionMode.phone,
              contextLabel: 'Phone session with ${host.name}',
              statusLabel: activity.isActive
                  ? 'Phone call is active'
                  : 'Restarted phone session',
              trailingLabel: '🪙 ${activity.coinCost}',
            ),
          ),
        );
      case _UserActivityType.video:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ActivitySessionScreen(
              peerName: host.name,
              peerAvatar: host.imageUrl,
              sessionMode: ActivitySessionMode.video,
              contextLabel: 'Video session with ${host.name}',
              statusLabel: activity.isActive
                  ? 'Video call is active'
                  : 'Restarted video session',
              trailingLabel: '🪙 ${activity.coinCost}',
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

  bool _isMeetMessage(_UserActivity activity, DemoUserHost host) {
    if (activity.type != _UserActivityType.message) {
      return false;
    }

    return demoScheduleStore.latestAcceptedRequestForUserHost(
          userName: demoCurrentUserName,
          hostName: host.name,
        ) !=
        null;
  }

  IconData _typeIcon(_UserActivity activity, DemoUserHost host) {
    switch (activity.type) {
      case _UserActivityType.message:
        return _isMeetMessage(activity, host)
            ? Icons.event_available_rounded
            : Icons.message_rounded;
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DemoMeetRequest>>(
      valueListenable: demoScheduleStore,
      builder: (context, _, __) {
        final filtered = activities.where((activity) {
          final host = demoUserHosts.firstWhere((item) => item.id == activity.hostId);
          final query = _searchController.text.toLowerCase();
          final isActive = _effectiveIsActive(activity, host);
          final matchesTab =
              _activeTab == 'all' ||
              (_activeTab == 'active' && isActive) ||
              (_activeTab == 'archived' && !isActive);
          final matchesQuery =
              query.isEmpty ||
              host.name.toLowerCase().contains(query) ||
              activity.lastUpdate.toLowerCase().contains(query) ||
              _typeLabel(activity.type).toLowerCase().contains(query);
          return matchesTab && matchesQuery;
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
                      const Text(
                        'Activity',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search activity...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFFA5A09A),
                          ),
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
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _tabButton('all', 'All'),
                          const SizedBox(width: 10),
                          _tabButton('active', 'Active'),
                          const SizedBox(width: 10),
                          _tabButton('archived', 'Archived'),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final activity = filtered[index];
                      final host = demoUserHosts.firstWhere((item) => item.id == activity.hostId);
                      final typeColor = _typeColor(activity.type);
                      final isCurrentlyActive = _effectiveIsActive(activity, host);

                      return InkWell(
                        onTap: () {
                          if (isCurrentlyActive) {
                            _openActivity(activity, host);
                          } else {
                            setState(() {
                              selectedHost = host;
                              selectedActivity = activity;
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
                                        Expanded(
                                          child: Text(
                                            host.name,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                          ),
                                        ),
                                        Text(
                                          activity.timestamp,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF9B948D)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activity.lastUpdate,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: activity.unread ? const Color(0xFF2E2B28) : const Color(0xFF8A847E),
                                        fontWeight: activity.unread ? FontWeight.w600 : FontWeight.w400,
                                      ),
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
                                              Icon(_typeIcon(activity, host), size: 14, color: typeColor),
                                              const SizedBox(width: 4),
                                              Text(
                                                _typeLabel(activity.type),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: typeColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          _activityStatusText(activity, host),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isCurrentlyActive
                                                ? const Color(0xFF2FA655)
                                                : const Color(0xFFB2AAA1),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (activity.unread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: const BoxDecoration(
                                    color: userAmberDark,
                                    shape: BoxShape.circle,
                                  ),
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
            if (selectedHost != null && selectedActivity != null)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0x80000000),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEDD9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _typeIcon(selectedActivity!, selectedHost!),
                              size: 34,
                              color: const Color(0xFFD18734),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${_typeLabel(selectedActivity!.type)} Archived',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your ${_typeLabel(selectedActivity!.type).toLowerCase()} activity with ${selectedHost!.name} has ended.${selectedActivity!.type == _UserActivityType.message ? ' Chat message hanya bisa dibuka dari H-3 sampai H+1 acara yang sudah accepted.' : ' Start again by paying coins for this feature.'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF817A74)),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF3E4), Color(0xFFFFE8D2)],
                              ),
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
                                      Text(
                                        'Restart ${_typeLabel(selectedActivity!.type).toLowerCase()}',
                                        style: const TextStyle(color: Color(0xFF847D76), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '🪙 ${selectedActivity!.coinCost}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: userAmberDark),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                final host = selectedHost!;
                                final activity = selectedActivity!;
                                setState(() {
                                  selectedHost = null;
                                  selectedActivity = null;
                                });
                                if (activity.type == _UserActivityType.message) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Chat message hanya bisa dibuka dalam rentang H-3 sampai H+1 dari schedule yang sudah accepted.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                _openActivity(activity, host);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: userAmberDark,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Pay Coins and Continue'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                selectedHost = null;
                                selectedActivity = null;
                              }),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side: const BorderSide(color: Color(0xFFE8E1D8)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Maybe Later'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabButton(String value, String label) {
    final isActive = _activeTab == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _activeTab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? userAmberDark : const Color(0xFFF4EFE8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF6F6862),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
