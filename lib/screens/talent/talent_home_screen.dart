// Flutter translation of cocoa/src/app/pages/TalentHome.tsx
//
// Semua komponen input/filter/list harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET /talent/home
//
// Komponen reusable dibuat di folder components terpisah.

import 'package:flutter/material.dart';

import '../../shared/demo_schedule_store.dart';
import 'talent_ui_shared.dart';

const List<_AnalyticsBarPoint> _demoWeeklyAnalytics = [
  _AnalyticsBarPoint('Mon', 280),
  _AnalyticsBarPoint('Tue', 420),
  _AnalyticsBarPoint('Wed', 350),
  _AnalyticsBarPoint('Thu', 480),
  _AnalyticsBarPoint('Fri', 390),
  _AnalyticsBarPoint('Sat', 520),
  _AnalyticsBarPoint('Sun', 310),
];

class TalentHomeScreen extends StatefulWidget {
  const TalentHomeScreen({Key? key}) : super(key: key);

  @override
  State<TalentHomeScreen> createState() => _TalentHomeScreenState();
}

class _TalentHomeScreenState extends State<TalentHomeScreen> {
  static const String _currentTalentHostName = 'Clara';

  // TODO: Ambil data talent home dari backend
  // Gunakan Provider/Bloc untuk fetch data

  bool isOnline = true;
  double currentRating = 4.8;
  int monthlyEarnings = 12500;
  bool showTierDetails = false;

  // Tier config mirip React
  final List<Map<String, dynamic>> tiers = [
    {
      'name': 'Bronze',
      'minCoins': 0,
      'maxCoins': 4999,
      'minRating': null,
      'color': Colors.amber,
      'bgGradient': [Color(0xFFF59E42), Color(0xFFB45309)],
      'badge': '🥉',
    },
    {
      'name': 'Silver',
      'minCoins': 5000,
      'maxCoins': 9999,
      'minRating': null,
      'color': Colors.grey,
      'bgGradient': [Color(0xFFD1D5DB), Color(0xFF6B7280)],
      'badge': '🥈',
    },
    {
      'name': 'Gold',
      'minCoins': 10000,
      'maxCoins': 19999,
      'minRating': null,
      'color': Colors.yellow,
      'bgGradient': [Color(0xFFFDE68A), Color(0xFFD97706)],
      'badge': '🥇',
    },
    {
      'name': 'Platinum',
      'minCoins': 20000,
      'maxCoins': 34999,
      'minRating': 4.7,
      'color': Colors.cyan,
      'bgGradient': [Color(0xFF67E8F9), Color(0xFF0891B2)],
      'badge': '💎',
    },
    {
      'name': 'Diamond',
      'minCoins': 35000,
      'maxCoins': null,
      'minRating': 4.7,
      'color': Colors.purple,
      'bgGradient': [Color(0xFFA78BFA), Color(0xFF6366F1)],
      'badge': '👑',
    },
  ];

  Map<String, dynamic> getCurrentTier() {
    Map<String, dynamic> eligibleTier = tiers[0];
    for (final tier in tiers) {
      final meetsCoins =
          monthlyEarnings >= tier['minCoins'] &&
          (tier['maxCoins'] == null || monthlyEarnings <= tier['maxCoins']);
      if (meetsCoins) {
        if (tier['minRating'] != null) {
          if (currentRating >= tier['minRating']) {
            eligibleTier = tier;
          } else {
            final goldTier = tiers[2];
            if (monthlyEarnings >= goldTier['minCoins'])
              eligibleTier = goldTier;
            break;
          }
        } else {
          eligibleTier = tier;
        }
      }
    }
    return eligibleTier;
  }

  Map<String, dynamic>? getNextTier(Map<String, dynamic> currentTier) {
    final idx = tiers.indexOf(currentTier);
    if (idx == tiers.length - 1) return null;
    return tiers[idx + 1];
  }

