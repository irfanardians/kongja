import 'dart:convert';

import 'api_client.dart';

class TalentPublicProfileService {
  TalentPublicProfileService._();

  static const Duration _cacheMaxAge = Duration(minutes: 5);

  static Future<TalentPublicProfileData> getTalentProfile(
    String accountId, {
    bool forceRefresh = false,
  }) async {
    final trimmedAccountId = accountId.trim();
    if (trimmedAccountId.isEmpty) {
      throw const TalentPublicProfileException(
        'Talent account id tidak tersedia.',
      );
    }

    final decoded = await _getProfileJson(
      trimmedAccountId,
      forceRefresh: forceRefresh,
    );

    return _parseProfile(decoded, trimmedAccountId);
  }

  static Future<dynamic> _getProfileJson(
    String accountId, {
    required bool forceRefresh,
  }) async {
    final primaryPath = '/talents/$accountId';
    final fallbackPath = '/talent/$accountId';

    final cachedPrimary = !forceRefresh
        ? ApiClient.peekCachedJson(primaryPath, maxAge: _cacheMaxAge)
        : null;
    if (cachedPrimary != null) {
      return cachedPrimary;
    }

    final cachedFallback = !forceRefresh
        ? ApiClient.peekCachedJson(fallbackPath, maxAge: _cacheMaxAge)
        : null;
    if (cachedFallback != null) {
      return cachedFallback;
    }

    final primaryResponse = await ApiClient.get(primaryPath, authorized: true);
    if (primaryResponse.statusCode >= 200 && primaryResponse.statusCode < 300) {
      final decoded = primaryResponse.body.isEmpty
          ? null
          : jsonDecode(primaryResponse.body);
      ApiClient.invalidateCache(fallbackPath);
      return decoded;
    }

    final fallbackResponse = await ApiClient.get(
      fallbackPath,
      authorized: true,
    );
    if (fallbackResponse.statusCode >= 200 && fallbackResponse.statusCode < 300) {
      return fallbackResponse.body.isEmpty
          ? null
          : jsonDecode(fallbackResponse.body);
    }

    throw TalentPublicProfileException(
      'Data talent tidak dapat dibaca. Server mengembalikan status '
      '${primaryResponse.statusCode} pada $primaryPath dan '
      '${fallbackResponse.statusCode} pada $fallbackPath.',
    );
  }

  static TalentPublicProfileData _parseProfile(
    dynamic decoded,
    String accountId,
  ) {
    final data = _extractDataMap(decoded);
    if (data == null) {
      throw const TalentPublicProfileException(
        'Data talent tidak ditemukan di respons backend.',
      );
    }

    final stageName = _firstNonEmpty([
      data['stage_name'],
      data['call_name'],
      data['display_name'],
      data['first_name'],
    ], fallback: 'Talent');
    final firstName = _firstNonEmpty([
      data['first_name'],
      _nestedValue(data['account'], 'first_name'),
    ]);
    final lastName = _firstNonEmpty([
      data['last_name'],
      _nestedValue(data['account'], 'last_name'),
    ]);
    final displayName = ([firstName, lastName]
              .where((item) => item.trim().isNotEmpty)
              .join(' '))
          .trim()
          .isNotEmpty
        ? [firstName, lastName]
            .where((item) => item.trim().isNotEmpty)
            .join(' ')
            .trim()
        : stageName;

    final avatarUrl = _firstNonEmpty([
      data['avatar_url'],
      _nestedValue(data['talent_information'], 'avatar_url'),
      _nestedValue(data['profile_summary'], 'avatar_url'),
    ]);
    final city = _stringValue(data['city']);
    final country = _stringValue(data['country']);
    final countryCode = _countryCodeValue([
      data['country_code'],
      _nestedValue(data['account'], 'country_code'),
      _nestedValue(data['profile_summary'], 'country_code'),
      _nestedValue(data['talent_information'], 'country_code'),
      data['phone_country_code'],
      _nestedValue(data['account'], 'phone_country_code'),
    ]);
    final languages = _stringList(data['languages']);
    final specialties = _stringList(
      data['specialties'] ?? data['specialities'] ?? data['specialty'],
    );

    return TalentPublicProfileData(
      accountId: _firstNonEmpty([
        data['account_id'],
        data['id'],
        accountId,
      ], fallback: accountId),
      displayName: displayName,
      stageName: stageName,
      avatarUrl: avatarUrl,
      city: city,
      country: country,
      countryCode: countryCode,
      bio: _firstNonEmpty([
        data['bio'],
        data['description'],
        _nestedValue(data['profile_summary'], 'bio'),
      ]),
      age: _intValue(data['age']) > 0
          ? _intValue(data['age'])
          : _ageFromDate(_firstNonEmpty([
              data['date_of_birth'],
              data['birth_date'],
              _nestedValue(data['account'], 'date_of_birth'),
            ])),
      level: _firstNonEmpty([data['level']], fallback: 'basic'),
      rating: _doubleValue(data['average_rating']),
      reviewCount: _intValue(data['review_count']),
      isOnline: _boolValue(data['is_online_setting'] ?? data['is_online']),
      languages: languages,
      specialties: specialties,
      verificationStatus: _stringValue(data['verification_status']),
      portfolioUrls: _extractPortfolioUrls(data, fallbackAvatarUrl: avatarUrl),
      servicePrices: _extractServicePrices(data['tier_pricing']),
    );
  }

