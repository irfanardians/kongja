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

import '../../shared/demo_schedule_store.dart';
import '../shared/review_composer_sheet.dart';
import 'user_ui_shared.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const List<_ReadyToReviewTalent> _seedReadyToReviewTalents = [
    _ReadyToReviewTalent(
      name: 'Clara',
      avatarUrl:
          'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=800',
      sessionLabel: 'Offline meet finished',
      dateLabel: 'Archived today',
    ),
    _ReadyToReviewTalent(
      name: 'Mia',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
      sessionLabel: 'Message session completed',
      dateLabel: 'Completed yesterday',
    ),
  ];
  static const List<_AnonymousTalentReview> _anonymousTalentReviews = [
    _AnonymousTalentReview(
      animalEmoji: '🦊',
      alias: 'Anonymous Fox',
      tierLabel: 'Gold Talent',
      rating: 5,
      dateLabel: '2 days ago',
      comment:
          'Very respectful and easy to communicate with. The meetup details were clear and the experience felt comfortable from start to finish.',
    ),
    _AnonymousTalentReview(
      animalEmoji: '🐼',
      alias: 'Anonymous Panda',
      tierLabel: 'Silver Talent',
      rating: 4,
      dateLabel: '5 days ago',
      comment:
          'Polite conversation and good energy throughout the session. I appreciated how organized the user was with schedule and location.',
    ),
    _AnonymousTalentReview(
      animalEmoji: '🦁',
      alias: 'Anonymous Lion',
      tierLabel: 'Platinum Talent',
      rating: 5,
      dateLabel: '1 week ago',
      comment:
          'Friendly, punctual, and thoughtful. The whole interaction felt safe and well prepared.',
    ),
    _AnonymousTalentReview(
      animalEmoji: '🐨',
      alias: 'Anonymous Koala',
      tierLabel: 'Bronze Talent',
      rating: 4,
      dateLabel: '2 weeks ago',
      comment:
          'Good overall experience. Fast replies and a very clear meetup plan made the session easier to manage.',
    ),
  ];

  late List<_ReadyToReviewTalent> _readyToReviewTalents;

  @override
  void initState() {
    super.initState();
    _readyToReviewTalents = List<_ReadyToReviewTalent>.from(
      _seedReadyToReviewTalents,
    );
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _openTalentReviews() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final averageRating =
            (_anonymousTalentReviews.fold<int>(
                      0,
                      (sum, review) => sum + review.rating,
                    ) /
                    _anonymousTalentReviews.length)
                .toStringAsFixed(1);

        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.65,
          maxChildSize: 0.94,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF7),
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Talent Reviews',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF241B15),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Reviews written by talents are shown anonymously.',
                              style: TextStyle(color: Color(0xFF887F79)),
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF3E6), Color(0xFFFFE8D4)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Average Rating',
                                style: TextStyle(color: Color(0xFF806B57)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                averageRating,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2B1F18),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => const Padding(
                                    padding: EdgeInsets.only(right: 2),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: Color(0xFFF1B62D),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 82,
                          height: 82,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('🐾', style: TextStyle(fontSize: 38)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ..._anonymousTalentReviews.map(_reviewCard),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitTalentReview(_ReadyToReviewTalent talent) async {
    final result = await showReviewComposerSheet(
      context: context,
      title: 'Review Talent',
      subtitle:
          'Add your rating, write an optional note, and attach a photo if needed.',
      targetName: talent.name,
      targetAvatar: talent.avatarUrl,
      sessionLabel: talent.sessionLabel,
      confirmLabel: 'Confirm Talent Review',
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _readyToReviewTalents = _readyToReviewTalents
          .where((item) => item != talent)
          .toList(growable: false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Review for ${talent.name} submitted with ${result.rating} stars.',
        ),
      ),
    );
  }

  Future<void> _openReadyToReviewTalents() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReadyToReviewTalentSheet(
        readyToReviewTalents: _readyToReviewTalents,
        onReviewTap: _submitTalentReview,
      ),
    );
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
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                      icon: const Icon(
                        Icons.settings_rounded,
                        color: Colors.white,
                      ),
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
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Alex Johnson',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'alex.johnson@email.com',
                                        style: TextStyle(
                                          color: Color(0xFF86807B),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 18,
                                            color: Color(0xFFF1B62D),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '4.8',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '(24 reviews)',
                                            style: TextStyle(
                                              color: Color(0xFFAAA39C),
                                              fontSize: 12,
                                            ),
                                          ),
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
                                  colors: [
                                    Color(0xFFFFF3E4),
                                    Color(0xFFFFEEDF),
                                  ],
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
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Coin Balance',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF7B746E),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '🪙 1,250',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pushNamed(context, '/topup'),
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
                      ValueListenableBuilder<List<DemoMeetRequest>>(
                        valueListenable: demoScheduleStore,
                        builder: (context, _, __) {
                          final userSchedules = demoScheduleStore
                              .requestsForUser(demoCurrentUserName)
                            ..sort(
                              (left, right) => right.date.compareTo(left.date),
                            );

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'My Schedule',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Lihat submit schedule dan keputusan talent di sini.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF8D8781),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                if (userSchedules.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7EE),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Text(
                                      'Belum ada schedule yang diajukan.',
                                      style: TextStyle(color: Color(0xFF6A625B)),
                                    ),
                                  )
                                else
                                  ...userSchedules.take(3).map(
                                    (request) => Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBF7),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: const Color(0xFFF0E6DA),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  request.hostName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              _scheduleStatusBadge(
                                                request.status,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${request.eventType} • ${request.dateLabel} • ${request.startTimeLabel}',
                                            style: const TextStyle(
                                              color: Color(0xFF665E58),
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            request.statusDescription,
                                            style: const TextStyle(
                                              color: Color(0xFF8D8781),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
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
                              iconBg: const Color(0xFFFFECEE),
                              iconColor: const Color(0xFFE34B57),
                              title: 'Ready to Review Talent',
                              subtitle: _readyToReviewTalents.isEmpty
                                  ? 'No talents are waiting for your review'
                                  : '${_readyToReviewTalents.length} completed or archived transaction${_readyToReviewTalents.length == 1 ? '' : 's'} waiting for review',
                              badgeCount: _readyToReviewTalents.length,
                              onTap: _openReadyToReviewTalents,
                            ),
                            _divider(),
                            _menuTile(
                              icon: Icons.rate_review_rounded,
                              iconBg: const Color(0xFFF2E8FF),
                              iconColor: const Color(0xFF7C4DFF),
                              title: 'Talent Reviews',
                              subtitle: 'Read anonymous reviews from talents',
                              onTap: _openTalentReviews,
                            ),
                            _divider(),
                            _menuTile(
                              icon: Icons.history_rounded,
                              iconBg: const Color(0xFFFFF0D6),
                              iconColor: userAmberDark,
                              title: 'Transaction History',
                              subtitle: 'View purchases & top ups',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/transactions'),
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

  Widget _divider() => const Divider(
    height: 1,
    indent: 68,
    endIndent: 20,
    color: Color(0xFFF1ECE6),
  );

  Widget _menuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8D8781),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badgeCount > 0)
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE34B57),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (badgeCount > 0) const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB8B0A8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(_AnonymousTalentReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE9D5), Color(0xFFFFF5E8)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    review.animalEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.alias,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      review.tierLabel,
                      style: const TextStyle(
                        color: Color(0xFF8C837C),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                review.dateLabel,
                style: const TextStyle(color: Color(0xFFAAA39C), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star_rounded,
                size: 18,
                color: index < review.rating
                    ? const Color(0xFFF1B62D)
                    : const Color(0xFFE2D9D1),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: const TextStyle(color: Color(0xFF5F5751), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _scheduleStatusBadge(DemoMeetRequestStatus status) {
    late final Color bgColor;
    late final Color textColor;
    late final String label;

    switch (status) {
      case DemoMeetRequestStatus.pending:
        bgColor = const Color(0xFFFFF3D6);
        textColor = const Color(0xFFB7791F);
        label = 'Submitted';
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
        bgColor = const Color(0xFFF0ECE8);
        textColor = const Color(0xFF8D8781);
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
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReadyToReviewTalent {
  const _ReadyToReviewTalent({
    required this.name,
    required this.avatarUrl,
    required this.sessionLabel,
    required this.dateLabel,
  });

  final String name;
  final String avatarUrl;
  final String sessionLabel;
  final String dateLabel;
}

class _ReadyToReviewTalentSheet extends StatelessWidget {
  const _ReadyToReviewTalentSheet({
    required this.readyToReviewTalents,
    required this.onReviewTap,
  });

  final List<_ReadyToReviewTalent> readyToReviewTalents;
  final Future<void> Function(_ReadyToReviewTalent talent) onReviewTap;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.68,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF7),
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ready to Review Talent',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF241B15),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Completed or archived transactions can be reviewed here.',
                          style: TextStyle(color: Color(0xFF887F79)),
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F3),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFF4C5CB)),
                ),
                child: Text(
                  readyToReviewTalents.isEmpty
                      ? 'No talents are waiting for your review right now.'
                      : '${readyToReviewTalents.length} talent${readyToReviewTalents.length == 1 ? '' : 's'} still need your review.',
                  style: const TextStyle(
                    color: Color(0xFF8B6F70),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (readyToReviewTalents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    'All completed sessions have been reviewed.',
                    style: TextStyle(color: Color(0xFF6A625B)),
                  ),
                )
              else
                ...readyToReviewTalents.map(
                  (talent) => Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(talent.avatarUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                talent.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                talent.sessionLabel,
                                style: const TextStyle(
                                  color: Color(0xFF7E746E),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                talent.dateLabel,
                                style: const TextStyle(
                                  color: Color(0xFFE34B57),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              onReviewTap(talent);
                            });
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2B211C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Review'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AnonymousTalentReview {
  const _AnonymousTalentReview({
    required this.animalEmoji,
    required this.alias,
    required this.tierLabel,
    required this.rating,
    required this.dateLabel,
    required this.comment,
  });

  final String animalEmoji;
  final String alias;
  final String tierLabel;
  final int rating;
  final String dateLabel;
  final String comment;
}
