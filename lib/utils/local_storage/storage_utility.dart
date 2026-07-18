import 'package:get_storage/get_storage.dart';

/// Thin wrapper around GetStorage for persisting simple values
/// like the auth token across app restarts.
class AdipsLocalStorage {
  static final GetStorage _storage = GetStorage();

  static const String _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) => _storage.write(_tokenKey, token);

  static String? get token => _storage.read<String>(_tokenKey);

  static Future<void> clearToken() => _storage.remove(_tokenKey);
}