  static Map<String, dynamic>? _extractDataMap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return decoded;
    }
    return null;
  }

  static List<String> _extractPortfolioUrls(
    Map<String, dynamic> data, {
    required String fallbackAvatarUrl,
  }) {
    final urls = <String>[];
    final value = data['portfolio_photos'];
    if (value is List) {
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          final url = _firstNonEmpty([
            item['public_url'],
            item['url'],
            item['photo_url'],
            _nestedValue(item['media'], 'url'),
            _nestedValue(item['file'], 'url'),
          ]);
          if (url.isNotEmpty) {
            urls.add(url);
          }
        } else {
          final url = _stringValue(item);
          if (url.isNotEmpty) {
            urls.add(url);
          }
        }
      }
    }

    if (urls.isEmpty && fallbackAvatarUrl.isNotEmpty) {
      urls.add(fallbackAvatarUrl);
    }

    return urls;
  }

  static Map<String, int> _extractServicePrices(dynamic tierPricing) {
    final prices = <String, int>{};
    if (tierPricing is Map<String, dynamic>) {
      final services = tierPricing['services'];
      if (services is List) {
        for (final item in services) {
          if (item is! Map<String, dynamic>) {
            continue;
          }
          final normalizedType = _normalizeServiceType(
            _stringValue(item['service_type']),
          );
          final amount = _extractPriceValue(item);
          if (normalizedType.isNotEmpty && amount > 0) {
            prices[normalizedType] = amount;
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
        final normalizedType = _normalizeServiceType(key);
        final amount = _extractPriceValue(tierPricing[key]);
        if (normalizedType.isNotEmpty && amount > 0) {
          prices[normalizedType] = amount;
        }
      }
    }

    return prices;
  }

  static int _extractPriceValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _intValue(value['coin_amount']) > 0
          ? _intValue(value['coin_amount'])
          : _intValue(value['price_per_hour']);
    }
    return _intValue(value);
  }

  static String _normalizeServiceType(String rawType) {
    final normalized = rawType.trim().toLowerCase();
    switch (normalized) {
      case 'chat':
        return 'chat';
      case 'voice':
      case 'voice_call':
      case 'call':
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

  static dynamic _nestedValue(dynamic value, String key) {
    if (value is Map<String, dynamic>) {
      return value[key];
    }
    return null;
  }

  static String _stringValue(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return '';
  }

  static String _countryCodeValue(List<dynamic> values) {
    final rawValue = _firstNonEmpty(values);
    if (rawValue.isEmpty) {
      return '';
    }

    final digits = rawValue.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) {
      const phoneCountryCodeMap = {
        '62': 'ID',
        '63': 'PH',
        '66': 'TH',
        '84': 'VN',
        '81': 'JP',
        '1': 'US',
        '44': 'GB',
        '60': 'MY',
        '65': 'SG',
        '82': 'KR',
      };
      final mappedCode = phoneCountryCodeMap[digits];
      if (mappedCode != null) {
        return mappedCode;
      }
    }

    final letters = rawValue.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.length >= 2) {
      return letters.substring(0, 2).toUpperCase();
    }

    return '';
  }

  static String _firstNonEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final stringValue = _stringValue(value);
      if (stringValue.isNotEmpty) {
        return stringValue;
      }
    }
    return fallback;
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map(_stringValue)
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static double _doubleValue(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static bool _boolValue(dynamic value) {
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

  static int _ageFromDate(String rawDate) {
    if (rawDate.isEmpty) {
      return 0;
    }

    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) {
      return 0;
    }

    final now = DateTime.now();
    var age = now.year - parsedDate.year;
    final hasBirthdayPassed =
        now.month > parsedDate.month ||
        (now.month == parsedDate.month && now.day >= parsedDate.day);
    if (!hasBirthdayPassed) {
      age -= 1;
    }
    return age < 0 ? 0 : age;
  }
}

class TalentPublicProfileData {
  const TalentPublicProfileData({
    required this.accountId,
    required this.displayName,
    required this.stageName,
    required this.avatarUrl,
    required this.city,
    required this.country,
    required this.countryCode,
    required this.bio,
    required this.age,
    required this.level,
    required this.rating,
    required this.reviewCount,
    required this.isOnline,
    required this.languages,
    required this.specialties,
    required this.verificationStatus,
    required this.portfolioUrls,
    required this.servicePrices,
  });

  final String accountId;
  final String displayName;
  final String stageName;
  final String avatarUrl;
  final String city;
  final String country;
  final String countryCode;
  final String bio;
  final int age;
  final String level;
  final double rating;
  final int reviewCount;
  final bool isOnline;
  final List<String> languages;
  final List<String> specialties;
  final String verificationStatus;
  final List<String> portfolioUrls;
  final Map<String, int> servicePrices;
}

class TalentPublicProfileException implements Exception {
  const TalentPublicProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}