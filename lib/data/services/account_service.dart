// data/services/account_service.dart
import 'package:adips/utils/constants/api_constants.dart';
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/models/account_model.dart';

/// Talks to /api/v1/accounts.
///
/// Errors are thrown as [ApiException] (from AdipsHttpHelper) with a
/// user-readable message, e.g. 409 "An account with this name already
/// exists" (A2) — screens should show that message as-is.
///
/// Every accounts endpoint lives here: list/get/create/update/summary,
/// archive/unarchive, delete (+preview), reorder and adjust.
class AccountService {
  /// GET /accounts — active accounts ordered by sort_order, each with
  /// its computed current_balance. Pass [includeArchived] to also get
  /// archived ones (A12).
  Future<List<AccountModel>> list({bool includeArchived = false}) async {
    final query = includeArchived ? '?include_archived=true' : '';
    final response = await AdipsHttpHelper.get(
      '${AdipsApiConstants.accounts}$query',
      cookie: AdipsHttpHelper.authCookie,
    );
    return AdipsHttpHelper.list(response)
        .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /accounts/:id
  Future<AccountModel> get(int id) async {
    final response = await AdipsHttpHelper.get(
      AdipsApiConstants.account(id),
      cookie: AdipsHttpHelper.authCookie,
    );
    return AccountModel.fromJson(AdipsHttpHelper.data(response));
  }

  /// GET /accounts/summary — dashboard payload: totals per currency
  /// (only include_in_total accounts) plus the active accounts.
  Future<AccountSummaryModel> summary() async {
    final response = await AdipsHttpHelper.get(
      AdipsApiConstants.accountsSummary,
      cookie: AdipsHttpHelper.authCookie,
    );
    return AccountSummaryModel.fromJson(AdipsHttpHelper.data(response));
  }

  /// POST /accounts
  ///
  /// [openingBalance] must be >= 0 (A4). [iconId] 1..80 and [colorId]
  /// 1..8. [includeInTotal] defaults to true server-side when omitted.
  Future<AccountModel> create({
    required String name,
    required String type, // cash|bank|savings|business|wallet|other
    required String currency,
    required int iconId,
    required int colorId,
    double openingBalance = 0,
    bool includeInTotal = true,
    bool isDefault = false,
  }) async {
    final response = await AdipsHttpHelper.post(
      AdipsApiConstants.accounts,
      {
        'name': name,
        'type': type,
        'currency': currency,
        'opening_balance': openingBalance,
        'icon_id': iconId,
        'color_id': colorId,
        'include_in_total': includeInTotal,
        'is_default': isDefault,
      },
      cookie: AdipsHttpHelper.authCookie,
    );
    return AccountModel.fromJson(AdipsHttpHelper.data(response));
  }

  /// PATCH /accounts/:id/archive — hides the account, history stays.
  ///
  /// Refused with 409 (message is user-readable, show it as-is) when
  /// it is the default account (A6), the last active account (A7), or
  /// its balance isn't zero (A11). Archiving an archived account is a
  /// harmless no-op server-side.
  Future<AccountModel> archive(int id) async {
    final response = await AdipsHttpHelper.patch(
      AdipsApiConstants.accountArchive(id),
      <String, dynamic>{},
      cookie: AdipsHttpHelper.authCookie,
    );
    return AccountModel.fromJson(AdipsHttpHelper.data(response));
  }

  /// PATCH /accounts/:id/unarchive — always allowed (A11).
  Future<AccountModel> unarchive(int id) async {
    final response = await AdipsHttpHelper.patch(
      AdipsApiConstants.accountUnarchive(id),
      <String, dynamic>{},
      cookie: AdipsHttpHelper.authCookie,
    );
    return AccountModel.fromJson(AdipsHttpHelper.data(response));
  }

  /// GET /accounts/:id/delete-preview?move_to=<id> — read-only preview
  /// of a merge-delete (A10). Show it and get a confirmation before
  /// calling [delete] with the same target.
  ///
  /// Throws the server's message when the delete isn't allowed:
  /// default account (A6) or last active account (A7) = 409; target
  /// archived / other currency / same account = 400.
  Future<AccountDeletePreview> deletePreview(int id, {required int moveTo}) async {
    final response = await AdipsHttpHelper.get(
      '${AdipsApiConstants.accountDeletePreview(id)}?move_to=$moveTo',
      cookie: AdipsHttpHelper.authCookie,
    );
    return AccountDeletePreview.fromJson(AdipsHttpHelper.data(response));
  }

  /// DELETE /accounts/:id[?move_transactions_to=<id>]
  ///
  /// - No transactions: soft delete (A8).
  /// - Has transactions and no [moveTransactionsTo]: 409 (A9).
  /// - [moveTransactionsTo] given: merge-delete (A10) — the transactions
  ///   and the opening balance move to the target, transfers between the
  ///   two are removed. The target must be active and use the same
  ///   currency.
  /// - Default account (A6) and last active account (A7): 409.
  ///
  /// The response has no `data`, so nothing is returned.
  Future<void> delete(int id, {int? moveTransactionsTo}) async {
    final query =
        moveTransactionsTo != null ? '?move_transactions_to=$moveTransactionsTo' : '';
    await AdipsHttpHelper.delete(
      '${AdipsApiConstants.account(id)}$query',
      cookie: AdipsHttpHelper.authCookie,
    );
  }

  /// PATCH /accounts/reorder — [items] are {id, sort_order} pairs, applied
  /// by the backend in one DB transaction: one unknown id fails the whole
  /// batch (400), so nothing is half-saved. Answers 200 with no `data`.
  Future<void> reorder(List<Map<String, int>> items) async {
    await AdipsHttpHelper.patch(
      AdipsApiConstants.accountsReorder,
      {'items': items},
      cookie: AdipsHttpHelper.authCookie,
    );
  }

  /// POST /accounts/:id/adjust — "my real balance is [actualBalance]".
  ///
  /// The backend records ONE completed credit or debit ("Balance
  /// Adjustment", dated now) for the difference, or nothing if the
  /// balance is already right (difference 0). Negative balances are
  /// allowed. Archived accounts can't be adjusted (400).
  Future<AccountAdjustResult> adjust(
    int id, {
    required double actualBalance,
    String note = '',
  }) async {
    final response = await AdipsHttpHelper.post(
      AdipsApiConstants.accountAdjust(id),
      {'actual_balance': actualBalance, 'note': note},
      cookie: AdipsHttpHelper.authCookie,
    );
    return AccountAdjustResult.fromJson(AdipsHttpHelper.data(response));
  }

  /// PATCH /accounts/:id — only non-null fields are sent, matching the
  /// backend's pointer-field UpdateAccountRequest (omitted = untouched).
  ///
  /// Currency can't change once the account has transactions (A3): the
  /// server answers 409. Setting [isDefault] true clears the old
  /// default server-side (A5).
  Future<AccountModel> update(
      int id, {
        String? name,
        String? type,
        String? currency,
        double? openingBalance,
        int? iconId,
        int? colorId,
        int? sortOrder,
        bool? isDefault,
        bool? includeInTotal,
      }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (iconId != null) 'icon_id': iconId,
      if (colorId != null) 'color_id': colorId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isDefault != null) 'is_default': isDefault,
      if (includeInTotal != null) 'include_in_total': includeInTotal,
    };
    final response = await AdipsHttpHelper.patch(
      AdipsApiConstants.account(id),
      body,
      cookie: AdipsHttpHelper.authCookie,
    );
    return AccountModel.fromJson(AdipsHttpHelper.data(response));
  }
}