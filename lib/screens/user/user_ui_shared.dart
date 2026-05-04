import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/chat_service.dart';
import '../../core/services/telephone_session_service.dart';

const Color userCreamBackground = Color(0xFFF5F1E8);
const Color userAmber = Color(0xFF9A654D);
const Color userAmberDark = Color(0xFF8B5A3C);
const Color userAmberLight = Color(0xFFD08D43);

const List<String> userTabRoutes = [
  '/home',
  '/messages',
  '/favorites',
  '/user-profile',
];

final ValueNotifier<String> userTabRouteNotifier = ValueNotifier<String>(
  '/home',
);

String normalizeUserTabRoute(String route) {
  if (userTabRoutes.contains(route)) {
    return route;
  }

  return '/home';
}

void navigateToUserTab(BuildContext context, String route) {
  final normalizedRoute = normalizeUserTabRoute(route);
  final currentRoute = ModalRoute.of(context)?.settings.name;

  userTabRouteNotifier.value = normalizedRoute;
  if (!userTabRoutes.contains(currentRoute)) {
    Navigator.pushReplacementNamed(context, normalizedRoute);
  }
}

class DemoUserHost {
  const DemoUserHost({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.countryCode,
    required this.description,
    required this.imageUrl,
    required this.pricePerMin,
    required this.tierLabel,
    required this.rating,
    required this.reviewCount,
    required this.badges,
    required this.portfolio,
    required this.isOnline,
    required this.location,
    this.biography = '',
    this.accountId = '',
    this.languages = const [],
    this.specialties = const [],
    this.servicePrices = const {},
  });

  final int id;
  final String name;
  final int age;
  final String city;
  final String countryCode;
  final String description;
  final String imageUrl;
  final int pricePerMin;
  final String tierLabel;
  final double rating;
  final int reviewCount;
  final List<String> badges;
  final List<String> portfolio;
  final bool isOnline;
  final String location;
  final String biography;
  final String accountId;
  final List<String> languages;
  final List<String> specialties;
  final Map<String, int> servicePrices;
}

const List<DemoUserHost> demoUserHosts = [
  DemoUserHost(
    id: 1,
    name: 'Clara',
    age: 24,
    city: 'Manila',
    countryCode: 'PH',
    description: 'Sweet & Caring',
    imageUrl:
        'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=800',
    pricePerMin: 30,
    tierLabel: 'Gold',
    rating: 4.9,
    reviewCount: 125,
    badges: ['Friendly', 'Verified', 'Travel Buddy'],
    portfolio: [
      'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=400',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
    ],
    isOnline: true,
    location: 'Makati, Manila',
  ),
  DemoUserHost(
    id: 2,
    name: 'Sophie',
    age: 23,
    city: 'Bandung',
    countryCode: 'ID',
    description: 'Elegant & Fun',
    imageUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
    pricePerMin: 28,
    tierLabel: 'Silver',
    rating: 4.8,
    reviewCount: 92,
    badges: ['Music', 'Late Night Chat'],
    portfolio: [
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
    ],
    isOnline: false,
    location: 'Dago, Bandung',
  ),
  DemoUserHost(
    id: 3,
    name: 'Emma',
    age: 26,
    city: 'Surabaya',
    countryCode: 'US',
    description: 'Cheerful Soul',
    imageUrl:
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
    pricePerMin: 32,
    tierLabel: 'Gold',
    rating: 4.7,
    reviewCount: 88,
    badges: ['Voice Call', 'Good Listener'],
    portfolio: [
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400',
    ],
    isOnline: true,
    location: 'West Surabaya',
  ),
  DemoUserHost(
    id: 4,
    name: 'Mia',
    age: 25,
    city: 'Bali',
    countryCode: 'VN',
    description: 'Kind Hearted',
    imageUrl:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
    pricePerMin: 27,
    tierLabel: 'Bronze',
    rating: 4.9,
    reviewCount: 140,
    badges: ['Travel', 'Offline Meet'],
    portfolio: [
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
    ],
    isOnline: false,
    location: 'Seminyak, Bali',
  ),
  DemoUserHost(
    id: 5,
    name: 'Nara',
    age: 22,
    city: 'Medan',
    countryCode: 'JP',
    description: 'Sweet Smile',
    imageUrl:
        'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800',
    pricePerMin: 25,
    tierLabel: 'Bronze',
    rating: 4.8,
    reviewCount: 64,
    badges: ['Gaming', 'Study Buddy'],
    portfolio: [
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400',
      'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=400',
    ],
    isOnline: true,
    location: 'Central Medan',
  ),
  DemoUserHost(
    id: 6,
    name: 'Lia',
    age: 27,
    city: 'Makassar',
    countryCode: 'TH',
    description: 'Playful Cat',
    imageUrl:
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
    pricePerMin: 35,
    tierLabel: 'VIP',
    rating: 4.9,
    reviewCount: 111,
    badges: ['VIP', 'Video Call'],
    portfolio: [
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    ],
    isOnline: true,
    location: 'Panakkukang, Makassar',
  ),
];

