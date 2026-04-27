class ApiConfig {
  ApiConfig._();

//  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const String baseUrl = 'http://103.119.51.149:3001/api/v1';
  static Uri uri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
