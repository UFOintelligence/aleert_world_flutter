class AuthStorage {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static String get token {
    if (_token == null) throw Exception('Token no disponible');
    return _token!;
  }

  static void clear() {
    _token = null;
  }
}
