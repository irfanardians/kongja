import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'auth_service.dart';
import 'talent_service.dart';

class TalentProfileService {
  TalentProfileService._();

  static const Duration _cacheMaxAge = Duration(minutes: 5);

  static TalentProfileData? peekCachedMyProfile() {
    final decoded = ApiClient.peekCachedJson(
      '/talent/me',
      maxAge: _cacheMaxAge,
    );

    if (decoded == null) {
      return null;
    }

    final profile = _parseProfile(decoded);
    if (!profile.hasAnyContent) {
      return null;
    }

    return profile;
  }

  static Future<TalentProfileData> getMyProfile({
    bool forceRefresh = false,
  }) async {
    final decoded = await ApiClient.getJson(
      '/talent/me',
      useCache: true,
      forceRefresh: forceRefresh,
      maxAge: _cacheMaxAge,
    );

    return _parseProfile(decoded);
  }

  static Future<TalentProfileData> refreshRelatedData() async {
    ApiClient.invalidateCache('/talent/me');
    ApiClient.invalidateCache(
      '/talents',
      queryParameters: const {'get_all': true},
    );

    final profileFuture = getMyProfile(forceRefresh: true);
    final talentsFuture = TalentService.getAllTalents(forceRefresh: true);

    final results = await Future.wait<dynamic>([
      profileFuture,
      talentsFuture,
    ]);

    return results.first as TalentProfileData;
  }

  static Future<void> updateOnlineStatus(bool isOnline) async {
    final response = await ApiClient.postJson(
      '/talent/profile/online-status',
      body: {'is_online': isOnline},
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(
          response,
          fallbackPrefix: 'Update status online gagal',
        ),
      );
    }

