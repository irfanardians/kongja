import 'api_client.dart';

class UserWalletService {
  UserWalletService._();

  static const Duration _cacheMaxAge = Duration(minutes: 2);

  static Future<int> getAvailableCoinBalance({
    bool forceRefresh = false,
  }) async {
    final decoded = await ApiClient.getJson(
      '/wallets/user',
      useCache: true,
      forceRefresh: forceRefresh,
      maxAge: _cacheMaxAge,
    );

    return _extractAvailableCoinBalance(decoded);
  }

  static int? peekCachedAvailableCoinBalance() {
    final decoded = ApiClient.peekCachedJson(
      '/wallets/user',
      maxAge: _cacheMaxAge,
    );

    if (decoded == null) {
      return null;
    }

    return _extractAvailableCoinBalance(decoded);
  }

  static int _extractAvailableCoinBalance(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final nestedData = decoded['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedBalance = _intValue(nestedData['available_coin_balance']);
        if (nestedBalance >= 0) {
          return nestedBalance;
        }
      }

      final rootBalance = _intValue(decoded['available_coin_balance']);
      if (rootBalance >= 0) {
        return rootBalance;
      }
    }

    return 0;
  }

  static int _intValue(dynamic value) {
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
}