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

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/services/user_wallet_service.dart';
import '../../shared/demo_schedule_store.dart';
import '../shared/loading_splash.dart';
import '../shared/review_composer_sheet.dart';
import 'user_ui_shared.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

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
  final ImagePicker _imagePicker = ImagePicker();
  UserProfileData? _profile;
  bool _isLoadingProfile = false;
  int _availableCoinBalance = 0;

  @override
  void initState() {
    super.initState();
    _readyToReviewTalents = List<_ReadyToReviewTalent>.from(
      _seedReadyToReviewTalents,
    );
    final cachedBalance = UserWalletService.peekCachedAvailableCoinBalance();
    if (cachedBalance != null) {
      _availableCoinBalance = cachedBalance;
    }
    _loadProfile();
    _loadWalletBalance();
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    if (_profile == null) {
      setState(() {
        _isLoadingProfile = true;
      });
    }

    try {
      final profile = await UserProfileService.getMyProfile(
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadWalletBalance({bool forceRefresh = false}) async {
    try {
      final balance = await UserWalletService.getAvailableCoinBalance(
        forceRefresh: forceRefresh,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _availableCoinBalance = balance;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
    }
  }

  Future<void> _editProfilePhoto() async {
    final overlayController = AppLoadingOverlay.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final showCameraOption = _supportsCameraOption();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCameraOption)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF1E3),
                      child: Icon(Icons.photo_camera_rounded),
                    ),
                    title: const Text('Open Camera'),
                    subtitle: const Text('Take a new profile photo'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  )
                else
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFF2ECE4),
                      child: Icon(
                        Icons.photo_camera_rounded,
                        color: Color(0xFF9A8F82),
                      ),
                    ),
                    title: Text('Open Camera'),
                    subtitle: Text(
                      'Sementara hanya tersedia di Android atau perangkat fisik yang sudah diverifikasi.',
                    ),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF1E3),
                    child: Icon(Icons.photo_library_rounded),
                  ),
                  title: const Text('Get from Device'),
                  subtitle: const Text('Choose a photo from your device'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    XFile? pickedFile;
    try {
      pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 88,
      );
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Akses kamera atau galeri tidak tersedia.',
          ),
        ),
      );
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka kamera atau galeri di perangkat ini.'),
        ),
      );
      return;
    }

    if (pickedFile == null || !mounted) {
      return;
    }

    final selectedFile = pickedFile;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Photo Upload'),
          content: const Text('Gunakan foto ini sebagai foto profil Anda?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final updatedProfile = await overlayController.run(
        () => UserProfileService.uploadAvatar(selectedFile.path),
        message: 'Mengunggah foto profil...',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = updatedProfile;
      });

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Gagal mengunggah foto profil. Coba lagi.'),
        ),
      );
    }
  }

  bool _supportsCameraOption() {
    if (kIsWeb) {
      return false;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }

    return false;
  }

  Future<void> _openProfilePhotoPreview({required String displayName}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _ProfilePhotoFullscreenImage(
                        imageUrl: _profile?.avatarUrl,
                        displayName: displayName,
                        isLoading: _isLoadingProfile,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 28,
                  left: 24,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await _editProfilePhoto();
                    },
                    icon: const Icon(Icons.photo_camera_back_rounded),
                    label: const Text('Change Photo'),
                    style: FilledButton.styleFrom(
                      backgroundColor: userAmberDark,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
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

  Future<void> _handleLogout() async {
    await AuthService.logoutCurrentSession();
    if (!mounted) {
      return;
    }
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
    final profile = _profile;
    final displayName = profile?.displayName ?? 'Alex Johnson';
    final locationLabel = profile?.locationLabel.isNotEmpty == true
        ? profile!.locationLabel
        : 'Profile data loading...';
    final countryCode = _countryCode(profile?.country ?? 'US');

    return Scaffold(
      backgroundColor: userCreamBackground,
      bottomNavigationBar: widget.showBottomNav
          ? const UserBottomNav(currentRoute: '/user-profile')
          : null,
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
                                    InkWell(
                                      onTap: () => _openProfilePhotoPreview(
                                        displayName: displayName,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      child: _UserProfileAvatar(
                                        radius: 40,
                                        imageUrl: profile?.avatarUrl,
                                        isLoading: _isLoadingProfile,
                                        initials: displayName,
                                      ),
                                    ),
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: UserFlagBadge(
                                        countryCode: countryCode,
                                        size: 28,
                                        borderWidth: 2,
                                        innerPadding: 3,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: InkWell(
                                        onTap: _editProfilePhoto,
                                        borderRadius: BorderRadius.circular(20),
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
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        locationLabel,
                                        style: const TextStyle(
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Coin Balance',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF7B746E),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '🪙 ${_formatCoinBalance(_availableCoinBalance)}',
                                          style: const TextStyle(
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
                        builder: (context, value, child) {
                          final userSchedules =
                              demoScheduleStore.requestsForUser(
                                demoCurrentUserName,
                              )..sort(
                                (left, right) =>
                                    right.date.compareTo(left.date),
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
                                      style: TextStyle(
                                        color: Color(0xFF6A625B),
                                      ),
                                    ),
                                  )
                                else
                                  ...userSchedules
                                      .take(3)
                                      .map(
                                        (request) => Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFBF7),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
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
                                                        fontWeight:
                                                            FontWeight.w700,
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

  String _countryCode(String country) {
    final normalized = country.trim().toLowerCase();
    const overrides = {
      'indonesia': 'ID',
      'united states': 'US',
      'philippines': 'PH',
      'thailand': 'TH',
      'vietnam': 'VN',
      'japan': 'JP',
    };

    final override = overrides[normalized];
    if (override != null) {
      return override;
    }

    final letters = normalized.replaceAll(RegExp(r'[^a-z]'), '');
    if (letters.length >= 2) {
      return letters.substring(0, 2).toUpperCase();
    }

    return 'US';
  }

  String _formatCoinBalance(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index += 1) {
      final remaining = digits.length - index;
      buffer.write(digits[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    final formatted = buffer.toString();
    return value < 0 ? '-$formatted' : formatted;
  }
}

class _UserProfileAvatar extends StatelessWidget {
  const _UserProfileAvatar({
    required this.radius,
    required this.imageUrl,
    required this.isLoading,
    required this.initials,
  });

  final double radius;
  final String? imageUrl;
  final bool isLoading;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl?.trim() ?? '';
    if (trimmedUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(trimmedUrl),
      );
    }

    final label = initials.trim().isEmpty
        ? 'U'
        : initials.trim().substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFFFECDD),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B5A3C),
              ),
            ),
    );
  }
}

class _ProfilePhotoFullscreenImage extends StatelessWidget {
  const _ProfilePhotoFullscreenImage({
    required this.imageUrl,
    required this.displayName,
    required this.isLoading,
  });

  final String? imageUrl;
  final String displayName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl?.trim() ?? '';
    if (trimmedUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.network(
          trimmedUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _FullscreenAvatarFallback(
              displayName: displayName,
              isLoading: isLoading,
            );
          },
        ),
      );
    }

    return _FullscreenAvatarFallback(
      displayName: displayName,
      isLoading: isLoading,
    );
  }
}

class _FullscreenAvatarFallback extends StatelessWidget {
  const _FullscreenAvatarFallback({
    required this.displayName,
    required this.isLoading,
  });

  final String displayName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFFFECDD),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                displayName.trim().isEmpty
                    ? 'U'
                    : displayName.trim().substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 88,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B5A3C),
                ),
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
                          'Ready To Review',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF241B15),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Share feedback for your finished sessions.',
                          style: TextStyle(
                            color: Color(0xFF817A74),
                            fontSize: 13,
                          ),
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
                                  fontSize: 13,
                                  color: Color(0xFF7F756D),
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
