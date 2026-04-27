import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../services/api_cache_store.dart';

class AuthSession {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _roleKey = 'auth.role';
  static const _routeTargetDefaultKey = 'auth.route_target_default';

  String? _accessToken;
  String? _refreshToken;
  String? _role;
  String? _routeTargetDefault;
  Completer<bool>? _refreshCompleter;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get role => _role;
  String? get routeTargetDefault => _routeTargetDefault;
  bool get isAuthenticated =>
      _accessToken != null && _accessToken!.trim().isNotEmpty;
    bool get canRefresh =>
      _refreshToken != null && _refreshToken!.trim().isNotEmpty;
  String get launchRoute {
    if (!isAuthenticated) {
      return '/login';
    }

    final targetRoute = _routeTargetDefault?.trim();
    if (targetRoute != null && targetRoute.isNotEmpty) {
      return targetRoute;
    }

    switch (_role?.trim().toLowerCase()) {
      case 'talent':
        return '/talent-home';
      case 'user':
        return '/home';
      default:
        return '/login';
    }
  }

  Future<void> restore() async {
    final preferences = await SharedPreferences.getInstance();
    _accessToken = preferences.getString(_accessTokenKey);
    _refreshToken = preferences.getString(_refreshTokenKey);
    _role = preferences.getString(_roleKey);
    _routeTargetDefault = preferences.getString(_routeTargetDefaultKey);
  }

  void saveLogin(LoginResult result) {
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    _role = result.role;
    _routeTargetDefault = result.routeTargetDefault;
    ApiCacheStore.instance.clear();
    unawaited(_persist());
  }

  void clear() {
    _accessToken = null;
    _refreshToken = null;
    _role = null;
    _routeTargetDefault = null;
    ApiCacheStore.instance.clear();
    unawaited(_clearPersisted());
  }

  Map<String, String> authorizationHeaders({Map<String, String>? headers}) {
    final mergedHeaders = <String, String>{
      'Accept': 'application/json',
      ...?headers,
    };

    final token = _accessToken;
    if (token != null && token.trim().isNotEmpty) {
      mergedHeaders['Authorization'] = 'Bearer $token';
    }

    return mergedHeaders;
  }

  Future<bool> refreshSession() async {
    final activeRefresh = _refreshCompleter;
    if (activeRefresh != null) {
      return activeRefresh.future;
    }

    if (!canRefresh) {
      return false;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refreshed = await _performRefresh();
      completer.complete(refreshed);
      return refreshed;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<bool> _performRefresh() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      return false;
    }

    final response = await _postRefreshRequest(refreshToken);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }

    final updatedSession = _parseRefreshResponse(response.body);
    if (updatedSession == null) {
      return false;
    }

    _accessToken = updatedSession.accessToken;
    _refreshToken = updatedSession.refreshToken ?? _refreshToken;
    _role = updatedSession.role ?? _role;
    _routeTargetDefault =
        updatedSession.routeTargetDefault ?? _routeTargetDefault;
    ApiCacheStore.instance.clear();
    await _persist();
    return true;
  }

  Future<http.Response> _postRefreshRequest(String refreshToken) async {
    final candidatePaths = <String>['/auth/refresh', '/refresh'];
    http.Response? lastResponse;

    for (final path in candidatePaths) {
      final response = await http.post(
        ApiConfig.uri(path),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode != 404) {
        return response;
      }
      lastResponse = response;
    }

    return lastResponse ??
        http.Response(
          '',
          404,
          request: http.Request('POST', ApiConfig.uri('/refresh')),
        );
  }

  _RefreshSessionResult? _parseRefreshResponse(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final data = decoded['data'] is Map<String, dynamic>
        ? decoded['data'] as Map<String, dynamic>
        : decoded;

    final accessToken = _stringValue(data['access_token']);
    if (accessToken.isEmpty) {
      return null;
    }

    return _RefreshSessionResult(
      accessToken: accessToken,
      refreshToken: _stringValue(data['refresh_token']),
      role: _stringValue(data['role']),
      routeTargetDefault: _stringValue(data['route_target_default']),
    );
  }

  String _stringValue(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return '';
  }

  Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenKey, _accessToken ?? '');
    await preferences.setString(_refreshTokenKey, _refreshToken ?? '');
    await preferences.setString(_roleKey, _role ?? '');
    await preferences.setString(
      _routeTargetDefaultKey,
      _routeTargetDefault ?? '',
    );
  }

  Future<void> _clearPersisted() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_roleKey);
    await preferences.remove(_routeTargetDefaultKey);
  }
}

class _RefreshSessionResult {
  const _RefreshSessionResult({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.routeTargetDefault,
  });

  final String accessToken;
  final String? refreshToken;
  final String? role;
  final String? routeTargetDefault;
}
