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

import 'talent_ui_shared.dart';

class TalentHomeScreen extends StatefulWidget {
  const TalentHomeScreen({Key? key}) : super(key: key);

  @override
  State<TalentHomeScreen> createState() => _TalentHomeScreenState();
}

class _TalentHomeScreenState extends State<TalentHomeScreen> {
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
      final meetsCoins = monthlyEarnings >= tier['minCoins'] && (tier['maxCoins'] == null || monthlyEarnings <= tier['maxCoins']);
      if (meetsCoins) {
        if (tier['minRating'] != null) {
          if (currentRating >= tier['minRating']) {
            eligibleTier = tier;
          } else {
            final goldTier = tiers[2];
            if (monthlyEarnings >= goldTier['minCoins']) eligibleTier = goldTier;
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

  double getProgress(Map<String, dynamic> currentTier, Map<String, dynamic>? nextTier) {
    if (nextTier == null) return 100;
    final currentMin = currentTier['minCoins'];
    final nextMin = nextTier['minCoins'];
    final range = nextMin - currentMin;
    final progress = ((monthlyEarnings - currentMin) / range) * 100;
    return progress.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = getCurrentTier();
    final nextTier = getNextTier(currentTier);
    final progress = getProgress(currentTier, nextTier);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      bottomNavigationBar: const TalentBottomNav(currentRoute: '/talent-home'),
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
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
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
                                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100'),
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
                                  child: const Icon(Icons.flag, size: 16, color: Colors.orange), // TODO: Ganti dengan widget bendera
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Welcome Back!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: List<Color>.from(currentTier['bgGradient'])),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    child: Row(
                                      children: [
                                        Text(currentTier['badge'], style: const TextStyle(fontSize: 16)),
                                        const SizedBox(width: 4),
                                        Text(currentTier['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Text('Jessica Martinez', style: TextStyle(color: Color(0xFFFFF7D6), fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications, color: Colors.white),
                            onPressed: () {
                              Navigator.pushNamed(context, '/talent-messages');
                            },
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 10))),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(isOnline ? "You're Online" : "You're Offline", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
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
                      Text('Your Tier Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: List<Color>.from(currentTier['bgGradient'])),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(currentTier['badge'], style: const TextStyle(fontSize: 32)),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Current Tier', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    Text(currentTier['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(showTierDetails ? Icons.keyboard_arrow_down : Icons.chevron_right, color: Colors.white),
                              onPressed: () {
                                setState(() => showTierDetails = !showTierDetails);
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('This Month', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    Text('🪙 ${monthlyEarnings.toString()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Rating', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    Text('⭐ $currentRating', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (nextTier != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Progress to ${nextTier['name']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text('${progress.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 8,
                              backgroundColor: Colors.white30,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('🪙 $monthlyEarnings', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text('🪙 ${nextTier['minCoins']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          if (nextTier['minRating'] != null && currentRating < nextTier['minRating'])
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('⚠️ You need a minimum rating of ${nextTier['minRating']} to unlock ${nextTier['name']} tier. Current rating: $currentRating', style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                              child: Text('🎉 Congratulations! You\'ve reached the highest tier!', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
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
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: Column(
                        children: tiers.map((tier) {
                          final isCurrent = tier['name'] == currentTier['name'];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrent ? Colors.amber[50] : Colors.transparent,
                              border: isCurrent ? Border(left: BorderSide(color: Colors.amber, width: 4)) : null,
                            ),
                            child: Row(
                              children: [
                                Text(tier['badge'], style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(tier['name'], style: TextStyle(fontWeight: FontWeight.bold, color: tier['color'])),
                                        if (isCurrent)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                                            child: const Text('CURRENT', style: TextStyle(color: Colors.white, fontSize: 10)),
                                          ),
                                      ],
                                    ),
                                    Text('💰 Earn: 🪙 ${tier['minCoins']}${tier['maxCoins'] != null ? ' - ${tier['maxCoins']}' : '+'} / month', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    if (tier['minRating'] != null)
                                      Text('⭐ Rating: Minimum ${tier['minRating']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
                          Icon(Icons.monetization_on, color: Colors.green),
                          SizedBox(height: 8),
                          Text("Today's Earnings", style: TextStyle(fontSize: 13, color: Colors.black54)),
                          Text('🪙 450', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                          Text('Active Chats', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          Text('12', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _quickActionButton(Icons.calendar_today, 'Schedule', Colors.blue[100]!, Colors.blue),
                      _quickActionButton(Icons.trending_up, 'Analytics', Colors.purple[100]!, Colors.purple),
                      _quickActionButton(Icons.emoji_events, 'Achievements', Colors.amber[100]!, Colors.amber),
                      _quickActionButton(Icons.calendar_month, 'Availability', Colors.green[100]!, Colors.green),
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
                  gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF059669)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("This Week's Earnings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Icon(Icons.monetization_on, color: Colors.white),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('🪙 2,450 Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                    Text('↑ 23% from last week', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('Total hours: 34.5h', style: TextStyle(color: Colors.white, fontSize: 13)),
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
                      const Text('Recent Chats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All', style: TextStyle(color: Colors.amber)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      children: [
                        _chatTile('Sarah Johnson', 'Thank you for the chat!', '2 min ago', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 2),
                        _chatTile('Mike Chen', 'Are you available now?', '15 min ago', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', 1),
                        _chatTile('Emma Wilson', 'Great conversation!', '1 hr ago', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', 0),
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
                  const Text("Today's Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.people, color: Colors.blue),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Peak Hours (6PM - 10PM)', style: TextStyle(fontWeight: FontWeight.w500)),
                                Text('Best time to go online', style: TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
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
                          child: const Text('💡 Tip: Most users are active during evening hours. Going online now can boost your earnings!', style: TextStyle(color: Colors.blue, fontSize: 13)),
                        ),
                      ],
                    ),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
  }

  Widget _quickActionButton(IconData icon, String label, Color bg, Color fg) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // TODO: Handle quick action
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: fg),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _chatTile(String name, String message, String time, String avatarUrl, int unread) {
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
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Center(child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10))),
              ),
            ),
        ],
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(time, style: const TextStyle(fontSize: 12, color: Colors.black45)),
      onTap: () {
        // TODO: Navigate to chat detail
      },
    );
  }
}
