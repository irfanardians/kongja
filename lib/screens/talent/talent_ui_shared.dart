import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/chat_service.dart';
import '../../core/services/telephone_session_service.dart';

const Color talentBg = Color(0xFFFFF8E1);
const Color talentAmberDark = Color(0xFFB45309);
const Color talentAmber = Color(0xFFF59E42);
const Color talentPink = Color(0xFFDB2777);
const Color talentPurple = Color(0xFF7C3AED);

const List<String> talentTabRoutes = [
  '/talent-home',
  '/talent-messages',
  '/talent-profile',
  '/talent-settings',
];

final ValueNotifier<String> talentTabRouteNotifier = ValueNotifier<String>(
  '/talent-home',
);

String normalizeTalentTabRoute(String route) {
  if (talentTabRoutes.contains(route)) {
    return route;
  }

  return '/talent-home';
}

void navigateToTalentTab(BuildContext context, String route) {
  final normalizedRoute = normalizeTalentTabRoute(route);
  final currentRoute = ModalRoute.of(context)?.settings.name;

  talentTabRouteNotifier.value = normalizedRoute;
  if (!talentTabRoutes.contains(currentRoute)) {
    Navigator.pushReplacementNamed(context, normalizedRoute);
  }
}

class TalentBottomNav extends StatefulWidget {
  const TalentBottomNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  State<TalentBottomNav> createState() => _TalentBottomNavState();
}

class _TalentBottomNavState extends State<TalentBottomNav> {
  StreamSubscription<void>? _sessionSubscription;
  Timer? _refreshTimer;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _loadNotificationCount();
    _sessionSubscription = ChatService.realtime.sessionStream.listen((_) {
      if (!mounted) {
        return;
      }
      _loadNotificationCount(forceRefresh: true);
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) {
        return;
      }
      _loadNotificationCount(forceRefresh: true);
    });
    unawaited(ChatService.realtime.connect());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _sessionSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  late final WidgetsBindingObserver _lifecycleObserver =
      _TalentBottomNavLifecycleObserver(onResumed: () {
        if (!mounted) {
          return;
        }
        _loadNotificationCount(forceRefresh: true);
      });

  Future<void> _loadNotificationCount({bool forceRefresh = false}) async {
    try {
      final results = await Future.wait<dynamic>([
        ChatService.getChatSessions(forceRefresh: forceRefresh),
        TelephoneSessionService.getSessions(forceRefresh: forceRefresh),
      ]);
      final chatSessions = results[0] as List<ChatSessionSummary>;
      final telephoneSessions = results[1] as List<TelephoneSessionListItem>;
      if (!mounted) {
        return;
      }

      final unreadMessages = chatSessions.fold<int>(
        0,
        (sum, session) => sum + session.unreadCount,
      );
      final telephoneAlerts = telephoneSessions.where((session) {
        final status = session.status.trim().toLowerCase();
        final callStatus = session.callStatus.trim().toLowerCase();
        final isExpired = session.validUntil != null &&
            DateTime.now().isAfter(session.validUntil!);
        final isCompleted = status == 'completed' ||
            session.closedReason.trim().toLowerCase() ==
                'manual_end_transaction';
        if (isExpired || isCompleted) {
          return false;
        }
        return status == 'pending' ||
            callStatus == 'ringing' ||
            callStatus == 'ongoing';
      }).length;

      setState(() {
        _notificationCount = unreadMessages + telephoneAlerts;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _TalentNavItem(
        icon: Icons.home_rounded,
        label: 'Home',
        route: '/talent-home',
      ),
      _TalentNavItem(
        icon: Icons.local_activity_rounded,
        label: 'Activity',
        route: '/talent-messages',
      ),
      _TalentNavItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        route: '/talent-profile',
      ),
      _TalentNavItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
        route: '/talent-settings',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final isActive = widget.currentRoute == item.route;
            final showNotification =
                item.route == '/talent-messages' && _notificationCount > 0;
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                if (!isActive) {
                  navigateToTalentTab(context, item.route);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? const LinearGradient(
                                    colors: [talentAmberDark, talentAmber],
                                  )
                                : null,
                            color: isActive ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item.icon,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF7C746D),
                            size: 20,
                          ),
                        ),
                        if (showNotification)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE34B57),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _notificationCount > 99
                                      ? '99+'
                                      : '$_notificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? talentAmberDark
                            : const Color(0xFF7C746D),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TalentSectionCard extends StatelessWidget {
  const TalentSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TalentField extends StatelessWidget {
  const TalentField({
    super.key,
    required this.label,
    required this.icon,
    required this.initialValue,
    this.helper,
    this.trailing,
    this.maxLines = 1,
    this.enabled = true,
    this.controller,
  });

  final String label;
  final IconData icon;
  final String initialValue;
  final String? helper;
  final Widget? trailing;
  final int maxLines;
  final bool enabled;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7F7770)),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: enabled ? Colors.white : const Color(0xFFF4F1ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6DED6)),
            ),
            child: Row(
              crossAxisAlignment: maxLines > 1
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                  child: Icon(icon, color: const Color(0xFFA59D96)),
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    enabled: enabled,
                    initialValue: controller == null ? initialValue : null,
                    maxLines: maxLines,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: trailing,
                  ),
              ],
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Text(
              helper!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFA59D96)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TalentNavItem {
  const _TalentNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class _TalentBottomNavLifecycleObserver with WidgetsBindingObserver {
  _TalentBottomNavLifecycleObserver({required this.onResumed});

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
