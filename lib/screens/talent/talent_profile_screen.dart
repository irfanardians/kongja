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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/demo_schedule_store.dart';
import '../shared/review_composer_sheet.dart';
import 'talent_ui_shared.dart';

class TalentProfileScreen extends StatefulWidget {
  const TalentProfileScreen({Key? key}) : super(key: key);

  @override
  State<TalentProfileScreen> createState() => _TalentProfileScreenState();
}

class _TalentProfileScreenState extends State<TalentProfileScreen> {
  // TODO: Ambil data profile talent dari backend
  static const String _currentTalentHostName = 'Clara';
  static const int _totalEarnedCoins = 45230;
  static const List<_ReadyToReviewUser> _seedReadyToReviewUsers = [
    _ReadyToReviewUser(
      name: 'Sarah Johnson',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      sessionLabel: 'Dinner companion',
      dateLabel: 'Completed today',
    ),
    _ReadyToReviewUser(
      name: 'Mike Chen',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      sessionLabel: 'City walk meet-up',
      dateLabel: 'Completed yesterday',
    ),
  ];
  final ImagePicker _imagePicker = ImagePicker();
  late List<_ReadyToReviewUser> _readyToReviewUsers;
  late List<_PaymentHistoryItem> _paymentHistoryItems;
  bool isOnline = true;
  int coinBalance = 4580;
  double rating = 4.8;
  int reviews = 234;
  _TalentPhoto profilePhoto = const _TalentPhoto.network(
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
  );
  List<_TalentPhoto> portfolioPhotos = const [
    _TalentPhoto.network(
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    ),
    _TalentPhoto.network(
      'https://images.unsplash.com/photo-1762343040706-b74ea936c1c0?w=400',
    ),
    _TalentPhoto.network(
      'https://images.unsplash.com/photo-1773955779694-42b1fba71f72?w=400',
    ),
    _TalentPhoto.network(
      'https://images.unsplash.com/photo-1675275372275-0a5e5f0a9fa6?w=400',
    ),
    _TalentPhoto.network(
      'https://images.unsplash.com/photo-1758467796950-1da4615c97b5?w=400',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _readyToReviewUsers = List<_ReadyToReviewUser>.from(
      _seedReadyToReviewUsers,
    );
    _paymentHistoryItems = List<_PaymentHistoryItem>.from(
      _TalentPaymentHistorySheet.seedItems,
    );
  }

  Future<void> _pickPortfolioPhoto() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );

    if (pickedFile == null || !mounted) {
      return;
    }

    setState(() {
      portfolioPhotos = [
        _TalentPhoto.file(pickedFile.path),
        ...portfolioPhotos,
      ];
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Photo added to portfolio.')));
  }

  Future<void> _pickProfilePhoto() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );

    if (pickedFile == null || !mounted) {
      return;
    }

