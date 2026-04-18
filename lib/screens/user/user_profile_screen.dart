// Flutter translation of cocoa/src/app/pages/UserProfile.tsx
//
// Semua aksi dan input harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET/PATCH /user
// - POST /logout
//
// Komponen reusable dibuat di folder components terpisah.

import 'package:flutter/material.dart';

import 'user_ui_shared.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userCreamBackground,
      bottomNavigationBar: const UserBottomNav(currentRoute: '/user-profile'),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 84),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9E683B), Color(0xFFC67C42)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                          icon: const Icon(Icons.settings_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -52),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        const CircleAvatar(
                                          radius: 40,
                                          backgroundImage: NetworkImage(
                                            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                                          ),
                                        ),
                                        const Positioned(
                                          right: 2,
                                          top: 2,
                                          child: UserFlagBadge(countryCode: 'US'),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: userAmberDark,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Alex Johnson',
                                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'alex.johnson@email.com',
                                            style: TextStyle(color: Color(0xFF86807B), fontSize: 14),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: const [
                                              Icon(Icons.star_rounded, size: 18, color: Color(0xFFF1B62D)),
                                              SizedBox(width: 4),
                                              Text('4.8', style: TextStyle(fontWeight: FontWeight.w700)),
                                              SizedBox(width: 4),
                                              Text('(24 reviews)', style: TextStyle(color: Color(0xFFAAA39C), fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFF3E4), Color(0xFFFFEEDF)],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: const BoxDecoration(
                                          color: userAmberDark,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Coin Balance', style: TextStyle(fontSize: 13, color: Color(0xFF7B746E))),
                                            SizedBox(height: 2),
                                            Text('🪙 1,250', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pushNamed(context, '/topup'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: userAmberDark,
                                          foregroundColor: Colors.white,
                                          shape: const StadiumBorder(),
                                        ),
                                        child: const Text('Top Up'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                _menuTile(
                                  icon: Icons.rate_review_rounded,
                                  iconBg: const Color(0xFFF2E8FF),
                                  iconColor: const Color(0xFF7C4DFF),
                                  title: 'Review Talent',
                                  subtitle: 'Rate your experiences',
                                  onTap: () {},
                                ),
                                _divider(),
                                _menuTile(
                                  icon: Icons.history_rounded,
                                  iconBg: const Color(0xFFFFF0D6),
                                  iconColor: userAmberDark,
                                  title: 'Transaction History',
                                  subtitle: 'View purchases & top ups',
                                  onTap: () => Navigator.pushNamed(context, '/transactions'),
                                ),
                                _divider(),
                                _menuTile(
                                  icon: Icons.workspace_premium_rounded,
                                  iconBg: const Color(0xFFFFF8D9),
                                  iconColor: const Color(0xFFE0A100),
                                  title: 'Membership',
                                  subtitle: 'Upgrade to VIP',
                                  onTap: () {},
                                ),
                                _divider(),
                                _menuTile(
                                  icon: Icons.logout_rounded,
                                  iconBg: const Color(0xFFFFE4E4),
                                  iconColor: const Color(0xFFD54343),
                                  title: 'Logout',
                                  subtitle: 'Sign out of your account',
                                  onTap: _handleLogout,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 68, endIndent: 20, color: Color(0xFFF1ECE6));

  Widget _menuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF8D8781))),
    );
  }
}
