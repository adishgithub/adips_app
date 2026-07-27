// utils/models/app_transaction.dart
//
// Mirrors internal/dto.TransactionResponse from adips_backend exactly
// (field names/types), so parsing is a straight json['field'] read
// with no guessing at what the server sends.
class AppTransaction {
  const AppTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.status,
    required this.paymentMethod,
    required this.transactionDate,
    required this.note,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final double amount;

  /// Always "credit" or "debit" — matches the backend's
  /// TransactionDirection enum.
  final String type;
  final String category;
  final String description;

  /// "pending" | "completed" | "failed"
  final String status;
  final String paymentMethod;
  final DateTime transactionDate;
  final String note;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCredit => type == 'credit';

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      amount: _asDouble(json['amount']),
      type: (json['type'] ?? 'debit').toString(),
      category: (json['category'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'completed').toString(),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      transactionDate: _asDate(json['transaction_date']),
      note: (json['note'] ?? '').toString(),
      currency: (json['currency'] ?? 'INR').toString(),
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
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
