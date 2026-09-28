// utils/models/app_transaction.dart
//
// Mirrors internal/dto.TransactionResponse from adips_backend exactly
// (field names/types), so parsing is a straight json['field'] read
// with no guessing at what the server sends.
class AppTransaction {
  const AppTransaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.accountName,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryIconId,
    required this.categoryColorId,
    required this.description,
    required this.status,
    required this.paymentMethod,
    required this.transactionDate,
    required this.note,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.transferGroupId,
  });

  final int id;
  final int userId;

  /// The account this transaction belongs to (required by the backend
  /// on create, rule T1). [accountName] is resolved server-side so
  /// renaming an account shows everywhere (D6).
  final int accountId;
  final String accountName;
  final double amount;

  /// Always "credit" or "debit" — matches the backend's
  /// TransactionDirection enum.
  final String type;
  final String category;

  /// Snapshot of the category's icon/color *at the time this
  /// transaction was created* (see adips_backend's
  /// Transaction.CategoryIconID/CategoryColorID) — used to render the
  /// exact icon the user picked in the category dropdown, instead of
  /// guessing one from the category name. 0 on older rows created
  /// before this field existed; callers should fall back to
  /// CategoryStyle in that case.
  final int categoryIconId;
  final int categoryColorId;
  final String description;

  /// "pending" | "completed" | "failed"
  final String status;
  final String paymentMethod;
  final DateTime transactionDate;
  final String note;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Non-null only on the two legs of a transfer (both legs share the
  /// same id). Such rows can't be edited/deleted via /transactions
  /// (T4) — use /transfers instead.
  final String? transferGroupId;

  bool get isCredit => type == 'credit';
  bool get isTransfer => transferGroupId != null;

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      accountId: _asInt(json['account_id']),
      accountName: (json['account_name'] ?? '').toString(),
      amount: _asDouble(json['amount']),
      type: (json['type'] ?? 'debit').toString(),
      category: (json['category'] ?? '').toString(),
      categoryIconId: _asInt(json['category_icon_id']),
      categoryColorId: _asInt(json['category_color_id']),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'completed').toString(),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      transactionDate: _asDate(json['transaction_date']),
      note: (json['note'] ?? '').toString(),
      currency: (json['currency'] ?? 'INR').toString(),
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
      transferGroupId: _asNullableString(json['transfer_group_id']),
    );
  }

  /// Simple case-insensitive match over description/category, used
  /// by the search bar.
  bool matchesQuery(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return true;
    return description.toLowerCase().contains(trimmed) ||
        category.toLowerCase().contains(trimmed);
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String? _asNullableString(dynamic v) {
    final str = v?.toString();
    return (str == null || str.isEmpty) ? null : str;
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static DateTime _asDate(dynamic v) {
    if (v == null) return DateTime.now();
    return DateTime.tryParse(v.toString())?.toLocal() ?? DateTime.now();
  }
}

/// Mirrors internal/dto.SummaryResponse.
class TransactionSummary {
  const TransactionSummary({
    required this.totalCredit,
    required this.totalDebit,
    required this.balance,
    required this.count,
  });

  final double totalCredit;
  final double totalDebit;
  final double balance;
  final int count;

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalCredit: AppTransaction._asDouble(json['total_credit']),
      totalDebit: AppTransaction._asDouble(json['total_debit']),
      balance: AppTransaction._asDouble(json['balance']),
      count: AppTransaction._asInt(json['transaction_count']),
    );
  }

  static const empty = TransactionSummary(
    totalCredit: 0,
    totalDebit: 0,
    balance: 0,
    count: 0,
  );
}