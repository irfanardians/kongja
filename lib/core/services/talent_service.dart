import 'api_client.dart';

class TalentService {
  TalentService._();

  static const Duration _defaultCacheMaxAge = Duration(minutes: 5);

  static List<Map<String, dynamic>> peekCachedTalents() {
    final decoded = ApiClient.peekCachedJson(
      '/talents',
      queryParameters: const {'get_all': true},
      maxAge: _defaultCacheMaxAge,
    );

    return _extractTalentList(decoded);
  }

  static Future<List<Map<String, dynamic>>> getAllTalents({
    bool forceRefresh = false,
  }) async {
    final decoded = await ApiClient.getJson(
      '/talents',
      queryParameters: const {'get_all': true},
      useCache: true,
      forceRefresh: forceRefresh,
      maxAge: _defaultCacheMaxAge,
    );

    return _extractTalentList(decoded);
  }

  static List<Map<String, dynamic>> _extractTalentList(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
    }

    return const [];
  }
}
