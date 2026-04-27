class ApiCacheStore {
  ApiCacheStore._();

  static final ApiCacheStore instance = ApiCacheStore._();

  final Map<String, _ApiCacheEntry> _entries = {};

  T? read<T>(String key, {Duration? maxAge}) {
    final entry = _entries[key];
    if (entry == null) {
      return null;
    }

    if (maxAge != null && DateTime.now().difference(entry.savedAt) > maxAge) {
      _entries.remove(key);
      return null;
    }

    final value = entry.value;
    if (value is T) {
      return value;
    }

    return null;
  }

  void write(String key, Object? value) {
    _entries[key] = _ApiCacheEntry(value: value, savedAt: DateTime.now());
  }

  void remove(String key) {
    _entries.remove(key);
  }

  void clear() {
    _entries.clear();
  }
}

class _ApiCacheEntry {
  const _ApiCacheEntry({required this.value, required this.savedAt});

  final Object? value;
  final DateTime savedAt;
}
