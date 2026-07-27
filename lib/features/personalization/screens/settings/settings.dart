// features/personalization/screens/settings/settings.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/list_tiles/settings_tile.dart';
import '../../../../data/services/settings_service.dart';
import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../categories/categories_screen.dart';
import '../transaction_types/transaction_types_screen.dart';
import 'widgets/profile_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.name, required this.email});

  final String name;
  final String email;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  static const String _appVersion = '1.0.0';

  String _currency = 'INR'; // default until the real value loads
  bool _loadingCurrency = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.getSettings();
      if (mounted) setState(() => _currency = settings.currency);
    } catch (_) {
      // Keep the INR default silently — this row is informational
      // only (non-clickable), so there's nothing actionable to show.
    } finally {
      if (mounted) setState(() => _loadingCurrency = false);
    }
  }

  String get _currencyLabel {
    switch (_currency) {
      case 'INR':
        return 'INR - Indian Rupee';
      case 'USD':
        return 'USD - US Dollar';
      case 'EUR':
        return 'EUR - Euro';
      default:
        return _currency;
    }
  }

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
              ProfileSection(name: widget.name, email: widget.email),
              const SizedBox(height: AdipsSizes.spaceBtwSections),

              SettingsSectionCard(
                label: 'General',
                children: [
                  SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Account',
                    subtitle: 'Profile details, logout',
                    onTap: () => Get.toNamed(
                      '/dashboard',
                      arguments: {'fullName': widget.name, 'email': widget.email},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdipsSizes.spaceBtwItems),

              SettingsSectionCard(
                label: 'Preferences',
                children: [
                  SettingsTile(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Currency',
                    subtitle: _loadingCurrency ? 'Loading...' : _currencyLabel,
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