class UserBottomNav extends StatefulWidget {
  const UserBottomNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  State<UserBottomNav> createState() => _UserBottomNavState();
}

class _UserBottomNavState extends State<UserBottomNav> {
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
      _UserBottomNavLifecycleObserver(onResumed: () {
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
      final sessions = results[0] as List<ChatSessionSummary>;
      final telephoneSessions = results[1] as List<TelephoneSessionListItem>;
      if (!mounted) {
        return;
      }

      final unreadMessages = sessions.fold<int>(
        0,
        (sum, session) => sum + session.unreadCount,
      );
      final pendingRooms = sessions.where((session) {
        final status = session.status.trim().toLowerCase();
        return session.isActiveNow &&
            status == 'pending' &&
            session.unreadCount == 0;
      }).length;

      final telephonePending = telephoneSessions.where((session) {
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
        _notificationCount = unreadMessages + pendingRooms + telephonePending;
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
      _BottomNavItem(icon: Icons.home_rounded, label: 'Home', route: '/home'),
      _BottomNavItem(
        icon: Icons.local_activity_rounded,
        label: 'Activity',
        route: '/messages',
      ),
      _BottomNavItem(
        icon: Icons.favorite_rounded,
        label: 'Favorites',
        route: '/favorites',
      ),
      _BottomNavItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        route: '/user-profile',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E1D8))),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
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
                item.route == '/messages' && _notificationCount > 0;
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (!isActive) {
                  navigateToUserTab(context, item.route);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showNotification)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9E7D8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Activity',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? userAmberDark
                                : const Color(0xFF8B5A3C),
                          ),
                        ),
                      ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isActive ? userAmberDark : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF7F7A75),
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
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isActive
                            ? userAmberDark
                            : const Color(0xFF7F7A75),
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

class _UserBottomNavLifecycleObserver with WidgetsBindingObserver {
  _UserBottomNavLifecycleObserver({required this.onResumed});

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}

class UserFlagBadge extends StatelessWidget {
  const UserFlagBadge({
    super.key,
    required this.countryCode,
    this.size = 42,
    this.borderWidth = 3,
    this.innerPadding = 4,
  });

  final String countryCode;
  final double size;
  final double borderWidth;
  final double innerPadding;

  @override
  Widget build(BuildContext context) {
    final normalizedCode = countryCode.trim().toLowerCase();
    final flagUrl =
        normalizedCode.length == 2
            ? 'https://flagcdn.com/w80/$normalizedCode.png'
            : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(innerPadding),
        child: ClipOval(
          child: flagUrl == null
              ? _FlagCodeFallback(countryCode: countryCode)
              : Image.network(
                  flagUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _FlagCodeFallback(countryCode: countryCode);
                  },
                ),
        ),
      ),
    );
  }
}

class UserHostCard extends StatelessWidget {
  const UserHostCard({super.key, required this.host, this.onTap});

  final DemoUserHost host;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 0.78,
                        child: Image.network(host.imageUrl, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: host.isOnline
                                ? const Color(0xFF3BC45B)
                                : const Color(0xFFC9C9C9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: UserFlagBadge(countryCode: host.countryCode),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 56,
                bottom: -2,
                child: _UserTierBadge(label: host.tierLabel),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            host.age > 0 ? '${host.name}, ${host.age}' : host.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFFE54184)),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  host.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A716D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            host.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8A633D)),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on,
                size: 16,
                color: Color(0xFFF1B62D),
              ),
              const SizedBox(width: 2),
              Text(
                '${host.pricePerMin} / Hour',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF1B62D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class _UserTierBadge extends StatelessWidget {
  const _UserTierBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final assetPath = _TierAssetResolver.assetPathFor(label);
    if (assetPath == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 64,
      height: 64,
      child: ColoredBox(
        color: Colors.transparent,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

class _FlagCodeFallback extends StatelessWidget {
  const _FlagCodeFallback({required this.countryCode});

  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4EFE7),
      child: Center(
        child: Text(
          countryCode.trim().toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF5F554B),
          ),
        ),
      ),
    );
  }
}

class _TierAssetResolver {
  static String? assetPathFor(String label) {
    switch (label.toLowerCase()) {
      case 'bronze':
      case 'basic':
        return 'lib/tier/bronze.PNG';
      case 'silver':
        return 'lib/tier/silver.PNG';
      case 'gold':
        return 'lib/tier/gold.PNG';
      case 'platinum':
        return 'lib/tier/platinum.PNG';
      case 'diamond':
      case 'vip':
        return 'lib/tier/diamond.PNG';
      default:
        return null;
    }
  }
}
