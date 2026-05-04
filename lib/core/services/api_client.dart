import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_session.dart';
import '../config/api_config.dart';
import 'api_cache_store.dart';

class ApiClient {
  ApiClient._();

  static Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool authorized = true,
  }) {
    final uri = ApiConfig.uri(path, queryParameters: queryParameters);
    return _sendWithAuthRetry(
      authorized: authorized,
      headers: headers,
      send: (resolvedHeaders) => http.get(uri, headers: resolvedHeaders),
    );
  }

  static Future<dynamic> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool authorized = true,
    bool useCache = false,
    bool forceRefresh = false,
    Duration? maxAge,
  }) async {
    final cacheKey = _buildCacheKey(path, queryParameters: queryParameters);

    if (useCache && !forceRefresh) {
      final cached = ApiCacheStore.instance.read<dynamic>(
        cacheKey,
        maxAge: maxAge,
      );
      if (cached != null) {
        return cached;
      }
    }

    final response = await get(
      path,
      queryParameters: queryParameters,
      headers: headers,
      authorized: authorized,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiClientException(
        'Request gagal. Server mengembalikan status ${response.statusCode}.',
      );
    }

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (useCache) {
      ApiCacheStore.instance.write(cacheKey, decoded);
    }

    return decoded;
  }

  static dynamic peekCachedJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Duration? maxAge,
  }) {
    return ApiCacheStore.instance.read<dynamic>(
      _buildCacheKey(path, queryParameters: queryParameters),
      maxAge: maxAge,
    );
  }

  static void clearCache() {
    ApiCacheStore.instance.clear();
  }

  static void invalidateCache(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    ApiCacheStore.instance.remove(
      _buildCacheKey(path, queryParameters: queryParameters),
    );
  }

  static Future<http.Response> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool authorized = false,
  }) {
    final uri = ApiConfig.uri(path, queryParameters: queryParameters);
    final encodedBody = body == null ? null : jsonEncode(body);
    return _sendWithAuthRetry(
      authorized: authorized,
      headers: headers,
      includeJsonContentType: true,
      send: (resolvedHeaders) => http.post(
        uri,
        headers: resolvedHeaders,
        body: encodedBody,
      ),
    );
  }

  static Future<http.Response> patchJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool authorized = false,
  }) {
    final uri = ApiConfig.uri(path, queryParameters: queryParameters);
    final encodedBody = body == null ? null : jsonEncode(body);
    return _sendWithAuthRetry(
      authorized: authorized,
      headers: headers,
      includeJsonContentType: true,
      send: (resolvedHeaders) => http.patch(
        uri,
        headers: resolvedHeaders,
        body: encodedBody,
      ),
    );
  }

  static Future<http.Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool authorized = true,
  }) {
    final uri = ApiConfig.uri(path, queryParameters: queryParameters);
    return _sendWithAuthRetry(
      authorized: authorized,
      headers: headers,
      send: (resolvedHeaders) => http.delete(uri, headers: resolvedHeaders),
    );
  }

  static Future<http.Response> postMultipart(
    String path, {
    required String fileField,
    required String filePath,
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, String>? headers,
    bool authorized = true,
  }) async {
    return _sendWithAuthRetry(
      authorized: authorized,
      headers: headers,
      send: (resolvedHeaders) async {
        final request = http.MultipartRequest(method, ApiConfig.uri(path));
        request.headers.addAll(resolvedHeaders);
        request.fields.addAll(fields ?? const {});
        request.files.add(
          await http.MultipartFile.fromPath(fileField, filePath),
        );

        final streamedResponse = await request.send();
        return http.Response.fromStream(streamedResponse);
      },
    );
  }

  static Future<http.Response> _sendWithAuthRetry({
    required Future<http.Response> Function(Map<String, String> headers) send,
    required bool authorized,
    Map<String, String>? headers,
    bool includeJsonContentType = false,
  }) async {
    final initialHeaders = _buildHeaders(
      headers: headers,
      authorized: authorized,
      includeJsonContentType: includeJsonContentType,
    );
    final initialResponse = await send(initialHeaders);

    if (!authorized || initialResponse.statusCode != 401) {
      return initialResponse;
    }

    final refreshed = await AuthSession.instance.refreshSession();
    if (!refreshed) {
      return initialResponse;
    }

    final retryHeaders = _buildHeaders(
      headers: headers,
      authorized: authorized,
      includeJsonContentType: includeJsonContentType,
    );
    return send(retryHeaders);
  }

  static Map<String, String> _buildHeaders({
    Map<String, String>? headers,
    required bool authorized,
    bool includeJsonContentType = false,
  }) {
    final mergedHeaders = <String, String>{
      if (includeJsonContentType) 'Content-Type': 'application/json',
      ...?headers,
    };

    if (!authorized) {
      return {'Accept': 'application/json', ...mergedHeaders};
    }

    return AuthSession.instance.authorizationHeaders(headers: mergedHeaders);
  }

  static String _buildCacheKey(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    final uri = ApiConfig.uri(path, queryParameters: queryParameters);
    final tokenKey = AuthSession.instance.accessToken ?? 'guest';
    return '$tokenKey::${uri.toString()}';
  }
}

class ApiClientException implements Exception {
  const ApiClientException(this.message);

  final String message;

  @override
  String toString() => message;
}
