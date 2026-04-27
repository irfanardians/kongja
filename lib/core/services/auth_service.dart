import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_session.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();

  static Future<void> registerUser(Map<String, dynamic> payload) async {
    final response = await ApiClient.postJson(
      '/register',
      body: payload,
      authorized: false,
    );

    if (response.statusCode == 200) {
      return;
    }

    throw AuthServiceException(
      _extractMessage(response, fallbackPrefix: 'Register gagal'),
    );
  }

  static Future<void> registerTalent({
    required Map<String, String> fields,
    required String identityDocumentPath,
    required String selfieVerificationPath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri('/talent/register'),
    );
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);
    request.files.add(
      await http.MultipartFile.fromPath(
        'identity_document',
        identityDocumentPath,
      ),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'selfie_verification',
        selfieVerificationPath,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw AuthServiceException(
      _extractMessage(response, fallbackPrefix: 'Register talent gagal'),
    );
  }

  static Future<LoginResult> loginUser({
    required String identifier,
    required String password,
  }) async {
    final response = await ApiClient.postJson(
      '/login',
      body: {'identifier': identifier, 'password': password},
      authorized: false,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final result = _parseLoginResult(response);
      AuthSession.instance.saveLogin(result);
      return result;
    }

    throw AuthServiceException(
      _extractMessage(response, fallbackPrefix: 'Login gagal'),
    );
  }

  static LoginResult _parseLoginResult(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          final role = data['role'];
          if (role is String && role.trim().isNotEmpty) {
            return LoginResult(
              role: role,
              accessToken: data['access_token'] as String?,
              refreshToken: data['refresh_token'] as String?,
              routeTargetDefault: data['route_target_default'] as String?,
            );
          }
        }
      }
    } catch (_) {
      throw const AuthServiceException(
        'Login berhasil tetapi respons backend tidak bisa dibaca.',
      );
    }

    throw const AuthServiceException(
      'Login berhasil tetapi role tidak ditemukan di respons backend.',
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

        final errors = decoded['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.join('\n');
        }
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          return errors.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join('\n');
        }
      }
    } catch (_) {
      return response.body;
    }

    return '$fallbackPrefix. Server mengembalikan status ${response.statusCode}.';
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LoginResult {
  const LoginResult({
    required this.role,
    this.accessToken,
    this.refreshToken,
    this.routeTargetDefault,
  });

  final String role;
  final String? accessToken;
  final String? refreshToken;
  final String? routeTargetDefault;
}
