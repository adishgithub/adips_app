import 'dart:convert';
import 'package:http/http.dart' as http;

import '../local_storage/storage_utility.dart';

/// Thin wrapper around the `http` package.
/// Every screen/controller should go through this instead of calling
/// `http.get` / `http.post` directly, so headers, base URL, and error
/// handling stay in one place.
///
/// Backend routes are versioned under `/api/v1` (e.g. pass
/// '/api/v1/users/login', not '/login').
///
/// Every response body follows the same envelope:
///   { "success": bool, "message": string, "data": <payload>, "error"?: any }
/// `_handleResponse` returns the decoded top-level map as-is (still
/// containing "data"/"message"/etc) — call `AdipsHttpHelper.data(response)`
/// to unwrap the actual payload instead of reaching into `response['data']`
/// at every call site.
///
/// Note: the adips_backend auth middleware reads the token from a
/// `Authorization` COOKIE, not a Bearer header. Since a Flutter app
/// doesn't have a browser-style cookie jar, we pass the token back
/// manually via the `cookie` param on authenticated requests.
class AdipsHttpHelper {
  static const String _baseUrl = 'https://adips-backend.onrender.com';

  /// The saved auth token, pre-formatted as the `Authorization=<token>`
  /// cookie value every authenticated call needs to pass as `cookie:`.
  /// Null when there's no saved token (not logged in).
  static String? get authCookie {
    final token = AdipsLocalStorage.token;
    return token != null ? 'Authorization=$token' : null;
  }

  static Map<String, String> _headers({String? cookie}) => {
    'Content-Type': 'application/json',
    if (cookie != null) 'Cookie': cookie,
  };

  static Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> body, {
        String? cookie,
      }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await http
          .post(url, headers: _headers(cookie: cookie), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Could not reach the server. Check your connection.');
    }
  }

  static Future<Map<String, dynamic>> get(
      String endpoint, {
        String? cookie,
      }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await http
          .get(url, headers: _headers(cookie: cookie))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Could not reach the server. Check your connection.');
    }
  }

  static Future<Map<String, dynamic>> put(
      String endpoint,
      Map<String, dynamic> body, {
        String? cookie,
      }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await http
          .put(url, headers: _headers(cookie: cookie), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Could not reach the server. Check your connection.');
    }
  }

  static Future<Map<String, dynamic>> patch(
      String endpoint,
      Map<String, dynamic> body, {
        String? cookie,
      }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await http
          .patch(url, headers: _headers(cookie: cookie), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Could not reach the server. Check your connection.');
    }
  }

  static Future<Map<String, dynamic>> delete(
      String endpoint, {
        String? cookie,
      }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await http
          .delete(url, headers: _headers(cookie: cookie))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Could not reach the server. Check your connection.');
    }
  }

  /// Unwraps the `data` field from a decoded response envelope.
  /// Every 2xx response from the backend is shaped like
  /// `{"success":true,"message":"...","data": <payload>}` — call
  /// sites should read the payload via this helper instead of
  /// reaching into `response['data']` directly everywhere.
  static Map<String, dynamic> data(Map<String, dynamic> response) {
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Same as [data] but for endpoints whose `data` field is a JSON
  /// array (e.g. GET /transactions) rather than an object.
  static List<dynamic> listData(Map<String, dynamic> response) {
    return response['data'] as List<dynamic>? ?? [];
  }

  /// Alias for [listData] — some services call this one, some call
  /// that one; both do the same thing.
  static List<dynamic> list(Map<String, dynamic> response) => listData(response);

  /// Unwraps the `meta` field (pagination info) from a decoded
  /// response envelope.
  static Map<String, dynamic> meta(Map<String, dynamic> response) {
    return response['meta'] as Map<String, dynamic>? ?? {};
  }

  /// Parses the response and throws a readable Exception on any
  /// non-2xx status, so callers can just try/catch a single Exception type.
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final dynamic decoded =
    response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    }

    final String message = (decoded is Map && decoded['message'] != null)
        ? decoded['message'].toString()
        : 'Something went wrong (${response.statusCode})';
    throw Exception(message);
  }
}