    ApiClient.invalidateCache('/talent/me');
    ApiClient.invalidateCache('/talents', queryParameters: const {'get_all': true});
  }

  static Future<TalentProfileData> uploadAvatar(String filePath) async {
    final response = await ApiClient.postMultipart(
      '/talent/profile/avatar',
      fileField: 'avatar',
      filePath: filePath,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(response, fallbackPrefix: 'Upload foto profil gagal'),
      );
    }

    ApiClient.invalidateCache('/talent/me');
    return getMyProfile(forceRefresh: true);
  }

  static Future<TalentProfileData> uploadPortfolioPhoto(String filePath) async {
    final response = await ApiClient.postMultipart(
      '/talent/profile/portfolio-photos',
      fileField: 'photos',
      filePath: filePath,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(response, fallbackPrefix: 'Upload foto portfolio gagal'),
      );
    }

    ApiClient.invalidateCache('/talent/me');
    return getMyProfile(forceRefresh: true);
  }

  static Future<TalentProfileData> deletePortfolioPhoto(String mediaId) async {
    final response = await ApiClient.delete(
      '/talent/profile/portfolio-photos/$mediaId',
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(response, fallbackPrefix: 'Hapus foto portfolio gagal'),
      );
    }

    ApiClient.invalidateCache('/talent/me');
    return getMyProfile(forceRefresh: true);
  }
  
  static Future<TalentProfileData> updateBasicSettings({
    required String callName,
    required String email,
    required String phoneCountryCode,
    required String phone,
    required String address,
    required String city,
    required String country,
    required String postcode,
  }) async {
    final response = await ApiClient.postJson(
      '/setting/talent/basic',
      body: {
        'call_name': callName,
        'email': email,
        'phone_country_code': phoneCountryCode,
        'phone': phone,
        'address': address,
        'city': city,
        'country': country,
        'postcode': postcode,
      },
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(
          response,
          fallbackPrefix: 'Simpan pengaturan talent gagal',
        ),
      );
    }

    ApiClient.invalidateCache('/talent/me');
    return getMyProfile(forceRefresh: true);
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await ApiClient.postJson(
      '/setting/talent/changepassword',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(
          response,
          fallbackPrefix: 'Ubah password talent gagal',
        ),
      );
    }
  }

  static TalentProfileData _parseProfile(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return TalentProfileData(
          avatarUrl: _firstNonEmpty([
            data['avatar_url'],
            if (data['talent_information'] is Map<String, dynamic>)
              (data['talent_information'] as Map<String, dynamic>)['avatar_url'],
            if (data['profile_summary'] is Map<String, dynamic>)
              (data['profile_summary'] as Map<String, dynamic>)['avatar_url'],
          ]),
          isOnline: _boolValue(data['is_online']),
          callName: _firstNonEmpty([
            data['call_name'],
            if (data['account'] is Map<String, dynamic>)
              (data['account'] as Map<String, dynamic>)['call_name'],
            data['stage_name'],
            data['first_name'],
          ]),
          stageName: _firstNonEmpty([
            data['stage_name'],
            if (data['talent_information'] is Map<String, dynamic>)
              (data['talent_information'] as Map<String, dynamic>)['stage_name'],
            if (data['profile_summary'] is Map<String, dynamic>)
              (data['profile_summary'] as Map<String, dynamic>)['stage_name'],
          ]),
          firstName: _firstNonEmpty([
            data['first_name'],
            if (data['account'] is Map<String, dynamic>)
              (data['account'] as Map<String, dynamic>)['first_name'],
          ]),
          lastName: _firstNonEmpty([
            data['last_name'],
            if (data['account'] is Map<String, dynamic>)
              (data['account'] as Map<String, dynamic>)['last_name'],
          ]),
          email: _firstNonEmpty([
            data['email'],
            if (data['account'] is Map<String, dynamic>)
              (data['account'] as Map<String, dynamic>)['email'],
            data['username'],
          ]),
          phoneCountryCode: _firstNonEmpty([
            data['phone_country_code'],
            if (data['account'] is Map<String, dynamic>)
              (data['account'] as Map<String, dynamic>)['phone_country_code'],
          ]),
          phone: _firstNonEmpty([
            data['phone'],
            if (data['account'] is Map<String, dynamic>)
              (data['account'] as Map<String, dynamic>)['phone'],
          ]),
          address: _stringValue(data['address']),
          city: _stringValue(data['city']),
          country: _stringValue(data['country']),
          postcode: _stringValue(data['postcode']),
          gender: _firstNonEmpty([
            data['gender'],
            if (data['account'] is Map<String, dynamic>)
              (data['account'] as Map<String, dynamic>)['gender'],
          ]),
          dateOfBirth: _firstNonEmpty([
            data['date_of_birth'],
            data['birth_date'],
            if (data['account'] is Map<String, dynamic>)
              (data['account'] as Map<String, dynamic>)['date_of_birth'],
          ]),
          level: _stringValue(data['level']),
          averageRating: _doubleValue(data['average_rating']),
          todayCoinEarning: _intValue(data['today_coin_earning']),
          thisWeekCoinEarning: _intValue(data['this_week_coin_earning']),
          monthToDateCoinEarning: _intValue(data['month_to_date_coin_earning']),
          portfolioPhotos: _extractPortfolioPhotos(data),
        );
      }
    }

    return const TalentProfileData(
      avatarUrl: '',
      isOnline: false,
      callName: '',
      stageName: '',
      firstName: '',
      lastName: '',
      email: '',
      phoneCountryCode: '',
      phone: '',
      address: '',
      city: '',
      country: '',
      postcode: '',
      gender: '',
      dateOfBirth: '',
      level: '',
      averageRating: 0,
      todayCoinEarning: 0,
      thisWeekCoinEarning: 0,
      monthToDateCoinEarning: 0,
      portfolioPhotos: [],
    );
  }

  static List<TalentPortfolioPhoto> _extractPortfolioPhotos(
    Map<String, dynamic> data,
  ) {
    return _parsePortfolioPhotoCollection(data['portfolio_photos']);
  }

  static List<TalentPortfolioPhoto> _parsePortfolioPhotoCollection(
    dynamic value,
  ) {
    if (value is List) {
      return _parsePortfolioPhotoList(value);
    }

    if (value is Map<String, dynamic>) {
      final nestedCandidates = [
        value['data'],
        value['items'],
        value['results'],
        value['photos'],
        value['portfolio_photos'],
      ];

      for (final candidate in nestedCandidates) {
        final parsed = _parsePortfolioPhotoCollection(candidate);
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }

      final singlePhoto = _parsePortfolioPhoto(value);
      if (singlePhoto != null) {
        return [singlePhoto];
      }
    }

    return const [];
  }

  static List<TalentPortfolioPhoto> _parsePortfolioPhotoList(List<dynamic> items) {
    final photos = <TalentPortfolioPhoto>[];
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        final photo = _parsePortfolioPhoto(item);
        if (photo != null) {
          photos.add(photo);
        }
        continue;
      }

      final url = _stringValue(item);
      if (url.isNotEmpty) {
        photos.add(TalentPortfolioPhoto(mediaId: '', url: url));
      }
    }

    return photos;
  }

  static TalentPortfolioPhoto? _parsePortfolioPhoto(Map<String, dynamic> item) {
    final nestedMedia = item['media'];
    final nestedFile = item['file'];
    final mediaId = _firstNonEmpty([
      item['media_id'],
      item['mediaId'],
      item['id'],
      item['uuid'],
      if (nestedMedia is Map<String, dynamic>) nestedMedia['id'],
      if (nestedMedia is Map<String, dynamic>) nestedMedia['uuid'],
      if (nestedFile is Map<String, dynamic>) nestedFile['id'],
      if (nestedFile is Map<String, dynamic>) nestedFile['uuid'],
    ]);
    final url = _firstNonEmpty([
      item['url'],
      item['public_url'],
      item['photo_url'],
      item['image_url'],
      item['media_url'],
      item['file_url'],
      item['path'],
      item['src'],
      item['original_url'],
      item['thumbnail_url'],
      if (nestedMedia is Map<String, dynamic>) nestedMedia['url'],
      if (nestedMedia is Map<String, dynamic>) nestedMedia['file_url'],
      if (nestedMedia is Map<String, dynamic>) nestedMedia['original_url'],
      if (nestedFile is Map<String, dynamic>) nestedFile['url'],
      if (nestedFile is Map<String, dynamic>) nestedFile['file_url'],
      if (nestedFile is Map<String, dynamic>) nestedFile['path'],
    ]);

    if (url.isEmpty) {
      return null;
    }

    return TalentPortfolioPhoto(mediaId: mediaId, url: url);
  }

  static String _extractMessage(
    http.Response response, {
    required String fallbackPrefix,
  }) {
    if (response.body.isEmpty) {
      return '$fallbackPrefix. Server mengembalikan status ${response.statusCode}.';
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
        if (message is List && message.isNotEmpty) {
          return message.join('\n');
        }
      }
    } catch (_) {
      return response.body;
    }

    return '$fallbackPrefix. Server mengembalikan status ${response.statusCode}.';
  }

  static String _stringValue(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return '';
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

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final stringValue = _stringValue(value);
      if (stringValue.isNotEmpty) {
        return stringValue;
      }
    }
    return '';
  }
}

