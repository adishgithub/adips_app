import 'package:adips/utils/theme/custom_theme/adips_colors.dart';
import 'package:flutter/material.dart';

/// Raw colour constants — the single source of truth for every hex value.
/// Use these directly in const contexts (AppBarTheme, TextStyle, etc.)
/// Use [AdipsColors] extension only inside widget trees via Theme.of(context).
class AdipsPalette {
  AdipsPalette._();

  // ── Light ──────────────────────────────────────
  static const Color lightCanvas = Color(0xFFF7F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSubtle = Color(0xFFEEF1F5);

  static const Color lightTextPrimary = Color(0xFF1A2332);
  static const Color lightTextMuted = Color(0xFF6B7A8D);
  static const Color lightTextHint = Color(0xFF9CA8B8);

  static const Color lightBorder = Color(0xFFC8D0DC);
  static const Color lightDivider = Color(0xFFEEF1F5);

  static const Color lightAction = Color(0xFF2C5282);
  static const Color lightActionHover = Color(0xFF1E3A5F);
  static const Color lightActionTint = Color(0xFFE6F1FB);

  static const Color lightGain = Color(0xFF1D7A4F);
  static const Color lightGainTint = Color(0xFFE6F5EE);

  static const Color lightLoss = Color(0xFFC0392B);
  static const Color lightLossTint = Color(0xFFFCEBEB);

  static const Color lightCaution = Color(0xFF9A6100);
  static const Color lightCautionTint = Color(0xFFFEF3E2);

  static const Color onboardSecondary = Color(0xFF12D8E3);

  // ── Dark ───────────────────────────────────────
  static const Color darkCanvas = Color(0xFF121A26);
  static const Color darkSurface = Color(0xFF1C2840);
  static const Color darkSubtle = Color(0xFF253045);

  static const Color darkTextPrimary = Color(0xFFF0F4FA);
  static const Color darkTextMuted = Color(0xFF8A9BB5);
  static const Color darkTextHint = Color(0xFF4E6080);

  static const Color darkBorder = Color(0xFF2E3F58);
  static const Color darkDivider = Color(0xFF243048);

  static const Color darkAction = Color(0xFF4A7FBF);
  static const Color darkActionHover = Color(0xFF5A8FCC);
  static const Color darkActionTint = Color(0xFF1C2E44);

  static const Color darkGain = Color(0xFF3DBE80);
  static const Color darkGainTint = Color(0xFF0F2E1F);

  static const Color darkLoss = Color(0xFFE05555);
  static const Color darkLossTint = Color(0xFF2E1212);

  static const Color darkCaution = Color(0xFFD4922A);
  static const Color darkCautionTint = Color(0xFF2A1E08);

  // ── Gradient ───────────────────────────────────────

  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [AdipsPalette.darkCanvas, AdipsPalette.darkSubtle],
  );
}