  double getProgress(
    Map<String, dynamic> currentTier,
    Map<String, dynamic>? nextTier,
  ) {
    if (nextTier == null) return 100;
    final currentMin = currentTier['minCoins'];
    final nextMin = nextTier['minCoins'];
    final range = nextMin - currentMin;
    final progress = ((monthlyEarnings - currentMin) / range) * 100;
    return progress.clamp(0, 100);
  }

  Future<void> _openScheduleSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          const _TalentScheduleSheet(hostName: _currentTalentHostName),
    );
  }

  Future<void> _openAvailabilitySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          const _TalentAvailabilitySheet(hostName: _currentTalentHostName),
    );
  }

  Future<void> _openAnalyticsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TalentAnalyticsSheet(),
    );
  }

  Future<void> _openAchievementsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TalentAchievementsSheet(
        tiers: tiers,
        currentTier: getCurrentTier(),
        nextTier: getNextTier(getCurrentTier()),
        progress: getProgress(getCurrentTier(), getNextTier(getCurrentTier())),
        currentRating: currentRating,
        monthlyEarnings: monthlyEarnings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = getCurrentTier();
    final nextTier = getNextTier(currentTier);
    final progress = getProgress(currentTier, nextTier);

    return ValueListenableBuilder<List<DemoMeetRequest>>(
      valueListenable: demoScheduleStore,
      builder: (context, meetRequests, _) {
        final pendingRequests = meetRequests
            .where((request) => request.status == DemoMeetRequestStatus.pending)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8E1),
          bottomNavigationBar: const TalentBottomNav(
            currentRoute: '/talent-home',
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Header gradient, avatar, tier badge, online toggle
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFB45309), Color(0xFFF59E42)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage: NetworkImage(
                                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.flag,
                                            size: 16,
                                            color: Colors.orange,
                                          ), // TODO: Ganti dengan widget bendera
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Welcome Back!',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: List<Color>.from(
                                                  currentTier['bgGradient'],
                                                ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Colors.white30,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 2,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  currentTier['badge'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  currentTier['name'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        'Jessica Martinez',
                                        style: TextStyle(
                                          color: Color(0xFFFFF7D6),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/talent-messages',
                                      );
                                    },
                                  ),
                                  if (pendingRequests.isNotEmpty)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${pendingRequests.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: isOnline
                                            ? Colors.green
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isOnline
                                          ? "You're Online"
                                          : "You're Offline",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: isOnline,
                                  onChanged: (val) {
                                    setState(() => isOnline = val);
                                    // TODO: Update status online ke backend
                                  },
                                  activeColor: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tier status card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.emoji_events, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'Your Tier Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: List<Color>.from(
                                  currentTier['bgGradient'],
                                ),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          currentTier['badge'],
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Current Tier',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              currentTier['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        showTierDetails
                                            ? Icons.keyboard_arrow_down
                                            : Icons.chevron_right,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () => showTierDetails =
                                              !showTierDetails,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'This Month',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              '🪙 ${monthlyEarnings.toString()}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Rating',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              '⭐ $currentRating',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (nextTier != null) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Progress to ${nextTier['name']}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${progress.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progress / 100,
                                      minHeight: 8,
                                      backgroundColor: Colors.white30,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '🪙 $monthlyEarnings',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '🪙 ${nextTier['minCoins']}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (nextTier['minRating'] != null &&
                                      currentRating < nextTier['minRating'])
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '⚠️ You need a minimum rating of ${nextTier['minRating']} to unlock ${nextTier['name']} tier. Current rating: $currentRating',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ] else ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '🎉 Congratulations! You\'ve reached the highest tier!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (showTierDetails)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: tiers.map((tier) {
                                  final isCurrent =
                                      tier['name'] == currentTier['name'];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? Colors.amber[50]
                                          : Colors.transparent,
                                      border: isCurrent
                                          ? Border(
                                              left: BorderSide(
                                                color: Colors.amber,
                                                width: 4,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          tier['badge'],
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  tier['name'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: tier['color'],
                                                  ),
                                                ),
                                                if (isCurrent)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 8,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'CURRENT',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Text(
                                              '💰 Earn: 🪙 ${tier['minCoins']}${tier['maxCoins'] != null ? ' - ${tier['maxCoins']}' : '+'} / month',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            if (tier['minRating'] != null)
                                              Text(
                                                '⭐ Rating: Minimum ${tier['minRating']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Statistik, quick actions, earnings, recent chats, schedule, logout
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.monetization_on,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Today's Earnings",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '🪙 450',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: const [
                                  Icon(Icons.chat, color: Colors.blue),
                                  SizedBox(height: 8),
                                  Text(
                                    'Active Chats',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '12',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _quickActionButton(
                                Icons.calendar_today,
                                'Schedule',
                                Colors.blue[100]!,
                                Colors.blue,
                                _openScheduleSheet,
                              ),
                              _quickActionButton(
                                Icons.trending_up,
                                'Analytics',
                                Colors.purple[100]!,
                                Colors.purple,
                                _openAnalyticsSheet,
                              ),
                              _quickActionButton(
                                Icons.emoji_events,
                                'Achievements',
                                Colors.amber[100]!,
                                Colors.amber,
                                _openAchievementsSheet,
                              ),
                              _quickActionButton(
                                Icons.calendar_month,
                                'Availability',
                                Colors.green[100]!,
                                Colors.green,
                                _openAvailabilitySheet,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Earnings This Week
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22C55E), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "This Week's Earnings",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.monetization_on,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '🪙 2,450 Coins',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              '↑ 23% from last week',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Total hours: 34.5h',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recent Chats
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Chats',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'View All',
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: Column(
                              children: [
                                _chatTile(
                                  'Sarah Johnson',
                                  'Thank you for the chat!',
                                  '2 min ago',
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                                  2,
                                ),
                                _chatTile(
                                  'Mike Chen',
                                  'Are you available now?',
                                  '15 min ago',
                                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                                  1,
                                ),
                                _chatTile(
                                  'Emma Wilson',
                                  'Great conversation!',
                                  '1 hr ago',
                                  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
                                  0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Today's Schedule
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Today's Schedule",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (pendingRequests.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE4C7),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${pendingRequests.length} new request',
                                    style: const TextStyle(
                                      color: Color(0xFFB45309),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (pendingRequests.isEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.people,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'No offline requests yet',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Confirmed meet requests from users will appear here',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: const Text(
                                      'Once a user confirms Meet Offline from the profile screen, the schedule request will appear here as a pending request for the talent.',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: pendingRequests
                                  .take(3)
                                  .map(_scheduleRequestCard)
                                  .toList(),
                            ),
                        ],
                      ),
                    ),

                    // Logout
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          onPressed: () {
                            // TODO: Logout logic
                            Navigator.pushNamed(context, '/login');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickActionButton(
    IconData icon,
    String label,
    Color bg,
    Color fg,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: fg),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _chatTile(
    String name,
    String message,
    String time,
    String avatarUrl,
    int unread,
  ) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl), radius: 24),
          if (unread > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$unread',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 12, color: Colors.black45),
      ),
      onTap: () {
        // TODO: Navigate to chat detail
      },
    );
  }

  Widget _scheduleRequestCard(DemoMeetRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(request.userAvatar),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Requested ${request.requestedAtLabel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Color(0xFFCA6C34),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _scheduleTag(Icons.auto_awesome_rounded, request.eventType),
                _scheduleTag(
                  Icons.monetization_on_outlined,
                  '🪙 ${request.coins} coins',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _scheduleDetail(
              Icons.calendar_today_rounded,
              'Date',
              request.dateLabel,
            ),
            _scheduleDetail(
              Icons.schedule_rounded,
              'Time',
              '${request.startTimeLabel} - ${request.endTimeLabel} • ${request.durationLabel}',
            ),
            _scheduleDetail(
              Icons.location_on_outlined,
              'Location',
              request.meetingAddress,
            ),
            _scheduleDetail(Icons.place_outlined, 'Landmark', request.landmark),
          ],
        ),
      ),
    );
  }

  Widget _scheduleDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFB45309)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF221A14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFB45309)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7D4C16),
            ),
          ),
        ],
      ),
    );
  }
}

