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
/// Only list/get/create/update/summary live here for now; archive,
/// delete, reorder and adjust are added in Phase 3.
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