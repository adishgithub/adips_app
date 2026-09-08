import 'package:get_storage/get_storage.dart';

/// Thin wrapper around GetStorage for persisting simple values
/// like the auth token across app restarts.
class AdipsLocalStorage {
  static final GetStorage _storage = GetStorage();

  static const String _tokenKey = 'auth_token';
  static const String _nameKey = 'cached_full_name';
  static const String _emailKey = 'cached_email';

  static Future<void> saveToken(String token) => _storage.write(_tokenKey, token);

  static String? get token => _storage.read<String>(_tokenKey);

  static Future<void> clearToken() => _storage.remove(_tokenKey);

  /// Last-known user info, saved on every successful login/validate.
  /// Lets the app open straight to Home on a cold-start/timeout instead
  /// of blocking on the network or forcing a re-login.
  static Future<void> saveCachedUser(String fullName, String email) async {
    await _storage.write(_nameKey, fullName);
    await _storage.write(_emailKey, email);
  }

  static String? get cachedFullName => _storage.read<String>(_nameKey);
  static String? get cachedEmail => _storage.read<String>(_emailKey);
}