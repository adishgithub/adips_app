// utils/helpers/category_style.dart
import 'package:flutter/material.dart';

/// Transaction categories come from the backend as free-text strings
/// (see internal/models/transaction.go — Category is just a `string`,
/// not a foreign key), including whatever a user names their own
/// custom category. This maps the well-known seeded category names
/// (see internal/service/seed.go) to a nice icon/color, and falls
/// back to a generic look for anything else so the UI never breaks
/// on a category it doesn't recognise.
class CategoryStyle {
  static IconData iconFor(String category) {
    switch (category.trim().toLowerCase()) {
      case 'food':
        return Icons.restaurant_outlined;
      case 'grocery':
      case 'groceries':
        return Icons.shopping_cart_outlined;
      case 'fuel':
        return Icons.local_gas_station_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'bills & utilities':
      case 'utilities':
        return Icons.bolt_outlined;
      case 'entertainment':
        return Icons.movie_filter_outlined;
      case 'health':
        return Icons.favorite_border_rounded;
      case 'rent':
        return Icons.home_outlined;
      case 'salary':
        return Icons.work_outline_rounded;
      case 'business':
        return Icons.business_center_outlined;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'gift':
        return Icons.card_giftcard_outlined;
      case 'wallet transfer':
      case 'transfer':
        return Icons.swap_horiz_rounded;
      case 'transport':
        return Icons.local_taxi_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  static Color colorFor(String category) {
    switch (category.trim().toLowerCase()) {
      case 'food':
        return const Color(0xFFE0A526);
      case 'grocery':
      case 'groceries':
        return const Color(0xFF2E9E5B);
      case 'fuel':
        return const Color(0xFFE07A26);
      case 'shopping':
        return const Color(0xFFE0526B);
      case 'bills & utilities':
      case 'utilities':
        return const Color(0xFF2F9BE0);
      case 'entertainment':
        return const Color(0xFF8B5CF6);
      case 'health':
        return const Color(0xFFE0526B);
      case 'rent':
        return const Color(0xFF6B7A8D);
      case 'salary':
        return const Color(0xFF0F9D58);
      case 'business':
        return const Color(0xFF0F9D58);
      case 'investment':
        return const Color(0xFF2F9BE0);
      case 'gift':
        return const Color(0xFF8B5CF6);
      case 'wallet transfer':
      case 'transfer':
        return const Color(0xFF6B7A8D);
      case 'transport':
        return const Color(0xFFE0A526);
      default:
        return const Color(0xFF6B7A8D);
    }
  }
}
