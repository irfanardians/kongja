import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'auth_service.dart';

class UserProfileService {
  UserProfileService._();

  static const Duration _cacheMaxAge = Duration(minutes: 5);

  static Future<UserProfileData> getMyProfile({
    bool forceRefresh = false,
  }) async {
    final decoded = await ApiClient.getJson(
      '/me',
      useCache: true,
      forceRefresh: forceRefresh,
      maxAge: _cacheMaxAge,
    );

    return _parseProfile(decoded);
  }
  
  static UserProfileData? peekCachedMyProfile() {
    final decoded = ApiClient.peekCachedJson('/me', maxAge: _cacheMaxAge);
    if (decoded == null) {
      return null;
    }
  
    try {
      return _parseProfile(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<UserProfileData> uploadAvatar(String filePath) async {
    final response = await ApiClient.postMultipart(
      '/me/profile/avatar',
      fileField: 'avatar',
      filePath: filePath,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(response, fallbackPrefix: 'Upload foto profil gagal'),
      );
    }

    ApiClient.invalidateCache('/me');
    return getMyProfile(forceRefresh: true);
  }

  static Future<UserProfileData> updateBasicSettings({
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
      '/setting/user/basic',
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
        _extractMessage(response, fallbackPrefix: 'Simpan pengaturan user gagal'),
      );
    }

    ApiClient.invalidateCache('/me');
    return getMyProfile(forceRefresh: true);
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await ApiClient.postJson(
      '/setting/user/changepassword',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      authorized: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        _extractMessage(response, fallbackPrefix: 'Ubah password user gagal'),
      );
    }
  }

  static UserProfileData _parseProfile(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final displayName = _firstNonEmpty([
          data['display_name'],
          data['call_name'],
          data['first_name'],
        ], fallback: 'User');

        final avatarUrl = _firstNonEmpty([
          data['avatar_url'],
          if (data['profile_summary'] is Map<String, dynamic>)
            (data['profile_summary'] as Map<String, dynamic>)['avatar_url'],
        ]);

        final city = _stringValue(data['city']);
        final country = _stringValue(data['country']);

        return UserProfileData(
          displayName: displayName,
          avatarUrl: avatarUrl,
          callName: _firstNonEmpty([
            data['call_name'],
            data['display_name'],
            data['first_name'],
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
          city: city,
          country: country,
          postcode: _stringValue(data['postcode']),
          locationLabel: [
            city,
            country,
          ].where((value) => value.isNotEmpty).join(', '),
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
          role: _stringValue(data['role']),
        );
      }
    }

    throw const AuthServiceException(
      'Data profil user tidak ditemukan di respons backend.',
    );
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

  static String _firstNonEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final stringValue = _stringValue(value);
      if (stringValue.isNotEmpty) {
        return stringValue;
      }
    }
    return fallback;
  }
}

class UserProfileData {
  const UserProfileData({
    required this.displayName,
    required this.avatarUrl,
    required this.callName,
    required this.email,
    required this.phoneCountryCode,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.postcode,
    required this.locationLabel,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.level,
    required this.role,
  });

  final String displayName;
  final String avatarUrl;
  final String callName;
  final String email;
  final String phoneCountryCode;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String postcode;
  final String locationLabel;
  final String firstName;
  final String lastName;
  final String gender;
  final String dateOfBirth;
  final String level;
  final String role;
}