    setState(() {
      profilePhoto = _TalentPhoto.file(pickedFile.path);
    });
  }

  Future<void> _openPortfolioPreview(int initialIndex) async {
    final controller = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Portfolio preview',
      barrierColor: Colors.black.withValues(alpha: 0.94),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: PageView.builder(
                      controller: controller,
                      itemCount: portfolioPhotos.length,
                      onPageChanged: (index) =>
                          setModalState(() => currentIndex = index),
                      itemBuilder: (context, index) {
                        final photo = portfolioPhotos[index];
                        return InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Center(
                            child: photo.buildImage(fit: BoxFit.contain),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${currentIndex + 1} / ${portfolioPhotos.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 30,
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
      },
    );

    controller.dispose();
  }

  Future<void> _openReviewsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TalentReadyToReviewSheet(
        readyToReviewUsers: _readyToReviewUsers,
        onReviewTap: _submitUserReview,
      ),
    );
  }

  Future<void> _submitUserReview(_ReadyToReviewUser user) async {
    final result = await showReviewComposerSheet(
      context: context,
      title: 'Review User',
      subtitle:
          'Add your rating, write your review, and attach a photo if needed.',
      targetName: user.name,
      targetAvatar: user.avatarUrl,
      sessionLabel: user.sessionLabel,
      confirmLabel: 'Confirm User Review',
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _readyToReviewUsers = _readyToReviewUsers
          .where((item) => item != user)
          .toList(growable: false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Review for ${user.name} submitted with ${result.rating} stars.',
        ),
      ),
    );
  }

  Future<void> _openReceivedReviewsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TalentReviewsSheet(),
    );
  }

  Future<void> _openScheduleAvailabilitySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          const _TalentMeetScheduleSheet(hostName: _currentTalentHostName),
    );
  }

  Future<void> _openPaymentHistorySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TalentPaymentHistorySheet(
        items: _paymentHistoryItems,
        totalEarnedCoins: _totalEarnedCoins,
      ),
    );
  }

  Future<void> _openWithdrawSheet() async {
    final result = await showModalBottomSheet<_WithdrawRequestResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TalentWithdrawSheet(
        availableCoins: coinBalance,
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      coinBalance -= result.coinAmount;
      _paymentHistoryItems = [
        _PaymentHistoryItem(
          title: 'Withdraw to ${result.methodName}',
          signedCoins: -result.coinAmount,
          status: 'Pending',
          dateLabel: formatDemoDate(DateTime.now()),
          accent: const Color(0xFFD97706),
          detailLabel: '${result.accountName} • ${result.accountNumber}',
          cashLabel: result.cashAmountLabel,
        ),
        ..._paymentHistoryItems,
      ];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Withdraw ${_formatCoins(result.coinAmount)} coins ke ${result.methodName} sedang diproses.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      bottomNavigationBar: const TalentBottomNav(
        currentRoute: '/talent-profile',
      ),
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
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
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
                                  backgroundImage: profilePhoto.provider,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: _pickProfilePhoto,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: isOnline
                                          ? Colors.green
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
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
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Jessica Martinez',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.amber,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    'jessica.martinez@email.com',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$rating',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '•',
                                        style: TextStyle(color: Colors.black26),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$reviews reviews',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats Grid
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Stats',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statCard(
                            Icons.account_balance_wallet,
                            'Total Earnings',
                            '🪙 45,230',
                          ),
                          const SizedBox(width: 12),
                          _statCard(Icons.access_time, 'Total Hours', '582h'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _statCard(Icons.chat, 'Total Chats', '1,234'),
                          const SizedBox(width: 12),
                          _statCard(
                            Icons.remove_red_eye,
                            'Profile Views',
                            '12.5k',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Portfolio
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
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
                                Text(
                                  'My Portfolio',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _pickPortfolioPhoto,
                              child: const Text(
                                '+ Add Photos',
                                style: TextStyle(color: Colors.amber),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: portfolioPhotos.length,
                            separatorBuilder: (context, idx) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final photo = portfolioPhotos[idx];
                              return InkWell(
                                onTap: () => _openPortfolioPreview(idx),
                                borderRadius: BorderRadius.circular(12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: photo.buildImage(fit: BoxFit.cover),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${portfolioPhotos.length} photos • Users can view your portfolio on your profile',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Coin Balance
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '🪙 $coinBalance Coins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: coinBalance <= 0
                                  ? null
                                  : _openWithdrawSheet,
                              child: const Text('Withdraw Earnings'),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      children: [
                        _menuTile(
                          Icons.rate_review_rounded,
                          'Ready to Review Users',
                          _readyToReviewUsers.isEmpty
                              ? 'No users are waiting for a review right now'
                              : '${_readyToReviewUsers.length} user${_readyToReviewUsers.length == 1 ? '' : 's'} waiting for your review',
                          badgeCount: _readyToReviewUsers.length,
                          onTap: _openReviewsSheet,
                        ),
                        _menuTile(
                          Icons.reviews_rounded,
                          'Reviews',
                          'See reviews written by users about you',
                          onTap: _openReceivedReviewsSheet,
                        ),
                        _menuTile(
                          Icons.access_time,
                          'Schedule & Availability',
                          'See meet schedules and availability',
                          onTap: _openScheduleAvailabilitySheet,
                        ),
                        _menuTile(
                          Icons.account_balance_wallet,
                          'Payment History',
                          'View earned coins and withdrawal status',
                          onTap: _openPaymentHistorySheet,
                        ),
                        _menuTile(
                          Icons.settings,
                          'Settings',
                          'Privacy & preferences',
                          onTap: () {
                            Navigator.pushNamed(context, '/talent-settings');
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Logout
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
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
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    IconData icon,
    String title,
    String subtitle, {
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeCount > 0)
            Container(
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _ReadyToReviewUser {
  const _ReadyToReviewUser({
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

class _TalentPhoto {
  const _TalentPhoto.network(this.value) : isLocal = false;

  const _TalentPhoto.file(this.value) : isLocal = true;

  final String value;
  final bool isLocal;

  ImageProvider get provider {
    if (isLocal) {
      return FileImage(File(value));
    }
    return NetworkImage(value);
  }

  Widget buildImage({BoxFit fit = BoxFit.cover}) {
    if (isLocal) {
      return Image.file(File(value), fit: fit);
    }
    return Image.network(value, fit: fit);
  }
}

class _TalentProfileSheetFrame extends StatelessWidget {
  const _TalentProfileSheetFrame({
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
              Row(
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
              const SizedBox(height: 18),
              child,
            ],
          ),
        );
      },
    );
  }
}

class _TalentReadyToReviewSheet extends StatelessWidget {
  const _TalentReadyToReviewSheet({
    required this.readyToReviewUsers,
    required this.onReviewTap,
  });

  final List<_ReadyToReviewUser> readyToReviewUsers;
  final Future<void> Function(_ReadyToReviewUser user) onReviewTap;

  @override
  Widget build(BuildContext context) {
    return _TalentProfileSheetFrame(
      title: 'Ready to Review Users',
      subtitle: 'Give a review after each completed session',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F3),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF4C5CB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE34B57).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notification_important_rounded,
                        color: Color(0xFFE34B57),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ready to review',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            readyToReviewUsers.isEmpty
                                ? 'No completed sessions are waiting for your rating.'
                                : '${readyToReviewUsers.length} completed session${readyToReviewUsers.length == 1 ? '' : 's'} need your review.',
                            style: const TextStyle(color: Color(0xFF8B6F70)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (readyToReviewUsers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...readyToReviewUsers.map(
                    (user) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(user.avatarUrl),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.sessionLabel,
                                    style: const TextStyle(
                                      color: Color(0xFF7E746E),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.dateLabel,
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
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2B211C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  onReviewTap(user);
                                });
                              },
                              child: const Text('Review'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TalentReviewsSheet extends StatelessWidget {
  const _TalentReviewsSheet();

  static const List<_TalentReviewItem> _reviews = [
    _TalentReviewItem(
      name: 'Sarah Johnson',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      rating: 5,
      comment:
          'Amazing conversation. Jessica is kind, attentive, and always makes the chat feel natural.',
      dateLabel: '2 days ago',
      chatDuration: '45 min',
      coinsEarned: 120,
    ),
    _TalentReviewItem(
      name: 'Mike Chen',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      rating: 5,
      comment:
          'Great listener and very friendly. I would definitely chat again.',
      dateLabel: '3 days ago',
      chatDuration: '30 min',
      coinsEarned: 80,
    ),
    _TalentReviewItem(
      name: 'Emma Wilson',
      avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      rating: 4,
      comment:
          'Pleasant and genuine conversation. The session felt very comfortable.',
      dateLabel: '5 days ago',
      chatDuration: '25 min',
      coinsEarned: 65,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final average =
        (_reviews.fold<int>(0, (sum, item) => sum + item.rating) /
                _reviews.length)
            .toStringAsFixed(1);

    return _TalentProfileSheetFrame(
      title: 'Reviews',
      subtitle: 'Reviews written by users about your sessions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      average,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Color(0xFFF1B62D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_reviews.length} total reviews',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._reviews.map(
            (review) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(review.avatarUrl),
                        radius: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              review.dateLabel,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '🪙 ${review.coinsEarned}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: index < review.rating
                            ? const Color(0xFFF1B62D)
                            : const Color(0xFFE1D8CF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.comment,
                    style: const TextStyle(color: Colors.black87, height: 1.45),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chat duration: ${review.chatDuration}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TalentMeetScheduleSheet extends StatelessWidget {
  const _TalentMeetScheduleSheet({required this.hostName});

  final String hostName;

  @override
  Widget build(BuildContext context) {
    return _TalentProfileSheetFrame(
      title: 'Schedule & Availability',
      subtitle: 'Meet schedules and holiday dates for offline sessions',
      child: ValueListenableBuilder<List<DemoMeetRequest>>(
        valueListenable: demoScheduleStore,
        builder: (context, _, __) {
          final meetRequests = demoScheduleStore.requestsForHost(hostName);
          final holidayDates = demoScheduleStore.holidayDatesForHost(hostName);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meet Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (meetRequests.isEmpty)
                _profileEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No meet schedules yet',
                  subtitle:
                      'Offline meet requests accepted by users will appear here.',
                )
              else
                ...meetRequests.map(
                  (request) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(request.userAvatar),
                              radius: 22,
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
                                    ),
                                  ),
                                  Text(
                                    request.dateLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _meetStatusBadge(request.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${request.startTimeLabel} - ${request.endTimeLabel} • ${request.durationLabel}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          request.meetingAddress,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Landmark: ${request.landmark}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const Text(
                'Unavailable Dates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (holidayDates.isEmpty)
                _profileEmptyState(
                  icon: Icons.calendar_today_rounded,
                  title: 'No closed dates yet',
                  subtitle:
                      'Dates closed from availability settings will be listed here.',
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: holidayDates
                      .map(
                        (date) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8EB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            formatDemoDate(date),
                            style: const TextStyle(
                              color: Color(0xFFE34A57),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TalentPaymentHistorySheet extends StatelessWidget {
  const _TalentPaymentHistorySheet({
    required this.items,
    required this.totalEarnedCoins,
  });

  static const List<_PaymentHistoryItem> seedItems = [
    _PaymentHistoryItem(
      title: 'Voice Call Earnings',
      signedCoins: 320,
      status: 'Completed',
      dateLabel: 'Apr 17, 2026',
      accent: Color(0xFF2BAE66),
    ),
    _PaymentHistoryItem(
      title: 'Offline Meet Earnings',
      signedCoins: 500,
      status: 'Completed',
      dateLabel: 'Apr 15, 2026',
      accent: Color(0xFF2BAE66),
    ),
    _PaymentHistoryItem(
      title: 'Withdraw to Bank',
      signedCoins: -1000,
      status: 'Pending',
      dateLabel: 'Apr 13, 2026',
      accent: Color(0xFFD97706),
      cashLabel: 'Rp 100.000',
      detailLabel: 'BCA • 0147 8892 10',
    ),
    _PaymentHistoryItem(
      title: 'Video Call Earnings',
      signedCoins: 260,
      status: 'Completed',
      dateLabel: 'Apr 11, 2026',
      accent: Color(0xFF2BAE66),
    ),
    _PaymentHistoryItem(
      title: 'Withdraw to Bank',
      signedCoins: -2000,
      status: 'Rejected',
      dateLabel: 'Apr 08, 2026',
      accent: Color(0xFFD54343),
      cashLabel: 'Rp 200.000',
      detailLabel: 'Mandiri • 1340 1122 08',
    ),
  ];

  final List<_PaymentHistoryItem> items;
  final int totalEarnedCoins;

  @override
  Widget build(BuildContext context) {
    final pendingWithdrawCoins = items
        .where((item) => item.signedCoins < 0 && item.status == 'Pending')
        .fold<int>(0, (sum, item) => sum + item.signedCoins.abs());

    return _TalentProfileSheetFrame(
      title: 'Payment History',
      subtitle: 'Track earned coins and withdrawal status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _HistorySummaryCard(
                  title: 'Earned Coins',
                  value: '🪙 ${_formatCoins(totalEarnedCoins)}',
                  accent: const Color(0xFF2BAE66),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HistorySummaryCard(
                  title: 'Pending Withdraw',
                  value: '🪙 ${_formatCoins(pendingWithdrawCoins)}',
                  accent: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.signedCoins > 0
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: item.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (item.detailLabel != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            item.detailLabel!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        const SizedBox(height: 3),
                        Text(
                          item.dateLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.coinLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: item.accent,
                        ),
                      ),
                      if (item.cashLabel != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.cashLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        item.status,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TalentWithdrawSheet extends StatefulWidget {
  const _TalentWithdrawSheet({required this.availableCoins});

  final int availableCoins;

  @override
  State<_TalentWithdrawSheet> createState() => _TalentWithdrawSheetState();
}

class _TalentWithdrawSheetState extends State<_TalentWithdrawSheet> {
  static const List<int> _withdrawOptions = [500, 1000, 2000, 4000];
  static const List<_WithdrawMethod> _methods = [
    _WithdrawMethod(
      id: 'bank_bca',
      name: 'Bank BCA',
      description: 'Transfer ke rekening bank utama',
      icon: Icons.account_balance_rounded,
    ),
    _WithdrawMethod(
      id: 'bank_mandiri',
      name: 'Bank Mandiri',
      description: 'Pencairan ke rekening Mandiri',
      icon: Icons.account_balance_wallet_rounded,
    ),
    _WithdrawMethod(
      id: 'dana',
      name: 'DANA',
      description: 'E-wallet payout instan',
      icon: Icons.wallet_rounded,
    ),
  ];

  late int _selectedCoins;
  late _WithdrawMethod _selectedMethod;
  final TextEditingController _accountNameController =
      TextEditingController(text: 'Jessica Martinez');
  final TextEditingController _accountNumberController =
      TextEditingController(text: '0812 8899 2211');

  @override
  void initState() {
    super.initState();
    _selectedCoins = _withdrawOptions.firstWhere(
      (amount) => amount <= widget.availableCoins,
      orElse: () => widget.availableCoins,
    );
    _selectedMethod = _methods.first;
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cashAmount = _coinsToRupiah(_selectedCoins);

    return _TalentProfileSheetFrame(
      title: 'Withdraw Earnings',
      subtitle: 'Convert your coins into cash and send them to your payout account.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAF8EF), Color(0xFFDFF7E8)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available balance',
                  style: TextStyle(color: Color(0xFF5C7B66)),
                ),
                const SizedBox(height: 8),
                Text(
                  '🪙 ${_formatCoins(widget.availableCoins)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F7A45),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estimated payout: ${_formatRupiah(cashAmount)}',
                  style: const TextStyle(
                    color: Color(0xFF35684A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Conversion rate: 1 coin = Rp 100',
                  style: TextStyle(color: Color(0xFF5C7B66), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Choose amount',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _withdrawOptions
                .where((amount) => amount <= widget.availableCoins)
                .map(
                  (amount) => _amountChip(
                    amount: amount,
                    selected: _selectedCoins == amount,
                  ),
                )
                .toList(),
          ),
          if (widget.availableCoins < _withdrawOptions.first) ...[
            const SizedBox(height: 10),
            const Text(
              'Minimum withdraw is 500 coins.',
              style: TextStyle(color: Color(0xFFD54343), fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'Withdraw to',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ..._methods.map((method) {
            final selected = _selectedMethod.id == method.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedMethod = method),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFFFF6EA) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFB45309)
                          : const Color(0xFFE8E1D8),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(method.icon, color: const Color(0xFFB45309)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              method.description,
                              style: const TextStyle(
                                color: Color(0xFF7D746D),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected
                            ? const Color(0xFFB45309)
                            : const Color(0xFFCFC5BC),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          TextField(
            controller: _accountNameController,
            decoration: InputDecoration(
              labelText: 'Account holder',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Account number / wallet number',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You will receive',
                        style: TextStyle(color: Color(0xFF7D746D)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatRupiah(cashAmount),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '🪙 ${_formatCoins(_selectedCoins)}',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.availableCoins < 500 ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB45309),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Confirm Withdraw'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountChip({required int amount, required bool selected}) {
    return InkWell(
      onTap: () => setState(() => _selectedCoins = amount),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFB45309) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFB45309) : const Color(0xFFE8E1D8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🪙 ${_formatCoins(amount)}',
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF2C2420),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatRupiah(_coinsToRupiah(amount)),
              style: TextStyle(
                color: selected ? Colors.white70 : const Color(0xFF7D746D),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final accountName = _accountNameController.text.trim();
    final accountNumber = _accountNumberController.text.trim();

    if (accountName.isEmpty || accountNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi nama pemilik dan nomor akun tujuan.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _WithdrawRequestResult(
        coinAmount: _selectedCoins,
        methodName: _selectedMethod.name,
        accountName: accountName,
        accountNumber: accountNumber,
        cashAmountLabel: _formatRupiah(_coinsToRupiah(_selectedCoins)),
      ),
    );
  }
}

Widget _profileEmptyState({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
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

Widget _meetStatusBadge(DemoMeetRequestStatus status) {
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

class _TalentReviewItem {
  const _TalentReviewItem({
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.dateLabel,
    required this.chatDuration,
    required this.coinsEarned,
  });

  final String name;
  final String avatarUrl;
  final int rating;
  final String comment;
  final String dateLabel;
  final String chatDuration;
  final int coinsEarned;
}

class _PaymentHistoryItem {
  const _PaymentHistoryItem({
    required this.title,
    required this.signedCoins,
    required this.status,
    required this.dateLabel,
    required this.accent,
    this.detailLabel,
    this.cashLabel,
  });

  final String title;
  final int signedCoins;
  final String status;
  final String dateLabel;
  final Color accent;
  final String? detailLabel;
  final String? cashLabel;

  String get coinLabel {
    final prefix = signedCoins >= 0 ? '+' : '-';
    return '$prefix🪙 ${_formatCoins(signedCoins.abs())}';
  }
}

class _WithdrawMethod {
  const _WithdrawMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
}

class _WithdrawRequestResult {
  const _WithdrawRequestResult({
    required this.coinAmount,
    required this.methodName,
    required this.accountName,
    required this.accountNumber,
    required this.cashAmountLabel,
  });

  final int coinAmount;
  final String methodName;
  final String accountName;
  final String accountNumber;
  final String cashAmountLabel;
}

class _HistorySummaryCard extends StatelessWidget {
  const _HistorySummaryCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

int _coinsToRupiah(int coins) => coins * 100;

String _formatCoins(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final reverseIndex = digits.length - index;
    buffer.write(digits[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

String _formatRupiah(int value) {
  return 'Rp ${_formatCoins(value)}';
}