class _TalentScheduleSheet extends StatefulWidget {
  const _TalentScheduleSheet({required this.hostName});

  final String hostName;

  @override
  State<_TalentScheduleSheet> createState() => _TalentScheduleSheetState();
}

class _TalentScheduleSheetState extends State<_TalentScheduleSheet> {
  String _activeTab = 'pending';

  @override
  Widget build(BuildContext context) {
    return _TalentSheetFrame(
      title: 'Booking Schedule',
      subtitle: 'Manage booking requests and accepted sessions',
      child: ValueListenableBuilder<List<DemoMeetRequest>>(
        valueListenable: demoScheduleStore,
        builder: (context, requests, _) {
          final hostRequests = requests
              .where((item) => item.hostName == widget.hostName)
              .toList();
          final filtered = hostRequests.where((item) {
            switch (_activeTab) {
              case 'pending':
                return item.status == DemoMeetRequestStatus.pending;
              case 'upcoming':
                return item.status == DemoMeetRequestStatus.accepted;
              default:
                return item.status == DemoMeetRequestStatus.rejected ||
                  item.status == DemoMeetRequestStatus.cancelled ||
                    item.status == DemoMeetRequestStatus.completed;
            }
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _scheduleTab(
                    'pending',
                    'Pending',
                    hostRequests
                        .where(
                          (item) =>
                              item.status == DemoMeetRequestStatus.pending,
                        )
                        .length,
                  ),
                  const SizedBox(width: 8),
                  _scheduleTab('upcoming', 'Upcoming', null),
                  const SizedBox(width: 8),
                  _scheduleTab('history', 'History', null),
                ],
              ),
              const SizedBox(height: 18),
              if (filtered.isEmpty)
                _EmptyTalentState(
                  icon: Icons.event_note_rounded,
                  title: 'No bookings in this section',
                  subtitle:
                      'New requests and session updates will appear here.',
                )
              else
                ...filtered.map(
                  (request) => _scheduleSheetCard(context, request),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _scheduleTab(String value, String label, int? badge) {
    final isActive = _activeTab == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFB45309) : const Color(0xFFF6ECE3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF6D5B4E),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              if (badge != null && badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.22)
                        : const Color(0xFFE34A57),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _scheduleSheetCard(BuildContext context, DemoMeetRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(request.userAvatar),
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Requested ${request.requestedAtLabel}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(request.status),
            ],
          ),
          const SizedBox(height: 14),
          _detailRow(Icons.calendar_today_rounded, 'Date', request.dateLabel),
          _detailRow(
            Icons.schedule_rounded,
            'Time',
            '${request.startTimeLabel} - ${request.endTimeLabel} • ${request.durationLabel}',
          ),
          _detailRow(
            Icons.location_on_outlined,
            'Location',
            request.meetingAddress,
          ),
          _detailRow(Icons.place_outlined, 'Landmark', request.landmark),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillTag(Icons.auto_awesome_rounded, request.eventType),
              _pillTag(
                Icons.monetization_on_outlined,
                '🪙 ${request.coins} coins',
              ),
            ],
          ),
          if (request.status == DemoMeetRequestStatus.pending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      demoScheduleStore.updateRequestStatus(
                        request.id,
                        DemoMeetRequestStatus.accepted,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Booking accepted for ${request.userName}.',
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2BAE66),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      demoScheduleStore.updateRequestStatus(
                        request.id,
                        DemoMeetRequestStatus.rejected,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Booking declined for ${request.userName}.',
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD54343),
                      side: const BorderSide(color: Color(0xFFF0B1B1)),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Decline'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFB45309)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF221A14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFB45309)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7D4C16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(DemoMeetRequestStatus status) {
    late final Color bgColor;
    late final Color textColor;
    late final String label;
    switch (status) {
      case DemoMeetRequestStatus.pending:
        bgColor = const Color(0xFFFFF3D6);
        textColor = const Color(0xFFB7791F);
        label = 'Pending';
        break;
      case DemoMeetRequestStatus.accepted:
        bgColor = const Color(0xFFE6F7EC);
        textColor = const Color(0xFF218C4F);
        label = 'Accepted';
        break;
      case DemoMeetRequestStatus.rejected:
        bgColor = const Color(0xFFFFE8E8);
        textColor = const Color(0xFFD54343);
        label = 'Rejected';
        break;
      case DemoMeetRequestStatus.cancelled:
        bgColor = const Color(0xFFFFE8E8);
        textColor = const Color(0xFFD54343);
        label = 'Cancelled';
        break;
      case DemoMeetRequestStatus.completed:
        bgColor = const Color(0xFFE8F1FF);
        textColor = const Color(0xFF356AC3);
        label = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TalentAvailabilitySheet extends StatefulWidget {
  const _TalentAvailabilitySheet({required this.hostName});

  final String hostName;

  @override
  State<_TalentAvailabilitySheet> createState() =>
      _TalentAvailabilitySheetState();
}

class _TalentAvailabilitySheetState extends State<_TalentAvailabilitySheet> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return _TalentSheetFrame(
      title: 'Set Availability',
      subtitle: 'Mark green days as available and red days as holiday/offline.',
      child: ValueListenableBuilder<List<DemoMeetRequest>>(
        valueListenable: demoScheduleStore,
        builder: (context, _, __) {
          final cells = _calendarCells();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD1E5FF)),
                ),
                child: const Text(
                  'Tap any future date to toggle availability. Red dates are unavailable to users. Dates with active bookings cannot be changed.',
                  style: TextStyle(color: Color(0xFF3A6EA5), height: 1.45),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(
                      () => _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      ),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    _monthLabel(_selectedMonth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(
                      () => _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _LegendDot(color: Color(0xFF4CAF50), label: 'Available'),
                  SizedBox(width: 16),
                  _LegendDot(color: Color(0xFFE34A57), label: 'Holiday'),
                  SizedBox(width: 16),
                  _LegendDot(color: Color(0xFF8C95A2), label: 'Booked'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(child: Center(child: Text('Sun'))),
                  Expanded(child: Center(child: Text('Mon'))),
                  Expanded(child: Center(child: Text('Tue'))),
                  Expanded(child: Center(child: Text('Wed'))),
                  Expanded(child: Center(child: Text('Thu'))),
                  Expanded(child: Center(child: Text('Fri'))),
                  Expanded(child: Center(child: Text('Sat'))),
                ],
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cells.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final cell = cells[index];
                  return _availabilityCell(cell);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<_AvailabilityCalendarCell> _calendarCells() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final leading = firstDay.weekday % 7;
    final cells = <_AvailabilityCalendarCell>[];
    final today = normalizeDemoDate(DateTime.now());

    for (var index = 0; index < 42; index++) {
      final date = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        1 + index - leading,
      );
      final normalized = normalizeDemoDate(date);
      final isCurrentMonth = date.month == _selectedMonth.month;
      final isPast = normalized.isBefore(today);
      final isHoliday =
          isCurrentMonth &&
          demoScheduleStore.isTalentHoliday(
            hostName: widget.hostName,
            date: normalized,
          );
      final isBooked =
          isCurrentMonth &&
          demoScheduleStore.hasActiveBookingOnDate(
            hostName: widget.hostName,
            date: normalized,
          );
      final canToggle =
          isCurrentMonth &&
          !isPast &&
          demoScheduleStore.canToggleHolidayDate(
            hostName: widget.hostName,
            date: normalized,
          );
      cells.add(
        _AvailabilityCalendarCell(
          date: normalized,
          day: date.day,
          isCurrentMonth: isCurrentMonth,
          isPast: isPast,
          isHoliday: isHoliday,
          isBooked: isBooked,
          canToggle: canToggle,
        ),
      );
    }
    return cells;
  }

  Future<void> _confirmAvailabilityToggle(
    _AvailabilityCalendarCell cell,
  ) async {
    final isClosingDate = !cell.isHoliday;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isClosingDate ? 'Close this date?' : 'Reopen this date?'),
        content: Text(
          isClosingDate
              ? 'This will mark ${formatDemoDate(cell.date)} as unavailable, and users will not be able to book this date.'
              : 'This will reopen ${formatDemoDate(cell.date)} and make it available for users to book again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: isClosingDate
                  ? const Color(0xFFE34A57)
                  : const Color(0xFF2BAE66),
              foregroundColor: Colors.white,
            ),
            child: Text(isClosingDate ? 'Close Date' : 'Open Date'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    demoScheduleStore.toggleHolidayDate(
      hostName: widget.hostName,
      date: cell.date,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isClosingDate
              ? '${formatDemoDate(cell.date)} has been marked as unavailable.'
              : '${formatDemoDate(cell.date)} is now open for bookings again.',
        ),
      ),
    );
  }

  Widget _availabilityCell(_AvailabilityCalendarCell cell) {
    Color bg = const Color(0xFFE8F6EA);
    Color border = const Color(0xFF4CAF50);
    Color text = const Color(0xFF2F7D32);

    if (!cell.isCurrentMonth || cell.isPast) {
      bg = const Color(0xFFF6F0E9);
      border = const Color(0xFFE4D9CC);
      text = const Color(0xFFC4B8AC);
    } else if (cell.isBooked) {
      bg = const Color(0xFFF2F4F7);
      border = const Color(0xFF8C95A2);
      text = const Color(0xFF707B88);
    } else if (cell.isHoliday) {
      bg = const Color(0xFFFFE8EB);
      border = const Color(0xFFE34A57);
      text = const Color(0xFFE34A57);
    }

    return InkWell(
      onTap: cell.canToggle ? () => _confirmAvailabilityToggle(cell) : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${cell.day}',
                style: TextStyle(fontWeight: FontWeight.w700, color: text),
              ),
            ),
            if (cell.isCurrentMonth && !cell.isPast)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  cell.isBooked
                      ? Icons.lock_rounded
                      : (cell.isHoliday
                            ? Icons.close_rounded
                            : Icons.check_rounded),
                  size: 12,
                  color: text,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(DateTime month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[month.month - 1]} ${month.year}';
  }
}

class _TalentAnalyticsSheet extends StatelessWidget {
  const _TalentAnalyticsSheet();

  @override
  Widget build(BuildContext context) {
    final maxEarnings = _demoWeeklyAnalytics
        .map((item) => item.earnings)
        .reduce((a, b) => a > b ? a : b);
    return _TalentSheetFrame(
      title: 'Analytics',
      subtitle: 'Track your performance and weekly progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: const [
              _AnalyticsStatCard(
                title: 'This Month',
                value: '🪙 8,450',
                trend: '+15%',
                trendUp: true,
                icon: Icons.attach_money_rounded,
                iconColor: Color(0xFF2BAE66),
              ),
              _AnalyticsStatCard(
                title: 'Total Hours',
                value: '142.5h',
                trend: '+8%',
                trendUp: true,
                icon: Icons.schedule_rounded,
                iconColor: Color(0xFF356AC3),
              ),
              _AnalyticsStatCard(
                title: 'Total Chats',
                value: '156',
                trend: '-3%',
                trendUp: false,
                icon: Icons.chat_bubble_rounded,
                iconColor: Color(0xFF8B5CF6),
              ),
              _AnalyticsStatCard(
                title: 'Avg / Hour',
                value: '🪙 59',
                trend: '+12%',
                trendUp: true,
                icon: Icons.people_alt_rounded,
                iconColor: Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Weekly Earnings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Last 7 days',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _demoWeeklyAnalytics.map((point) {
                      final height = (point.earnings / maxEarnings) * 110 + 18;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${point.earnings}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 26,
                              height: height,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Color(0xFFB45309),
                                    Color(0xFFF2B267),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              point.day,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Performance Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const _InsightCard(
            color: Color(0xFFEAF8EF),
            accent: Color(0xFF2BAE66),
            icon: Icons.trending_up_rounded,
            title: 'Great Performance!',
            description:
                'Your earnings are 15% higher than last month. Keep this momentum going.',
          ),
          const SizedBox(height: 10),
          const _InsightCard(
            color: Color(0xFFEAF2FF),
            accent: Color(0xFF356AC3),
            icon: Icons.schedule_rounded,
            title: 'Peak Time: 7PM - 10PM',
            description:
                'Most users connect during evening hours. Staying online then can improve earnings.',
          ),
          const SizedBox(height: 10),
          const _InsightCard(
            color: Color(0xFFFFF6E7),
            accent: Color(0xFFD97706),
            icon: Icons.people_alt_rounded,
            title: 'Response Rate: 92%',
            description:
                'Excellent response speed. Users are more likely to book when you reply quickly.',
          ),
          const SizedBox(height: 18),
          const Text(
            'Monthly Goals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const _GoalProgress(
            label: 'Earnings Goal',
            value: '🪙 8,450 / 10,000',
            progress: 0.845,
          ),
          const SizedBox(height: 10),
          const _GoalProgress(
            label: 'Hours Goal',
            value: '142.5h / 160h',
            progress: 0.89,
          ),
        ],
      ),
    );
  }
}

class _TalentAchievementsSheet extends StatelessWidget {
  const _TalentAchievementsSheet({
    required this.tiers,
    required this.currentTier,
    required this.nextTier,
    required this.progress,
    required this.currentRating,
    required this.monthlyEarnings,
  });

