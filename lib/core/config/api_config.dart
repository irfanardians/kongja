class ApiConfig {
  ApiConfig._();

//static const String baseUrl = 'http://localhost:3000/api/v1';
//static const String socketBaseUrl = 'http://localhost:3000';
static const String baseUrl = 'http://103.119.51.149:3001/api/v1';
static const String socketBaseUrl = 'http://103.119.51.149:3001';

  static Uri get publicBaseUri => Uri.parse(socketBaseUrl);

  static Uri uri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  static String resolveExternalUrl(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return '';
    }

    final parsed = Uri.tryParse(trimmedValue);
    if (parsed == null) {
      return '';
    }

    if (!parsed.hasScheme) {
      final normalizedPath = trimmedValue.startsWith('/')
          ? trimmedValue
          : '/$trimmedValue';
      return publicBaseUri.resolve(normalizedPath).toString();
    }

    final normalizedHost = parsed.host.trim().toLowerCase();
    if (normalizedHost == 'localhost' || normalizedHost == '127.0.0.1') {
      return publicBaseUri
          .replace(
            path: parsed.path,
            query: parsed.hasQuery ? parsed.query : null,
            fragment: parsed.hasFragment ? parsed.fragment : null,
          )
          .toString();
    }

    return parsed.toString();
  }
}
