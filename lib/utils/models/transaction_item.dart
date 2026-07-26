// utils/models/transaction_item.dart
import 'package:flutter/material.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  groceries,
  salary,
  transport,
  entertainment,
  utilities,
  shopping,
  other,
}

extension TransactionCategoryStyle on TransactionCategory {
  IconData get icon {
    switch (this) {
      case TransactionCategory.groceries:
        return Icons.shopping_cart_outlined;
      case TransactionCategory.salary:
        return Icons.work_outline_rounded;
      case TransactionCategory.transport:
        return Icons.local_taxi_outlined;
      case TransactionCategory.entertainment:
        return Icons.movie_filter_outlined;
      case TransactionCategory.utilities:
        return Icons.bolt_outlined;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.other:
        return Icons.receipt_long_outlined;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.groceries:
        return const Color(0xFF2E9E5B);
      case TransactionCategory.salary:
        return const Color(0xFF0F9D58);
      case TransactionCategory.transport:
        return const Color(0xFFE0A526);
      case TransactionCategory.entertainment:
        return const Color(0xFF8B5CF6);
      case TransactionCategory.utilities:
        return const Color(0xFF2F9BE0);
      case TransactionCategory.shopping:
        return const Color(0xFFE0526B);
      case TransactionCategory.other:
        return const Color(0xFF6B7A8D);
    }
  }
}

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
  });

  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;

  /// Simple case-insensitive title match used by the search bar.
  bool matchesQuery(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return true;
    return title.toLowerCase().contains(trimmed);
  }
}