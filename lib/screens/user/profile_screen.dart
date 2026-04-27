// Flutter translation of cocoa/src/app/pages/Profile.tsx
//
// Semua aksi (chat, voice, video, favorite, meet offline, payment) harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET /profile/:id
// - POST /favorite
// - POST /payment
//
// Komponen reusable (PhotoGallery, MeetOfflineModal, dsb) dibuat di folder components terpisah.
//
// Untuk pengembangan backend, pastikan response sesuai kebutuhan UI.

import 'package:flutter/material.dart';

import '../../core/services/talent_public_profile_service.dart';
import '../../core/services/user_wallet_service.dart';
import '../../shared/demo_schedule_store.dart';
import 'chat_screen.dart';
import 'user_ui_shared.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DemoUserHost? _host;
  String? _talentAccountId;
  bool _didReadRouteArguments = false;
  bool _isLoadingTalentProfile = false;
  int _currentBalance = 0;
  bool isFavorite = false;
  bool idVerified = false;
  bool selfieVerified = false;

  DemoUserHost get host => _host ?? demoUserHosts.first;

  bool get _isMeetLocked {
    final normalizedTier = host.tierLabel.trim().toLowerCase();
    return normalizedTier == 'bronze' || normalizedTier == 'basic';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadRouteArguments) {
      return;
    }
    _didReadRouteArguments = true;

    final routeHost = ModalRoute.of(context)?.settings.arguments;
    if (routeHost is DemoUserHost) {
      _host = routeHost;
      final accountId = routeHost.accountId.trim();
      if (accountId.isNotEmpty) {
        _talentAccountId = accountId;
        _loadTalentProfile();
      }
    }

    final cachedBalance = UserWalletService.peekCachedAvailableCoinBalance();
    if (cachedBalance != null) {
      _currentBalance = cachedBalance;
    }
    _loadWalletBalance(forceRefresh: cachedBalance != null);
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
        _currentBalance = balance;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
    }
  }

  Future<void> _loadTalentProfile({bool forceRefresh = false}) async {
    final accountId = _talentAccountId;
    if (accountId == null || accountId.isEmpty || _isLoadingTalentProfile) {
      return;
    }

    setState(() => _isLoadingTalentProfile = true);
    try {
      final profile = await TalentPublicProfileService.getTalentProfile(
        accountId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _host = _mapProfileToHost(profile, fallbackHost: _host);
        _isLoadingTalentProfile = false;
      });
    } on TalentPublicProfileException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoadingTalentProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoadingTalentProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil talent: $error')),
      );
    }
  }

  DemoUserHost _mapProfileToHost(
    TalentPublicProfileData profile, {
    DemoUserHost? fallbackHost,
  }) {
    final description = profile.bio.trim().isNotEmpty
        ? profile.bio.trim()
        : fallbackHost?.description ?? 'Ready to connect';
    final tierLabel = _tierLabel(profile.level);
    final badges = _buildBadges(
      tierLabel: tierLabel,
      verificationStatus: profile.verificationStatus,
      specialties: profile.specialties,
      languages: profile.languages,
    );
    final portfolio = profile.portfolioUrls.isNotEmpty
        ? profile.portfolioUrls
        : fallbackHost?.portfolio ?? const [];
    final location = [profile.city, profile.country]
        .where((item) => item.trim().isNotEmpty)
        .join(', ');
    final servicePrices = profile.servicePrices.isNotEmpty
        ? profile.servicePrices
        : fallbackHost?.servicePrices ?? const {};

    return DemoUserHost(
      id: profile.accountId.hashCode,
      accountId: profile.accountId,
      name: profile.stageName.trim().isNotEmpty
        ? profile.stageName.trim()
        : profile.displayName,
      age: profile.age,
      city: profile.city,
      countryCode: _countryCode(profile.country),
      description: profile.specialties.isNotEmpty
        ? profile.specialties.take(2).join(' • ')
        : description,
      imageUrl: profile.avatarUrl.isNotEmpty
          ? profile.avatarUrl
          : (fallbackHost?.imageUrl ?? ''),
      pricePerMin: _priceForService('chat', servicePrices, tierLabel),
      tierLabel: tierLabel,
      rating: profile.rating,
      reviewCount: profile.reviewCount,
      badges: badges,
      portfolio: portfolio,
      isOnline: profile.isOnline,
      location: location.isNotEmpty
          ? location
          : (fallbackHost?.location ?? 'Unknown location'),
      biography: profile.bio.trim().isNotEmpty
          ? profile.bio.trim()
          : (fallbackHost?.biography ?? description),
      languages: profile.languages,
      specialties: profile.specialties,
      servicePrices: servicePrices,
    );
  }

  List<String> _buildBadges({
    required String tierLabel,
    required String verificationStatus,
    required List<String> specialties,
    required List<String> languages,
  }) {
    final badges = <String>[];
    if (tierLabel.trim().isNotEmpty) {
      badges.add(tierLabel);
    }
    if (verificationStatus.trim().isNotEmpty) {
      badges.add(_capitalize(verificationStatus));
    }
    return badges.toSet().toList(growable: false);
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _tierLabel(String level) {
    final normalized = level.trim();
    if (normalized.isEmpty) {
      return 'Basic';
    }
    return _capitalize(normalized);
  }

  String _countryCode(String country) {
    const overrides = {
      'indonesia': 'ID',
      'philippines': 'PH',
      'thailand': 'TH',
      'vietnam': 'VN',
      'japan': 'JP',
      'united states': 'US',
    };
    final normalized = country.trim().toLowerCase();
    final override = overrides[normalized];
    if (override != null) {
      return override;
    }

    final letters = normalized.replaceAll(RegExp(r'[^a-z]'), '');
    if (letters.length >= 2) {
      return letters.substring(0, 2).toUpperCase();
    }
    return 'ID';
  }

  int _priceForService(
    String serviceType,
    Map<String, int> prices,
    String tierLabel,
  ) {
    final normalized = serviceType.trim().toLowerCase();
    final exact = prices[normalized];
    if (exact != null && exact > 0) {
      return exact;
    }

    switch (normalized) {
      case 'chat':
        switch (tierLabel.toLowerCase()) {
          case 'bronze':
          case 'basic':
            return 20;
          case 'silver':
            return 25;
          case 'gold':
            return 30;
          case 'platinum':
            return 35;
          case 'diamond':
            return 40;
          default:
            return 20;
        }
      case 'voice':
        return (_priceForService('chat', prices, tierLabel) * 1.5).round();
      case 'video':
        return _priceForService('chat', prices, tierLabel) * 2;
      case 'meet':
        return (_priceForService('chat', prices, tierLabel) * 3).round();
      default:
        return 0;
    }
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

  Future<void> _openPhotoGallery(int initialIndex) async {
    final pageController = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Photo gallery',
      barrierColor: Colors.black.withValues(alpha: 0.94),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: host.portfolio.length,
                      onPageChanged: (index) =>
                          setModalState(() => currentIndex = index),
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Center(
                            child: Image.network(
                              host.portfolio[index],
                              fit: BoxFit.contain,
                            ),
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
                            '${currentIndex + 1} / ${host.portfolio.length}',
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

    pageController.dispose();
  }

  Future<void> _showPaymentSheet(String type) async {
    final servicePrice = _priceForService(
      type,
      host.servicePrices,
      host.tierLabel,
    );
    final title = type == 'chat'
        ? 'Start Chat'
        : type == 'voice'
        ? 'Start Voice Call'
        : type == 'video'
        ? 'Start Video Call'
        : 'Start Meet';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                type == 'chat'
                    ? 'You will be charged based on the talent chat tier pricing'
                    : type == 'voice'
                    ? 'You will be charged based on the talent voice tier pricing'
                    : type == 'video'
                    ? 'You will be charged based on the talent video tier pricing'
                    : 'You will be charged based on the talent meet tier pricing',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF817A74)),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF6EA), Color(0xFFFFEBD9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(color: Color(0xFF817A74)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🪙 ${_formatCoinBalance(_currentBalance)}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rate: 🪙 $servicePrice',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: userAmberDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (type == 'chat') {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => ChatScreen(host: host),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$title started with ${host.name} (${type.toLowerCase()})',
                          ),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: userAmberDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleMeet() async {
    if (_isMeetLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fitur meet ditutup untuk talent Bronze. Talent harus naik ke tier Silver agar fitur meet bisa diakses.',
          ),
        ),
      );
      return;
    }

    final request = await showModalBottomSheet<DemoMeetRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MeetOfflineSheet(
        hostName: host.name,
        hostLocation: host.location,
        verificationBypassed: !idVerified || !selfieVerified,
      ),
    );

    if (request == null || !mounted) {
      return;
    }

    demoScheduleStore.addRequest(request);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Schedule Request Sent'),
        content: const Text(
          'Your schedule request has been sent to the talent. Please wait for their response to see whether they accept or decline it.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: userAmberDark),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(host.imageUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                    const Color(0xFF171717),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _glassButton(
                        Icons.chevron_left_rounded,
                        () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          _glassButton(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            () => setState(() => isFavorite = !isFavorite),
                            active: isFavorite,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: host.isOnline
                                  ? const Color(0xFF2FA655)
                                  : const Color(0xFF8C857E),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.circle,
                                size: 14,
                                color: host.isOnline
                                    ? Colors.white
                                    : const Color(0xFFE7E0D7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 160),
                        if (_isLoadingTalentProfile)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: LinearProgressIndicator(minHeight: 3),
                          ),
                        Text(
                          host.age > 0 ? '${host.name}, ${host.age}' : host.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          host.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (host.languages.isNotEmpty) ...[
                          const Text(
                            'Languages',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: host.languages
                                .map(
                                  (language) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.14),
                                      ),
                                    ),
                                    child: Text(
                                      language,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: host.badges
                              .map(
                                (badge) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    badge,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        if (host.biography.trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Biography',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  host.biography,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => _showPaymentSheet('chat'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFCA6C34),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              'Chat Now • 🪙 ${_priceForService('chat', host.servicePrices, host.tierLabel)} / hour',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.photo_library_outlined,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Photos',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${host.portfolio.length} photos',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: host.portfolio.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                    ),
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () => _openPhotoGallery(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          host.portfolio[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (index == 0)
                                        Positioned(
                                          right: 6,
                                          bottom: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.42,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: const Icon(
                                              Icons.zoom_in_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Flexible(
                              child: AspectRatio(
                                aspectRatio: 0.78,
                                child: _actionCard(
                                  Icons.call_rounded,
                                  'Voice',
                                  '🪙 ${_priceForService('voice', host.servicePrices, host.tierLabel)} / hour',
                                  const Color(0xFF31B56A),
                                  () => _showPaymentSheet('voice'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: AspectRatio(
                                aspectRatio: 0.78,
                                child: _actionCard(
                                  Icons.videocam_rounded,
                                  'Video',
                                  '🪙 ${_priceForService('video', host.servicePrices, host.tierLabel)} / hour',
                                  const Color(0xFF7A5AF8),
                                  () => _showPaymentSheet('video'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: AspectRatio(
                                aspectRatio: 0.78,
                                child: _actionCard(
                                  Icons.location_on_rounded,
                                  'Meet',
                                  _isMeetLocked
                                      ? 'Silver tier only'
                                      : '🪙 ${_priceForService('meet', host.servicePrices, host.tierLabel)} / hour',
                                  const Color(0xFFCA6C34),
                                  _handleMeet,
                                  showWarning:
                                      _isMeetLocked ||
                                      !idVerified ||
                                      !selfieVerified,
                                  disabled: _isMeetLocked,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Reviews',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ...List.generate(
                                    5,
                                    (index) => const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Color(0xFFF1B62D),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${host.rating} (${host.reviewCount} Reviews)',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Aditya',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Clara is really sweet and easy to talk to. Always makes me smile!',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '♥ 125 Reviews',
                                style: TextStyle(
                                  color: Color(0xFFF1B62D),
                                  fontWeight: FontWeight.w600,
                                ),
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
        ],
      ),
    );
  }

  Widget _glassButton(
    IconData icon,
    VoidCallback onTap, {
    bool active = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFFE95A69) : Colors.white,
        ),
      ),
    );
  }

  Widget _actionCard(
    IconData icon,
    String label,
    String subtitle,
    Color accentColor,
    VoidCallback onTap, {
    bool showWarning = false,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Opacity(
            opacity: disabled ? 0.45 : 1,
            child: SizedBox(
              height: 184,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.30),
                      Colors.white.withValues(alpha: 0.10),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showWarning)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFE34A57),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MeetOfflineSheet extends StatefulWidget {
  const _MeetOfflineSheet({
    required this.hostName,
    required this.hostLocation,
    required this.verificationBypassed,
  });

  final String hostName;
  final String hostLocation;
  final bool verificationBypassed;

  @override
  State<_MeetOfflineSheet> createState() => _MeetOfflineSheetState();
}

class _MeetOfflineSheetState extends State<_MeetOfflineSheet> {
  static const List<String> _eventTypes = ['Casual Event', 'Formal Event'];
  static const List<String> _weekdayLabels = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  final TextEditingController _meetingAddressController =
      TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  String _selectedEventType = _eventTypes.first;
  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  int? _selectedStartHour;
  int? _selectedDuration;

  @override
  void initState() {
    super.initState();
    final tomorrow = normalizeDemoDate(
      DateTime.now().add(const Duration(days: 1)),
    );
    _selectedDate =
        demoScheduleStore.firstAvailableDateForHost(
          hostName: widget.hostName,
          start: tomorrow,
        ) ??
        tomorrow;
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _meetingAddressController.text = widget.hostLocation;
  }

  @override
  void dispose() {
    _meetingAddressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  List<int> _availableStartHours() {
    if (demoScheduleStore.isDateLockedForHost(
      hostName: widget.hostName,
      date: _selectedDate,
    )) {
      return const [];
    }

    final hours = <int>[];
    final now = DateTime.now();
    for (var hour = 10; hour <= 17; hour++) {
      final candidate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
      );
      if (candidate.isAfter(now.add(const Duration(hours: 1)))) {
        hours.add(hour);
      }
    }
    return hours;
  }

  List<int> _availableDurations() {
    final startHour = _selectedStartHour;
    if (startHour == null) {
      return const [];
    }
    final maxDuration = startHour <= 13 ? 8 : 4;
    return [for (var hour = 3; hour <= maxDuration; hour++) hour];
  }

  DateTime get _firstBookableDate => normalizeDemoDate(DateTime.now());

  DateTime get _lastBookableDate =>
      normalizeDemoDate(DateTime.now().add(const Duration(days: 90)));

  bool _canGoToPreviousMonth() {
    final previousMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    return !previousMonth.isBefore(
      DateTime(_firstBookableDate.year, _firstBookableDate.month),
    );
  }

  bool _canGoToNextMonth() {
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    return !nextMonth.isAfter(
      DateTime(_lastBookableDate.year, _lastBookableDate.month),
    );
  }

  List<_CalendarDayCell> _calendarCells() {
    final firstDayOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );
    final leadingEmptyDays = firstDayOfMonth.weekday % 7;
    final cells = <_CalendarDayCell>[];

    for (var index = 0; index < 42; index++) {
      final dayOffset = index - leadingEmptyDays;
      final date = DateTime(
        _visibleMonth.year,
        _visibleMonth.month,
        1 + dayOffset,
      );
      final normalizedDate = normalizeDemoDate(date);
      final isCurrentMonth = date.month == _visibleMonth.month;
      final isOutOfRange =
          normalizedDate.isBefore(_firstBookableDate) ||
          normalizedDate.isAfter(_lastBookableDate);
      final isHoliday =
          isCurrentMonth &&
          demoScheduleStore.isTalentHoliday(
            hostName: widget.hostName,
            date: normalizedDate,
          );
      final isBooked =
          isCurrentMonth &&
          !isHoliday &&
          demoScheduleStore.hasActiveBookingOnDate(
            hostName: widget.hostName,
            date: normalizedDate,
          );
      final isSelectable =
          isCurrentMonth && !isOutOfRange && !isHoliday && !isBooked;

      cells.add(
        _CalendarDayCell(
          date: normalizedDate,
          dayNumber: date.day,
          isCurrentMonth: isCurrentMonth,
          isSelectable: isSelectable,
          isHoliday: isHoliday,
          isBooked: isBooked,
          isSelected:
              isCurrentMonth && isSameDemoDate(_selectedDate, normalizedDate),
        ),
      );
    }

    return cells;
  }

  void _selectDate(DateTime date) {
    if (demoScheduleStore.isDateLockedForHost(
      hostName: widget.hostName,
      date: date,
    )) {
      return;
    }
    setState(() {
      _selectedDate = date;
      _selectedStartHour = null;
      _selectedDuration = null;
    });
  }

  void _confirmRequest() {
    if (_meetingAddressController.text.trim().isEmpty ||
        _landmarkController.text.trim().isEmpty ||
        _selectedStartHour == null ||
        _selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete the event type, address, landmark, date, time, and duration first.',
          ),
        ),
      );
      return;
    }

    if (demoScheduleStore.isDateLockedForHost(
      hostName: widget.hostName,
      date: _selectedDate,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This date is unavailable because the talent is on holiday or another user has already booked it. Please choose a different date.',
          ),
        ),
      );
      return;
    }

    final request = demoScheduleStore.createRequest(
      hostName: widget.hostName,
      eventType: _selectedEventType,
      meetingAddress: _meetingAddressController.text.trim(),
      landmark: _landmarkController.text.trim(),
      date: _selectedDate,
      startHour: _selectedStartHour!,
      durationHours: _selectedDuration!,
    );

    Navigator.pop(context, request);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final availableStartHours = _availableStartHours();
    final availableDurations = _availableDurations();
    final calendarCells = _calendarCells();
    final monthLabel = _monthLabel(_visibleMonth);

    if (_selectedStartHour != null &&
        !availableStartHours.contains(_selectedStartHour)) {
      _selectedStartHour = null;
      _selectedDuration = null;
    }
    if (_selectedDuration != null &&
        !availableDurations.contains(_selectedDuration)) {
      _selectedDuration = null;
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.72,
          maxChildSize: 0.96,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 56,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7C9B8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Meet Offline',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF221A14),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Book a date with ${widget.hostName}',
                                    style: const TextStyle(
                                      color: Color(0xFF7D6F64),
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
                        if (widget.verificationBypassed) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1E3),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFFFD3AA),
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: userAmberDark,
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Demo mode is active. ID and selfie verification are temporarily bypassed so you can preview the full meet request flow.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: userAmberDark,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        _sheetSectionTitle(
                          Icons.auto_awesome_rounded,
                          'Event Type',
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE8DCCF)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedEventType,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(18),
                              items: _eventTypes
                                  .map(
                                    (type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() => _selectedEventType = value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _sheetSectionTitle(
                          Icons.location_on_outlined,
                          'Meeting Location',
                        ),
                        const SizedBox(height: 10),
                        _sheetField(
                          controller: _meetingAddressController,
                          label: 'Meeting address',
                          hint: 'Enter the full address for the meetup',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        _sheetField(
                          controller: _landmarkController,
                          label: 'Landmark',
                          hint:
                              'Example: main lobby entrance or next to the coffee shop',
                        ),
                        const SizedBox(height: 18),
                        _sheetSectionTitle(
                          Icons.calendar_today_rounded,
                          'Meeting Calendar',
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE8DCCF)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _canGoToPreviousMonth()
                                        ? () => setState(
                                            () => _visibleMonth = DateTime(
                                              _visibleMonth.year,
                                              _visibleMonth.month - 1,
                                            ),
                                          )
                                        : null,
                                    icon: const Icon(
                                      Icons.chevron_left_rounded,
                                    ),
                                  ),
                                  Text(
                                    monthLabel,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2C2018),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _canGoToNextMonth()
                                        ? () => setState(
                                            () => _visibleMonth = DateTime(
                                              _visibleMonth.year,
                                              _visibleMonth.month + 1,
                                            ),
                                          )
                                        : null,
                                    icon: const Icon(
                                      Icons.chevron_right_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _calendarLegend(
                                    const Color(0xFFCA6C34),
                                    'Selected',
                                  ),
                                  _calendarLegend(
                                    const Color(0xFFE34A57),
                                    'Holiday',
                                  ),
                                  _calendarLegend(
                                    const Color(0xFFB0B7C3),
                                    'Booked',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: _weekdayLabels
                                    .map(
                                      (label) => Expanded(
                                        child: Center(
                                          child: Text(
                                            label,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF8A7C70),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: calendarCells.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 0.9,
                                    ),
                                itemBuilder: (context, index) {
                                  final cell = calendarCells[index];
                                  return _calendarDayCell(cell);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _sheetSectionTitle(
                          Icons.schedule_rounded,
                          'Meeting Time',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Duration rules: the minimum is 3 hours. If you choose a start time after 01:00 PM, the maximum duration is 4 hours. If you choose 01:00 PM or earlier, the duration can be 3 to 8 hours.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7D6F64),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (availableStartHours.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1E3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              demoScheduleStore.isTalentHoliday(
                                    hostName: widget.hostName,
                                    date: _selectedDate,
                                  )
                                  ? 'This date has been marked as a holiday by the talent and cannot be selected.'
                                  : 'This date has already been booked by another user. A talent can only take one booking per date unless that booking is cancelled by the talent.',
                              style: TextStyle(
                                color: userAmberDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: availableStartHours
                                .map(
                                  (hour) => _choiceChip(
                                    label: formatDemoHour(hour),
                                    selected: _selectedStartHour == hour,
                                    onTap: () {
                                      setState(() {
                                        _selectedStartHour = hour;
                                        _selectedDuration = null;
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 16),
                        _sheetSectionTitle(Icons.timelapse_rounded, 'Duration'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: availableDurations
                              .map(
                                (duration) => _choiceChip(
                                  label: '$duration jam',
                                  selected: _selectedDuration == duration,
                                  onTap: () => setState(
                                    () => _selectedDuration = duration,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        if (_selectedStartHour != null &&
                            _selectedDuration != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF5E7), Color(0xFFFFE8CF)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Request Summary',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2C2018),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _summaryRow('Event', _selectedEventType),
                                _summaryRow(
                                  'Date',
                                  formatDemoDate(_selectedDate),
                                ),
                                _summaryRow(
                                  'Time',
                                  '${formatDemoHour(_selectedStartHour!)} - ${formatDemoHour(_selectedStartHour! + _selectedDuration!)}',
                                ),
                                _summaryRow(
                                  'Duration',
                                  '$_selectedDuration hours',
                                ),
                                _summaryRow('Booking fee', '🪙 500 coins'),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _confirmRequest,
                            style: FilledButton.styleFrom(
                              backgroundColor: userAmberDark,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Confirm Meet Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
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
        ),
      ),
    );
  }

  Widget _sheetSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4C3A2E)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF221A14),
          ),
        ),
      ],
    );
  }

  Widget _calendarLegend(Color color, String label) {
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
            color: Color(0xFF7D6F64),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _calendarDayCell(_CalendarDayCell cell) {
    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;

    if (!cell.isCurrentMonth) {
      backgroundColor = const Color(0xFFF8F4EF);
      borderColor = Colors.transparent;
      textColor = const Color(0xFFD1C6BB);
    } else if (cell.isSelected) {
      backgroundColor = userAmberDark;
      borderColor = userAmberDark;
      textColor = Colors.white;
    } else if (cell.isHoliday) {
      backgroundColor = const Color(0xFFFFE6EA);
      borderColor = const Color(0xFFE34A57);
      textColor = const Color(0xFFE34A57);
    } else if (cell.isBooked) {
      backgroundColor = const Color(0xFFF2F4F7);
      borderColor = const Color(0xFFB0B7C3);
      textColor = const Color(0xFF7F8793);
    } else if (!cell.isSelectable) {
      backgroundColor = const Color(0xFFF8F4EF);
      borderColor = const Color(0xFFE8DCCF);
      textColor = const Color(0xFFC4B8AC);
    } else {
      backgroundColor = Colors.white;
      borderColor = const Color(0xFFE8DCCF);
      textColor = const Color(0xFF2C2018);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: cell.isSelectable ? () => _selectDate(cell.date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${cell.dayNumber}',
              style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 4),
            if (cell.isHoliday)
              const _CalendarStatusDot(color: Color(0xFFE34A57))
            else if (cell.isBooked)
              const _CalendarStatusDot(color: Color(0xFF8C95A2))
            else if (cell.isSelected)
              const _CalendarStatusDot(color: Colors.white)
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE8DCCF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE8DCCF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: userAmberDark, width: 1.4),
        ),
      ),
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? userAmberDark : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? userAmberDark : const Color(0xFFE8DCCF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5B4B3F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF7D6F64)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2018),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime month) {
    const monthNames = [
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
    return '${monthNames[month.month - 1]} ${month.year}';
  }
}

class _CalendarDayCell {
  const _CalendarDayCell({
    required this.date,
    required this.dayNumber,
    required this.isCurrentMonth,
    required this.isSelectable,
    required this.isHoliday,
    required this.isBooked,
    required this.isSelected,
  });

  final DateTime date;
  final int dayNumber;
  final bool isCurrentMonth;
  final bool isSelectable;
  final bool isHoliday;
  final bool isBooked;
  final bool isSelected;
}

class _CalendarStatusDot extends StatelessWidget {
  const _CalendarStatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
