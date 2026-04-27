// Flutter translation of cocoa/src/app/pages/Home.tsx
//
// Semua komponen input, filter, dan list host harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET /hosts (list host)
// - GET /hosts?city=xxx&query=xxx (filter)
//
// Komponen reusable (HostCard, BottomNav) dibuat di folder components terpisah.
//
// Untuk pengembangan backend, pastikan response sesuai kebutuhan UI.

import 'package:flutter/material.dart';

import '../../core/services/talent_service.dart';
import '../../core/services/user_wallet_service.dart';
import '../../shared/demo_schedule_store.dart';
import 'user_ui_shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeFilter = 'People';
  String searchQuery = '';
  String selectedCity = 'All Cities';
  String citySearchQuery = '';
  bool showCityDropdown = false;
  final TextEditingController _cityController = TextEditingController();
  List<DemoUserHost> _hosts = const [];
  bool _isLoadingHosts = false;
  String? _hostsError;
  int _availableCoinBalance = 0;

  @override
  void initState() {
    super.initState();
    final cachedHosts = _mapTalentsToHosts(TalentService.peekCachedTalents());
    final cachedBalance = UserWalletService.peekCachedAvailableCoinBalance();
    if (cachedHosts.isNotEmpty) {
      _hosts = cachedHosts;
    }
    if (cachedBalance != null) {
      _availableCoinBalance = cachedBalance;
    }
    _loadHosts(showLoading: cachedHosts.isEmpty);
    _loadWalletBalance();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadHosts({
    bool forceRefresh = false,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      setState(() {
        _isLoadingHosts = true;
        _hostsError = null;
      });
    }

    try {
      final talents = await TalentService.getAllTalents(
        forceRefresh: forceRefresh,
      );
      final hosts = _mapTalentsToHosts(talents);

      if (!mounted) {
        return;
      }

      setState(() {
        _hosts = hosts;
        _isLoadingHosts = false;
        _hostsError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingHosts = false;
        _hostsError = 'Gagal memuat daftar talent. Coba lagi.';
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

  Future<void> _refreshHomeData() async {
    await Future.wait<void>([
      _loadHosts(forceRefresh: true, showLoading: false),
      _loadWalletBalance(forceRefresh: true),
    ]);
  }

  List<DemoUserHost> _mapTalentsToHosts(List<Map<String, dynamic>> talents) {
    return talents
        .asMap()
        .entries
        .map((entry) {
          return _mapTalentToHost(entry.value, entry.key);
        })
        .toList(growable: false);
  }

  DemoUserHost _mapTalentToHost(Map<String, dynamic> talent, int index) {
    final accountId = _stringValue(talent['account_id']);
    final stageName = _stringValue(
      talent['stage_name'],
      fallback: 'Talent ${index + 1}',
    );
    final bio = _stringValue(talent['bio']);
    final city = _stringValue(talent['city'], fallback: 'Unknown City');
    final country = _stringValue(talent['country'], fallback: 'Indonesia');
    final avatarUrl = _stringValue(
      talent['avatar_url'],
      fallback: _nestedStringValue(talent['talent_information'], 'avatar_url'),
    );
    final specialties = _stringList(talent['specialties']);
    final languages = _stringList(talent['languages']);
    final level = _stringValue(talent['level'], fallback: 'basic');
    final verificationStatus = _stringValue(talent['verification_status']);
    final description = bio.isNotEmpty
        ? bio
        : specialties.isNotEmpty
        ? specialties.join(' • ')
        : 'Ready to connect';

    return DemoUserHost(
      id: accountId.hashCode == 0 ? index + 1 : accountId.hashCode,
      accountId: accountId,
      name: stageName,
      age: 0,
      city: city,
      countryCode: _countryCode(country),
      description: description,
      imageUrl: avatarUrl,
      pricePerMin: _resolvePricePerHour(talent['tier_pricing'], level),
      tierLabel: _tierLabel(level),
      rating: _doubleValue(talent['average_rating']),
      reviewCount: _intValue(talent['review_count']),
      badges: _buildBadges(
        level: level,
        verificationStatus: verificationStatus,
        specialties: specialties,
        languages: languages,
      ),
      portfolio: avatarUrl.isEmpty ? const [] : [avatarUrl],
      isOnline: _boolValue(talent['is_online_setting']),
      location: '$city, $country',
      biography: bio.isNotEmpty ? bio : description,
      languages: languages,
      specialties: specialties,
      servicePrices: _resolveServicePrices(talent['tier_pricing']),
    );
  }

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  String _nestedStringValue(dynamic parent, String key) {
    if (parent is Map<String, dynamic>) {
      return _stringValue(parent[key]);
    }
    return '';
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  double _doubleValue(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  bool _boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  List<String> _buildBadges({
    required String level,
    required String verificationStatus,
    required List<String> specialties,
    required List<String> languages,
  }) {
    final badges = <String>[];
    if (level.isNotEmpty) {
      badges.add(_capitalize(level));
    }
    if (verificationStatus.isNotEmpty) {
      badges.add(_capitalize(verificationStatus));
    }
    badges.addAll(specialties.take(2));
    if (badges.length < 3) {
      badges.addAll(languages.take(3 - badges.length));
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

  int _resolvePricePerHour(dynamic tierPricing, String level) {
    final servicePrices = _resolveServicePrices(tierPricing);
    final chatPrice = servicePrices['chat'] ?? 0;
    if (chatPrice > 0) {
      return chatPrice;
    }

    switch (level.toLowerCase()) {
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
  }

  Map<String, int> _resolveServicePrices(dynamic tierPricing) {
    final prices = <String, int>{};
    if (tierPricing is Map<String, dynamic>) {
      final services = tierPricing['services'];
      if (services is List) {
        for (final service in services) {
          if (service is! Map<String, dynamic>) {
            continue;
          }

          final serviceType = _stringValue(service['service_type']).toLowerCase();
          final parsedCoinAmount = _intValue(service['coin_amount']);
          final normalizedServiceType = _normalizeServiceType(serviceType);
          if (normalizedServiceType.isNotEmpty && parsedCoinAmount > 0) {
            prices[normalizedServiceType] = parsedCoinAmount;
          }
        }
      }

      for (final key in const [
        'chat',
        'voice',
        'call',
        'voice_call',
        'video',
        'video_call',
        'meet',
        'offline_meet',
      ]) {
        final normalizedServiceType = _normalizeServiceType(key);
        if (normalizedServiceType.isEmpty) {
          continue;
        }

        final rawPrice = tierPricing[key];
        final parsedPrice = rawPrice is Map<String, dynamic>
            ? (_intValue(rawPrice['coin_amount']) > 0
                  ? _intValue(rawPrice['coin_amount'])
                  : _intValue(rawPrice['price_per_hour']))
            : _intValue(rawPrice);
        if (parsedPrice > 0) {
          prices[normalizedServiceType] = parsedPrice;
        }
      }
    }

    return prices;
  }

  String _normalizeServiceType(String rawType) {
    switch (rawType.trim().toLowerCase()) {
      case 'chat':
        return 'chat';
      case 'voice':
      case 'call':
      case 'voice_call':
      case 'audio':
        return 'voice';
      case 'video':
      case 'video_call':
        return 'video';
      case 'meet':
      case 'offline_meet':
      case 'offline':
      case 'meeting':
        return 'meet';
      default:
        return '';
    }
  }

  Future<void> _openScheduleNotifications(
    List<DemoScheduleNotification> notifications,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.48,
          maxChildSize: 0.9,
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Schedule Notifications',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF241B15),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Accepted and rejected schedule updates from talents.',
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
                  if (notifications.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Text(
                        'Belum ada notifikasi schedule dari talent.',
                        style: TextStyle(color: Color(0xFF6A625B)),
                      ),
                    )
                  else
                    ...notifications.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: item.isPositive
                                    ? const Color(0xFFE6F7EC)
                                    : const Color(0xFFFFE8E8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                item.isPositive
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: item.isPositive
                                    ? const Color(0xFF218C4F)
                                    : const Color(0xFFD54343),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.body,
                                    style: const TextStyle(
                                      color: Color(0xFF6D655F),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${item.request.eventType} • ${item.request.dateLabel}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: item.isPositive
                                          ? const Color(0xFF218C4F)
                                          : const Color(0xFFD54343),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sourceHosts = _hosts.isNotEmpty ? _hosts : demoUserHosts;
    final cities = [
      'All Cities',
      ...{for (final host in sourceHosts) host.city}.toList()..sort(),
    ];

    final filteredHosts = sourceHosts.where((host) {
      final matchCity =
          selectedCity == 'All Cities' || host.city == selectedCity;
      final matchQuery =
          searchQuery.isEmpty ||
          host.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          host.city.toLowerCase().contains(searchQuery.toLowerCase());
      final matchFilter = switch (activeFilter) {
        'Online' => host.isOnline,
        'VIP' => host.badges.any(
          (badge) => badge.toLowerCase().contains('vip'),
        ),
        _ => true,
      };
      return matchCity && matchQuery && matchFilter;
    }).toList();
    final topHosts = filteredHosts.take(3).toList();
    final newHosts = filteredHosts.length > 3
        ? filteredHosts.skip(3).toList()
        : <DemoUserHost>[];

    return ValueListenableBuilder<List<DemoMeetRequest>>(
      valueListenable: demoScheduleStore,
      builder: (context, value, child) {
        final notifications = demoScheduleStore.notificationsForUser(
          demoCurrentUserName,
        );

        if (_isLoadingHosts && _hosts.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F1E8),
            bottomNavigationBar: widget.showBottomNav
                ? const UserBottomNav(currentRoute: '/home')
                : null,
            body: SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  Container(
                    width: 160,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9DED0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 220,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9DED0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(2, (sectionIndex) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: sectionIndex == 0 ? 28 : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 110,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9DED0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: List.generate(3, (cardIndex) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: cardIndex == 2 ? 0 : 16,
                                  ),
                                  child: Column(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 0.78,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE9DED0),
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE9DED0),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 70,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE9DED0),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F1E8),
          bottomNavigationBar: widget.showBottomNav
              ? const UserBottomNav(currentRoute: '/home')
              : null,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: Colors.brown,
              backgroundColor: Colors.white,
              onRefresh: _refreshHomeData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Attention',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '🪙 ${_formatCoinBalance(_availableCoinBalance)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _openScheduleNotifications(
                                            notifications,
                                          ),
                                      icon: const Icon(
                                        Icons.notifications,
                                        color: Colors.brown,
                                        size: 28,
                                      ),
                                    ),
                                    if (notifications.isNotEmpty)
                                      Positioned(
                                        right: 4,
                                        top: 2,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFE34B57),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${notifications.length}',
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
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Find Someone to Talk With',
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                        // Search
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            hintText: 'Search by name or city...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 0,
                            ),
                          ),
                          onChanged: (val) => setState(() => searchQuery = val),
                        ),
                        const SizedBox(height: 12),
                        // City Selector
                        Stack(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.location_on,
                                  color: Colors.grey,
                                ),
                                hintText: 'Search cities...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 0,
                                ),
                              ),
                              controller: _cityController,
                              onChanged: (val) => setState(() {
                                citySearchQuery = val;
                                showCityDropdown = true;
                              }),
                              onTap: () =>
                                  setState(() => showCityDropdown = true),
                            ),
                            if (showCityDropdown)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 48,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  constraints: const BoxConstraints(
                                    maxHeight: 180,
                                  ),
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: cities
                                        .where(
                                          (city) => city.toLowerCase().contains(
                                            citySearchQuery.toLowerCase(),
                                          ),
                                        )
                                        .map(
                                          (city) => ListTile(
                                            leading: const Icon(
                                              Icons.location_on,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            title: Text(city),
                                            selected: selectedCity == city,
                                            onTap: () {
                                              setState(() {
                                                selectedCity = city;
                                                citySearchQuery = city;
                                                _cityController.text = city;
                                                showCityDropdown = false;
                                              });
                                            },
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Filter
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: ['People', 'Online', 'New', 'VIP'].map((
                              filter,
                            ) {
                              final selected = activeFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(filter),
                                  selected: selected,
                                  selectedColor: Colors.brown,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.brown,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => activeFilter = filter),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (_hostsError != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEFEA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Gagal memuat data terbaru. Menampilkan data terakhir yang tersedia.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8A4E2A),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _loadHosts(forceRefresh: true);
                                    _loadWalletBalance(forceRefresh: true);
                                  },
                                  child: const Text('Coba lagi'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                    if (topHosts.isNotEmpty)
                      _buildHostSection(
                        title: 'Top Hosts',
                        sectionHosts: topHosts,
                      ),

                    if (newHosts.isNotEmpty)
                      _buildHostSection(
                        title: 'New Hosts',
                        sectionHosts: newHosts,
                      ),

                    // No Results
                    if (topHosts.isEmpty && newHosts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          'No hosts found matching your search',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHostSection({
    required String title,
    required List<DemoUserHost> sectionHosts,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All >',
                  style: TextStyle(color: Colors.brown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 16.0;
              final columns = constraints.maxWidth < 420 ? 2 : 3;
              final itemWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 20,
                children: List.generate(sectionHosts.length, (idx) {
                  return SizedBox(
                    width: itemWidth,
                    child: UserHostCard(
                      host: sectionHosts[idx],
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/profile',
                        arguments: sectionHosts[idx],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