class TalentProfileData {
  const TalentProfileData({
    required this.avatarUrl,
    required this.isOnline,
    required this.callName,
    required this.stageName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneCountryCode,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.postcode,
    required this.gender,
    required this.dateOfBirth,
    required this.level,
    required this.averageRating,
    required this.todayCoinEarning,
    required this.thisWeekCoinEarning,
    required this.monthToDateCoinEarning,
    required this.portfolioPhotos,
  });

  final String avatarUrl;
  final bool isOnline;
  final String callName;
  final String stageName;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneCountryCode;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String postcode;
  final String gender;
  final String dateOfBirth;
  final String level;
  final double averageRating;
  final int todayCoinEarning;
  final int thisWeekCoinEarning;
  final int monthToDateCoinEarning;
  final List<TalentPortfolioPhoto> portfolioPhotos;

  bool get hasAnyContent {
    return avatarUrl.isNotEmpty ||
        callName.isNotEmpty ||
        stageName.isNotEmpty ||
        firstName.isNotEmpty ||
        lastName.isNotEmpty ||
        email.isNotEmpty ||
        phoneCountryCode.isNotEmpty ||
        phone.isNotEmpty ||
        address.isNotEmpty ||
        city.isNotEmpty ||
        country.isNotEmpty ||
        postcode.isNotEmpty ||
        level.isNotEmpty ||
        averageRating > 0 ||
        todayCoinEarning > 0 ||
        thisWeekCoinEarning > 0 ||
        monthToDateCoinEarning > 0 ||
        portfolioPhotos.isNotEmpty;
  }
}

class TalentPortfolioPhoto {
  const TalentPortfolioPhoto({required this.mediaId, required this.url});

  final String mediaId;
  final String url;
}