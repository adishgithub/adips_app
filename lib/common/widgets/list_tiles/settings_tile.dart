// common/widgets/list_tiles/settings_tile.dart
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_palette.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

/// One row inside a [SettingsSectionCard]: a circular icon, a title,
/// an optional subtitle, and an optional trailing widget. Pass
/// [onTap] to make it clickable (a chevron is shown automatically);
/// leave it null for a plain, non-clickable info row.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.iconBackgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? iconBackgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final brandColor = isDark
        ? AdipsPalette.darkPrimaryBrandText
        : AdipsPalette.lightPrimaryBrandText;
    final defaultIconBg = isDark
        ? AdipsPalette.darkPrimaryBrandText.withOpacity(0.15)
        : AdipsPalette.lightPrimaryBrandText.withOpacity(0.1);

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AdipsSizes.md, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? defaultIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AdipsSizes.iconSm, color: iconColor ?? brandColor),
          ),
          const SizedBox(width: AdipsSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AdipsSizes.fontSizesSm,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: AdipsSizes.fontSizesEs, color: mutedColor),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (trailing == null && onTap != null)
            Icon(Icons.chevron_right_rounded, color: mutedColor, size: AdipsSizes.iconMd),
        ],
      ),
    );

    if (onTap == null && onLongPress == null) return row;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
      child: row,
    );
  }
}

/// The rounded, bordered card wrapper each group of [SettingsTile]s
/// sits inside — mirrors the "Preferences" / "Transaction Settings"
/// cards from the Settings screenshot. Children are separated by a
/// themed divider automatically.
class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({super.key, this.label, required this.children});

  final String? label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AdipsSizes.xs),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: AdipsSizes.fontSizesEs,
                fontWeight: FontWeight.w600,
                color: mutedColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusMd),
            border: Border.all(color: lineColor),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(height: 1, thickness: 1, color: lineColor, indent: AdipsSizes.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
