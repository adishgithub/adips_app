import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

/// ThemeExtension that exposes semantic colour tokens inside widget trees.
///
/// Usage:
///   final c = Theme.of(context).extension<AdipsColors>()!;
///   Text('+3.4%', style: TextStyle(color: c.gain));
class AdipsColors extends ThemeExtension<AdipsColors> {
  const AdipsColors({
    required this.canvas,
    required this.surface,
    required this.subtle,
    required this.textPrimary,
    required this.textMuted,
    required this.textHint,
    required this.border,
    required this.divider,
    required this.action,
    required this.actionHover,
    required this.actionTint,
    required this.gain,
    required this.gainTint,
    required this.loss,
    required this.lossTint,
    required this.caution,
    required this.cautionTint,
  });

  final Color canvas;
  final Color surface;
  final Color subtle;
  final Color textPrimary;
  final Color textMuted;
  final Color textHint;
  final Color border;
  final Color divider;
  final Color action;
  final Color actionHover;
  final Color actionTint;
  final Color gain;
  final Color gainTint;
  final Color loss;
  final Color lossTint;
  final Color caution;
  final Color cautionTint;

  static const light = AdipsColors(
    canvas: AdipsPalette.lightCanvas,
    surface: AdipsPalette.lightSurface,
    subtle: AdipsPalette.lightSubtle,
    textPrimary: AdipsPalette.lightTextPrimary,
    textMuted: AdipsPalette.lightTextMuted,
    textHint: AdipsPalette.lightTextHint,
    border: AdipsPalette.lightBorder,
    divider: AdipsPalette.lightDivider,
    action: AdipsPalette.lightAction,
    actionHover: AdipsPalette.lightActionHover,
    actionTint: AdipsPalette.lightActionTint,
    gain: AdipsPalette.lightGain,
    gainTint: AdipsPalette.lightGainTint,
    loss: AdipsPalette.lightLoss,
    lossTint: AdipsPalette.lightLossTint,
    caution: AdipsPalette.lightCaution,
    cautionTint: AdipsPalette.lightCautionTint,
  );

  static const dark = AdipsColors(
    canvas: AdipsPalette.darkCanvas,
    surface: AdipsPalette.darkSurface,
    subtle: AdipsPalette.darkSubtle,
    textPrimary: AdipsPalette.darkTextPrimary,
    textMuted: AdipsPalette.darkTextMuted,
    textHint: AdipsPalette.darkTextHint,
    border: AdipsPalette.darkBorder,
    divider: AdipsPalette.darkDivider,
    action: AdipsPalette.darkAction,
    actionHover: AdipsPalette.darkActionHover,
    actionTint: AdipsPalette.darkActionTint,
    gain: AdipsPalette.darkGain,
    gainTint: AdipsPalette.darkGainTint,
    loss: AdipsPalette.darkLoss,
    lossTint: AdipsPalette.darkLossTint,
    caution: AdipsPalette.darkCaution,
    cautionTint: AdipsPalette.darkCautionTint,
  );

  @override
  AdipsColors copyWith({
    Color? canvas,
    Color? surface,
    Color? subtle,
    Color? textPrimary,
    Color? textMuted,
    Color? textHint,
    Color? border,
    Color? divider,
    Color? action,
    Color? actionHover,
    Color? actionTint,
    Color? gain,
    Color? gainTint,
    Color? loss,
    Color? lossTint,
    Color? caution,
    Color? cautionTint,
  }) => AdipsColors(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    subtle: subtle ?? this.subtle,
    textPrimary: textPrimary ?? this.textPrimary,
    textMuted: textMuted ?? this.textMuted,
    textHint: textHint ?? this.textHint,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    action: action ?? this.action,
    actionHover: actionHover ?? this.actionHover,
    actionTint: actionTint ?? this.actionTint,
    gain: gain ?? this.gain,
    gainTint: gainTint ?? this.gainTint,
    loss: loss ?? this.loss,
    lossTint: lossTint ?? this.lossTint,
    caution: caution ?? this.caution,
    cautionTint: cautionTint ?? this.cautionTint,
  );

  @override
  AdipsColors lerp(AdipsColors? other, double t) {
    if (other == null) return this;
    return AdipsColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      subtle: Color.lerp(subtle, other.subtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      action: Color.lerp(action, other.action, t)!,
      actionHover: Color.lerp(actionHover, other.actionHover, t)!,
      actionTint: Color.lerp(actionTint, other.actionTint, t)!,
      gain: Color.lerp(gain, other.gain, t)!,
      gainTint: Color.lerp(gainTint, other.gainTint, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      lossTint: Color.lerp(lossTint, other.lossTint, t)!,
      caution: Color.lerp(caution, other.caution, t)!,
      cautionTint: Color.lerp(cautionTint, other.cautionTint, t)!,
    );
  }
}
