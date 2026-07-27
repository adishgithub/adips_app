// data/services/transaction_service.dart
import 'package:adips/utils/constants/api_constants.dart';
import 'package:adips/utils/http/http_client.dart';

/// Talks to /api/v1/transactions. Only Create is needed for the Add
/// Transaction sheet right now — List/Update/Delete can be added here
/// the same way once the home screen talks to the real API.
class TransactionService {
  Future<Map<String, dynamic>> create({
    required double amount,
    required String type, // 'credit' | 'debit'
    required String category,
    required String description,
    required String status, // 'pending' | 'completed' | 'failed'
    required String paymentMethod,
    String note = '',
    String currency = 'INR',
  }) async {
    final response = await AdipsHttpHelper.post(
      AdipsApiConstants.transactions,
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
      cookie: AdipsHttpHelper.authCookie,
    );
    return AdipsHttpHelper.data(response);
  }
}
