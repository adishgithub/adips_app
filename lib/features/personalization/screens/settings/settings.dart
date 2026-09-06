// features/personalization/screens/settings/settings.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/list_tiles/settings_tile.dart';
import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../categories/categories_screen.dart';
import '../transaction_types/transaction_types_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.name, required this.email});

  final String name;
  final String email;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AdipsSizes.defaultSpace,
            vertical: AdipsSizes.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionCard(
                label: 'General',
                children: [
                  SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Account',
                    subtitle: widget.email.isNotEmpty ? widget.email : 'Profile details, logout',
                    onTap: () => Get.toNamed(
                      '/dashboard',
                      arguments: {'fullName': widget.name, 'email': widget.email},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdipsSizes.spaceBtwItems),

              SettingsSectionCard(
                label: 'Transaction Settings',
                children: [
                  SettingsTile(
                    icon: Icons.sell_outlined,
                    title: 'Transaction Types',
                    subtitle: 'Manage your income, expense & transfer types',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TransactionTypesScreen()),
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.grid_view_rounded,
                    title: 'Categories',
                    subtitle: 'Manage your transaction categories',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdipsSizes.spaceBtwItems),

              SettingsSectionCard(
                label: 'Other',
                children: const [
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About Adips',
                    subtitle: 'Version $_appVersion',
                  ),
                ],
              ),
              const SizedBox(height: AdipsSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}