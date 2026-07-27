// utils/services/transaction_api.dart
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/local_storage/storage_utility.dart';
import 'package:adips/utils/models/app_transaction.dart';

/// Thin repository around AdipsHttpHelper for everything under
/// /api/v1/transactions. Every call automatically attaches the saved
/// auth token as the `Authorization` cookie the backend middleware
/// expects (see internal/middleware/auth.go) — callers never need to
/// touch AdipsLocalStorage themselves.
class TransactionApi {
  static String? get _cookie {
    final token = AdipsLocalStorage.token;
    return token != null ? 'Authorization=$token' : null;
  }

  /// GET /api/v1/transactions
  /// A generous [limit] is used by default so the home screen can do
  /// its own client-side search/sort/date-range filtering over
  /// "recent" transactions without paging through the API for a
  /// typical personal-finance-sized dataset.
  static Future<List<AppTransaction>> list({
    int page = 1,
    int limit = 200,
    String? sortBy,
    String? order,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (sortBy != null) 'sort_by': sortBy,
      if (order != null) 'order': order,
    };
    final uri = Uri(path: '/api/v1/transactions', queryParameters: query);

    final response = await AdipsHttpHelper.get(
      uri.toString(),
      cookie: _cookie,
    );

    return AdipsHttpHelper.listData(response)
        .map((e) => AppTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/transactions/summary
  static Future<TransactionSummary> summary() async {
    final response = await AdipsHttpHelper.get(
      '/api/v1/transactions/summary',
      cookie: _cookie,
    );
    return TransactionSummary.fromJson(AdipsHttpHelper.data(response));
  }

  /// POST /api/v1/transactions
  static Future<AppTransaction> create({
    required double amount,
    required String type,
    required String category,
    required String description,
    required String status,
    required String paymentMethod,
    String note = '',
    String currency = 'INR',
  }) async {
    final response = await AdipsHttpHelper.post(
      '/api/v1/transactions',
      {
        'amount': amount,
        'type': type,
        'category': category,
        'description': description,
        'status': status,
        'payment_method': paymentMethod,
        'note': note,
        'currency': currency,
      },
      cookie: _cookie,
    );
    return AppTransaction.fromJson(AdipsHttpHelper.data(response));
  }

  /// PATCH /api/v1/transactions/:id
  /// Only non-null fields are sent, matching the backend's partial
  /// UpdateTransactionRequest (pointer fields — omitted keys are left
  /// untouched server-side).
  static Future<AppTransaction> update(
    int id, {
    double? amount,
    String? type,
    String? category,
    String? description,
    String? status,
    String? paymentMethod,
    String? note,
    String? currency,
  }) async {
    final body = <String, dynamic>{
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (note != null) 'note': note,
      if (currency != null) 'currency': currency,
    };

    final response = await AdipsHttpHelper.patch(
      '/api/v1/transactions/$id',
      body,
      cookie: _cookie,
    );
    return AppTransaction.fromJson(AdipsHttpHelper.data(response));
  }

  /// DELETE /api/v1/transactions/:id
  static Future<void> delete(int id) async {
    await AdipsHttpHelper.delete(
      '/api/v1/transactions/$id',
      cookie: _cookie,
    );
  }
}
