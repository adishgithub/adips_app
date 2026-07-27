// utils/constants/adips_category_colors.dart
import 'package:flutter/material.dart';

/// The full, fixed set of colors a user can pick for a transaction
/// type or category. Backend only ever stores the integer `color_id`
/// (see adips_backend/internal/constants/icons.go, MinColorID..MaxColorID
/// = 1..8) — this list is the single source of truth for what each id
/// actually renders as. Never reorder; only ever append.
class AdipsCategoryColors {
  AdipsCategoryColors._();

  static const List<Color> _colors = [
    Color(0xFF2E9E5B), // 1 green
    Color(0xFFE0A526), // 2 amber
    Color(0xFF8B5CF6), // 3 purple
    Color(0xFF2F9BE0), // 4 blue
    Color(0xFFE0526B), // 5 red/pink
    Color(0xFF0F9D58), // 6 deep green
    Color(0xFF14B8A6), // 7 teal
    Color(0xFF6B7A8D), // 8 grey
  ];

  static Color byId(int id) {
    final index = id - 1;
    if (index < 0 || index >= _colors.length) return _colors.last;
    return _colors[index];
  }

  static List<MapEntry<int, Color>> get all =>
      List.generate(_colors.length, (i) => MapEntry(i + 1, _colors[i]));
}
