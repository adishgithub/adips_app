// data/services/transfer_service.dart
import 'package:adips/utils/constants/api_constants.dart';
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/models/transfer_model.dart';

/// Talks to /api/v1/transfers.
///
/// A transfer moves money between two of the user's own accounts and
/// is stored as two linked transactions. Errors are thrown as
/// [ApiException] with a user-readable message (400: same account,
/// currency mismatch, archived account; 404: unknown account/transfer)
/// — screens should show it as-is.
///
/// Overdraft is allowed (X8): the server does not reject an amount
/// above the source balance.
class TransferService {
  /// POST /transfers. The currency comes from the accounts (both must
  /// match, X3), so it is not sent. [transactionDate] defaults to now
  /// server-side when omitted.
  Future<TransferModel> create({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    DateTime? transactionDate,
    String note = '',
  }) async {
    final response = await AdipsHttpHelper.post(
      AdipsApiConstants.transfers,
      {
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'amount': amount,
        if (transactionDate != null)
          'transaction_date': transactionDate.toUtc().toIso8601String(),
        'note': note,
      },
      cookie: AdipsHttpHelper.authCookie,
    );
    return TransferModel.fromJson(AdipsHttpHelper.data(response));
  }

  /// GET /transfers/:group_id
  Future<TransferModel> get(String groupId) async {
    final response = await AdipsHttpHelper.get(
      AdipsApiConstants.transfer(groupId),
      cookie: AdipsHttpHelper.authCookie,
    );
    return TransferModel.fromJson(AdipsHttpHelper.data(response));
  }

  /// PATCH /transfers/:group_id — only non-null fields are sent
  /// (backend pointer fields); both legs change together (X6).
  Future<TransferModel> update(
    String groupId, {
    int? fromAccountId,
    int? toAccountId,
    double? amount,
    DateTime? transactionDate,
    String? note,
  }) async {
    final body = <String, dynamic>{
      if (fromAccountId != null) 'from_account_id': fromAccountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (amount != null) 'amount': amount,
      if (transactionDate != null)
        'transaction_date': transactionDate.toUtc().toIso8601String(),
      if (note != null) 'note': note,
    };
    final response = await AdipsHttpHelper.patch(
      AdipsApiConstants.transfer(groupId),
      body,
      cookie: AdipsHttpHelper.authCookie,
    );
    return TransferModel.fromJson(AdipsHttpHelper.data(response));
  }

  /// DELETE /transfers/:group_id — removes both legs; both balances
  /// go back to what they were.
  Future<void> delete(String groupId) async {
    await AdipsHttpHelper.delete(
      AdipsApiConstants.transfer(groupId),
      cookie: AdipsHttpHelper.authCookie,
    );
  }
}
