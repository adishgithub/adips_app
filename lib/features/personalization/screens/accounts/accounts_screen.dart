// features/personalization/screens/accounts/accounts_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/buttons/custom_elevated_button.dart';
import '../../../../data/services/settings_service.dart';
import '../../../../utils/constants/adips_category_colors.dart';
import '../../../../utils/constants/adips_icons.dart';
import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/models/account_model.dart';
import '../../../authentication/controllers/accounts/account_controller.dart';
import 'widgets/account_form_sheet.dart';

/// Settings > Accounts: list, add and edit accounts.
/// Archive / delete / reorder / adjust arrive in Phase 3.
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final AccountController _controller = AccountController.instance;

  @override
  void initState() {
    super.initState();
    // Home already loaded accounts, but balances may be stale if the
    // user got here from somewhere else, so refresh on entry.
    _controller.load();
  }

  /// Currency to pre-fill for a new account: the user's settings
  /// currency, falling back to the default account's, then INR.
  Future<String> _defaultCurrency() async {
    try {
      final settings = await SettingsService().getSettings();
      return settings.currency;
    } catch (_) {
      return _controller.defaultAccount?.currency ?? 'INR';
    }
  }

  Future<void> _openForm({AccountModel? account}) async {
    final currency = account == null ? await _defaultCurrency() : account.currency;
    if (!mounted) return;
    final saved = await showAccountFormSheet(
      context: context,
      account: account,
      defaultCurrency: currency,
    );
    // Balances/summary come from the backend, so re-fetch.
    if (saved == true) await _controller.refreshQuietly();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;

    return Scaffold(
      backgroundColor: isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Accounts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add account',
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final accounts = _controller.accounts.toList();
                if (_controller.isLoading.value && accounts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: _controller.load,
                  child: accounts.isEmpty
                      // Scrollable so pull-to-refresh works when empty.
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Text(
                                  'No accounts yet',
                                  style: TextStyle(color: mutedColor),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AdipsSizes.defaultSpace,
                            AdipsSizes.md,
                            AdipsSizes.defaultSpace,
                            AdipsSizes.md,
                          ),
                          itemCount: accounts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AdipsSizes.sm),
                          itemBuilder: (context, i) => _AccountTile(
                            account: accounts[i],
                            onTap: () => _openForm(account: accounts[i]),
                          ),
                        ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AdipsSizes.defaultSpace,
                AdipsSizes.sm,
                AdipsSizes.defaultSpace,
                AdipsSizes.md,
              ),
              child: CustomButton(text: 'Add account', onPressed: () => _openForm()),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, required this.onTap});

  final AccountModel account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;
    final brandColor =
        isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;
    final color = AdipsCategoryColors.byId(account.colorId);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusMd),
        border: Border.all(color: lineColor),
      ),
      // Fill on the Material so the ink splash is visible (same
      // trick as ManageableItemTile).
      child: Material(
        color: surfaceColor,
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(AdipsIcons.byId(account.iconId), color: color),
          ),
          title: Text(
            account.name,
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(
              spacing: AdipsSizes.xs,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  AccountTypeInfo.of(account.type).label,
                  style: TextStyle(color: mutedColor),
                ),
                if (account.isDefault) _Badge(label: 'Default', color: brandColor),
                if (!account.includeInTotal) _Badge(label: 'Excluded', color: mutedColor),
              ],
            ),
          ),
          trailing: Text(
            AdipsFormatters.money(account.currentBalance, account.currency),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: account.currentBalance < 0 ? lossColor : textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
