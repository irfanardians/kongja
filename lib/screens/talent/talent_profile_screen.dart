// Flutter translation of cocoa/src/app/pages/TalentProfile.tsx
//
// Semua aksi dan input harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET /talent/profile/:id
// - PATCH /talent/profile
//
// Komponen reusable dibuat di folder components terpisah.

import 'package:flutter/material.dart';

import 'talent_ui_shared.dart';

class TalentProfileScreen extends StatefulWidget {
  const TalentProfileScreen({Key? key}) : super(key: key);

  @override
  State<TalentProfileScreen> createState() => _TalentProfileScreenState();
}

class _TalentProfileScreenState extends State<TalentProfileScreen> {
  // TODO: Ambil data profile talent dari backend
  bool isOnline = true;
  int coinBalance = 4580;
  double rating = 4.8;
  int reviews = 234;
  List<String> portfolioPhotos = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    'https://images.unsplash.com/photo-1762343040706-b74ea936c1c0?w=400',
    'https://images.unsplash.com/photo-1773955779694-42b1fba71f72?w=400',
    'https://images.unsplash.com/photo-1675275372275-0a5e5f0a9fa6?w=400',
    'https://images.unsplash.com/photo-1758467796950-1da4615c97b5?w=400',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      bottomNavigationBar: const TalentBottomNav(currentRoute: '/talent-profile'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB45309), Color(0xFFF59E42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/talent-settings');
                    },
                  ),
                ],
              ),
            ),

            // Profile Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                transform: Matrix4.translationValues(0, -40, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isOnline ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Jessica Martinez', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.amber),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const Text('jessica.martinez@email.com', style: TextStyle(color: Colors.black54, fontSize: 14)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text('$rating', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  const Text('•', style: TextStyle(color: Colors.black26)),
                                  const SizedBox(width: 8),
                                  Text('$reviews reviews', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFF7D6), Color(0xFFFFEDD5)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isOnline ? "You're Online" : "You're Offline", style: const TextStyle(fontWeight: FontWeight.w500)),
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
            ),

            // Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Stats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard(Icons.account_balance_wallet, 'Total Earnings', '🪙 45,230'),
                      const SizedBox(width: 12),
                      _statCard(Icons.access_time, 'Total Hours', '582h'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statCard(Icons.chat, 'Total Chats', '1,234'),
                      const SizedBox(width: 12),
                      _statCard(Icons.remove_red_eye, 'Profile Views', '12.5k'),
                    ],
                  ),
                ],
              ),
            ),

            // Portfolio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.photo_library, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('My Portfolio', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('+ Add Photos', style: TextStyle(color: Colors.amber)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: portfolioPhotos.length,
                        separatorBuilder: (context, idx) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(portfolioPhotos[idx], width: 70, height: 70, fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('${portfolioPhotos.length} photos • Users can view your portfolio on your profile', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ),
                  ],
                ),
              ),
            ),

            // Coin Balance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF059669)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text('🪙 $coinBalance Coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // TODO: Withdraw earnings
                          },
                          child: const Text('Withdraw Earnings'),
                        ),
                      ],
                    ),
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                  ],
                ),
              ),
            ),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Column(
                  children: [
                    _menuTile(Icons.emoji_events, 'Achievements', 'View your badges & rewards'),
                    _menuTile(Icons.access_time, 'Schedule & Availability', 'Manage your working hours'),
                    _menuTile(Icons.account_balance_wallet, 'Payment History', 'View withdrawals & earnings'),
                    _menuTile(Icons.settings, 'Settings', 'Privacy & preferences', onTap: () {
                      Navigator.pushNamed(context, '/talent-settings');
                    }),
                  ],
                ),
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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

  Widget _statCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.amber[700], size: 18),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: Colors.amber[700]),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: onTap,
    );
  }
}
