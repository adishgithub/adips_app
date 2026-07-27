// features/personalization/screens/settings/widgets/profile_section.dart
import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

/// Non-clickable profile row: initial avatar, name, and email.
/// Mirrors the "Adish / adish@gmail.com" row from the Settings
/// screenshot, minus the chevron since it isn't tappable.
class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key, required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final brandColor = isDark
        ? AdipsPalette.darkPrimaryBrandText
        : AdipsPalette.lightPrimaryBrandText;

    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AdipsSizes.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusMd),
        border: Border.all(color: lineColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: brandColor.withOpacity(0.12),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: AdipsSizes.fontSizesEl,
                fontWeight: FontWeight.bold,
                color: brandColor,
              ),
            ),
          ),
          const SizedBox(width: AdipsSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: AdipsSizes.fontSizesMd,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(fontSize: AdipsSizes.fontSizesEs, color: mutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