  final List<Map<String, dynamic>> tiers;
  final Map<String, dynamic> currentTier;
  final Map<String, dynamic>? nextTier;
  final double progress;
  final double currentRating;
  final int monthlyEarnings;

  @override
  Widget build(BuildContext context) {
    return _TalentSheetFrame(
      title: 'Achievements',
      subtitle: 'View your tier progress, unlocked badges, and next rewards',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: List<Color>.from(currentTier['bgGradient']),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      currentTier['badge'],
                      style: const TextStyle(fontSize: 34),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Tier',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            currentTier['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Monthly Earnings: 🪙 $monthlyEarnings',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rating: ⭐ $currentRating',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (nextTier != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress to ${nextTier!['name']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: progress / 100,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tier Ladder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...tiers.map((tier) {
            final isCurrent = tier['name'] == currentTier['name'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrent ? const Color(0xFFFFF7E8) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFFE0A100)
                      : const Color(0xFFF0E7DD),
                ),
              ),
              child: Row(
                children: [
                  Text(tier['badge'], style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Earn 🪙 ${tier['minCoins']}${tier['maxCoins'] != null ? ' - ${tier['maxCoins']}' : '+'} per month',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        if (tier['minRating'] != null)
                          Text(
                            'Requires minimum ⭐ ${tier['minRating']}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0A100),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'CURRENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TalentSheetFrame extends StatelessWidget {
  const _TalentSheetFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.68,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8CCC0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Builder(
                builder: (context) => Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF241B15),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(color: Color(0xFF887F79)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        );
      },
    );
  }
}

class _EmptyTalentState extends StatelessWidget {
  const _EmptyTalentState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1E3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: Color(0xFFB45309)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7A6E63),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityCalendarCell {
  const _AvailabilityCalendarCell({
    required this.date,
    required this.day,
    required this.isCurrentMonth,
    required this.isPast,
    required this.isHoliday,
    required this.isBooked,
    required this.canToggle,
  });

  final DateTime date;
  final int day;
  final bool isCurrentMonth;
  final bool isPast;
  final bool isHoliday;
  final bool isBooked;
  final bool canToggle;
}

class _AnalyticsBarPoint {
  const _AnalyticsBarPoint(this.day, this.earnings);

  final String day;
  final int earnings;
}

class _AnalyticsStatCard extends StatelessWidget {
  const _AnalyticsStatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String trend;
  final bool trendUp;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                trendUp
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 16,
                color: trendUp
                    ? const Color(0xFF2BAE66)
                    : const Color(0xFFD54343),
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  color: trendUp
                      ? const Color(0xFF2BAE66)
                      : const Color(0xFFD54343),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.color,
    required this.accent,
    required this.icon,
    required this.title,
    required this.description,
  });

  final Color color;
  final Color accent;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalProgress extends StatelessWidget {
  const _GoalProgress({
    required this.label,
    required this.value,
    required this.progress,
  });

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1E7DB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
