import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Settings screen, reached from the home screen's bottom action bar.
/// Tapping "Account" opens the Dashboard screen (profile details +
/// logout).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = (Get.arguments as Map<String, dynamic>?) ?? {};

    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final backgroundColor = isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground;
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final brandColor = isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AdipsSizes.defaultSpace),
          children: [
            Text(
              'GENERAL',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mutedColor, letterSpacing: 1),
            ),
            const SizedBox(height: AdipsSizes.spaceBtwItems),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border.all(color: lineColor),
                borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusMg),
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Account',
                    subtitle: 'Profile details, logout',
                    iconColor: brandColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    onTap: () => Get.toNamed('/dashboard', arguments: args),
                  ),
                  Divider(height: 1, color: lineColor),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Appearance',
                    subtitle: 'Follows your system theme',
                    iconColor: brandColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    onTap: () {},
                  ),
                  Divider(height: 1, color: lineColor),
                  _SettingsTile(
                    icon: Icons.currency_rupee_rounded,
                    label: 'Currency',
                    subtitle: 'Default transaction currency',
                    iconColor: brandColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.textColor,
    required this.mutedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: mutedColor)),
      trailing: Icon(Icons.chevron_right_rounded, color: mutedColor),
    );
  }
}
