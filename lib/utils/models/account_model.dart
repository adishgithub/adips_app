// utils/models/account_model.dart
//
// Mirrors adips_backend's dto.AccountResponse and
// dto.AccountSummaryResponse. Parsing is tolerant (same style as
// AppTransaction) so a missing/odd field never crashes a screen.

import 'app_transaction.dart';

/// One of the user's accounts (cash, bank, savings...).
///
/// [currentBalance] is computed by the backend (opening balance +
/// completed transactions up to now). The app never calculates it.
class AccountModel {
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.openingBalance,
    required this.currentBalance,
    required this.iconId,
    required this.colorId,
    required this.sortOrder,
    required this.isDefault,
    required this.includeInTotal,
    required this.isArchived,
  });

  final int id;
  final String name;

  /// cash | bank | savings | business | wallet | other
  /// (see [AccountTypeInfo]).
  final String type;

  /// 3-letter code, e.g. "INR". Cannot change once the account has
  /// transactions (rule A3).
  final String currency;
  final double openingBalance;
  final double currentBalance;
  final int iconId;
  final int colorId;
  final int sortOrder;
  final bool isDefault;

  /// false = still listed, but not counted in the dashboard total (A13).
  final bool includeInTotal;
  final bool isArchived;

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'other').toString(),
      currency: (json['currency'] ?? 'INR').toString(),
      openingBalance: _asDouble(json['opening_balance']),
      currentBalance: _asDouble(json['current_balance']),
      iconId: _asInt(json['icon_id']),
      colorId: _asInt(json['color_id']),
      sortOrder: _asInt(json['sort_order']),
      isDefault: json['is_default'] as bool? ?? false,
      includeInTotal: json['include_in_total'] as bool? ?? true,
      isArchived: json['is_archived'] as bool? ?? false,
    );
  }

  AccountModel copyWith({
    String? name,
    String? type,
    String? currency,
    double? openingBalance,
    double? currentBalance,
    int? iconId,
    int? colorId,
    int? sortOrder,
    bool? isDefault,
    bool? includeInTotal,
    bool? isArchived,
  }) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      iconId: iconId ?? this.iconId,
      colorId: colorId ?? this.colorId,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      includeInTotal: includeInTotal ?? this.includeInTotal,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

/// Mirrors dto.AccountSummaryResponse (GET /accounts/summary).
/// Only active accounts are returned; [totals] only counts accounts
/// with include_in_total = true, grouped by currency (D7) — never
/// add different currencies together in the app.
class AccountSummaryModel {
  const AccountSummaryModel({required this.totals, required this.accounts});

  final List<AccountSummaryTotal> totals;
  final List<AccountSummaryItem> accounts;

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    final totals = (json['totals'] as List<dynamic>? ?? [])
        .map((e) => AccountSummaryTotal.fromJson(e as Map<String, dynamic>))
        .toList();
    final accounts = (json['accounts'] as List<dynamic>? ?? [])
        .map((e) => AccountSummaryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return AccountSummaryModel(totals: totals, accounts: accounts);
  }

  static const empty = AccountSummaryModel(totals: [], accounts: []);
}

class AccountSummaryTotal {
  const AccountSummaryTotal({required this.currency, required this.totalBalance});

  final String currency;
  final double totalBalance;

  factory AccountSummaryTotal.fromJson(Map<String, dynamic> json) {
    return AccountSummaryTotal(
      currency: (json['currency'] ?? 'INR').toString(),
      totalBalance: _asDouble(json['total_balance']),
    );
  }
}

/// Slim account row used by the dashboard (no icon/color: the backend
/// summary doesn't send them, so join with [AccountModel] by id).
class AccountSummaryItem {
  const AccountSummaryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.currentBalance,
    required this.includeInTotal,
  });

  final int id;
  final String name;
  final String type;
  final double currentBalance;
  final bool includeInTotal;

  factory AccountSummaryItem.fromJson(Map<String, dynamic> json) {
    return AccountSummaryItem(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'other').toString(),
      currentBalance: _asDouble(json['current_balance']),
      includeInTotal: json['include_in_total'] as bool? ?? true,
    );
  }
}

/// Mirrors dto.DeletePreviewResponse (GET /accounts/:id/delete-preview):
/// what a merge-delete WOULD do, without changing anything.
///
/// [movedTransactionCount] rows are re-pointed to the target and kept.
/// Transfers between source and target ([collapsedTransferCount]) net
/// to zero, so they disappear instead of moving. No money is created or
/// lost: [targetBalanceAfter] == [targetBalanceBefore] +
/// [sourceCurrentBalance].
class AccountDeletePreview {
  const AccountDeletePreview({
    required this.movedTransactionCount,
    required this.collapsedTransferCount,
    required this.sourceCurrentBalance,
    required this.targetBalanceBefore,
    required this.targetBalanceAfter,
  });

  final int movedTransactionCount;
  final int collapsedTransferCount;
  final double sourceCurrentBalance;
  final double targetBalanceBefore;
  final double targetBalanceAfter;

  factory AccountDeletePreview.fromJson(Map<String, dynamic> json) {
    return AccountDeletePreview(
      movedTransactionCount: _asInt(json['moved_transaction_count']),
      collapsedTransferCount: _asInt(json['collapsed_transfer_count']),
      sourceCurrentBalance: _asDouble(json['source_current_balance']),
      targetBalanceBefore: _asDouble(json['target_balance_before']),
      targetBalanceAfter: _asDouble(json['target_balance_after']),
    );
  }
}

/// Mirrors dto.AdjustAccountResponse (POST /accounts/:id/adjust).
///
/// [difference] is actual - calculated balance: positive = a credit was
/// recorded, negative = a debit. 0 means the balance already matched
/// and nothing was written ([adjustment] is null then).
class AccountAdjustResult {
  const AccountAdjustResult({
    required this.account,
    required this.difference,
    this.adjustment,
  });

  final AccountModel account;
  final double difference;

  /// The "Balance Adjustment" transaction, when one was created.
  final AppTransaction? adjustment;

  bool get changed => adjustment != null;

  factory AccountAdjustResult.fromJson(Map<String, dynamic> json) {
    final adj = json['adjustment'];
    return AccountAdjustResult(
      account: AccountModel.fromJson(
          (json['account'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
      difference: _asDouble(json['difference']),
      adjustment: adj is Map<String, dynamic> ? AppTransaction.fromJson(adj) : null,
    );
  }
}

/// The fixed list of account types the backend accepts
/// (binding: oneof=cash bank savings business wallet other), with a
/// label and a suggested default icon for the create form. Icon ids
/// refer to AdipsIcons (append-only): 4 wallet, 7 bank, 5 savings,
/// 19 briefcase, 9 payments.
class AccountTypeInfo {
  const AccountTypeInfo(this.value, this.label, this.defaultIconId);

  final String value;
  final String label;
  final int defaultIconId;

  static const List<AccountTypeInfo> all = [
    AccountTypeInfo('cash', 'Cash', 4),
    AccountTypeInfo('bank', 'Bank', 7),
    AccountTypeInfo('savings', 'Savings', 5),
    AccountTypeInfo('business', 'Business', 19),
    AccountTypeInfo('wallet', 'Wallet', 4),
    AccountTypeInfo('other', 'Other', 9),
  ];

  /// Falls back to "Other" for any value the app doesn't know yet.
  static AccountTypeInfo of(String value) => all.firstWhere(
        (t) => t.value == value,
    orElse: () => all.last,
  );
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0.0;
}