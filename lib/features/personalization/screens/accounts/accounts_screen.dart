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
import '../../../../utils/http/http_client.dart';
import '../../../../utils/models/account_model.dart';
import '../../../authentication/controllers/accounts/account_controller.dart';
import '../../../authentication/controllers/home/home_controller.dart';
import '../../../authentication/screens/homepage/widgets/transfer_form_sheet.dart';
import 'widgets/account_form_sheet.dart';

enum _AccountAction { edit, archive, unarchive }

/// Settings > Accounts: list, add, edit, archive / unarchive, and a
/// "Show archived" toggle. Delete / reorder / adjust arrive in the
/// rest of Phase 3.
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final AccountController _controller = AccountController.instance;

  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    // Home already loaded accounts, but balances may be stale if the
    // user got here from somewhere else, so refresh on entry.
    _controller.load();
  }

  Future<void> _reload() async {
    await _controller.load();
    if (_showArchived) await _controller.loadArchived();
  }

  Future<void> _toggleArchived(bool value) async {
    setState(() => _showArchived = value);
    if (value) await _controller.loadArchived();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _archive(AccountModel account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Archive ${account.name}?'),
        content: const Text(
          'It will be hidden from Home and from account pickers. Its '
          'transactions are kept, and you can unarchive it any time.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Archive')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _controller.archive(account.id, refreshArchived: _showArchived);
      // Home may be filtered to this account; it is gone from the
      // cards now, so go back to "All".
      final home = HomeController.instance;
      if (home.selectedAccountId.value == account.id) await home.selectAccount(null);
      _snack('${account.name} archived');
    } on ApiException catch (e) {
      // A11: non-zero balance gets a shortcut; A6 (default account)
      // and A7 (last active account) are explained by the server's own
      // message.
      if (e.statusCode == 409 &&
          e.message.toLowerCase().contains('zero') &&
          account.currentBalance.abs() >= 0.005) {
        await _offerBalanceTransfer(account, e.message);
      } else {
        _snack(e.message);
      }
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Archiving needs a zero balance: explain, and open the transfer
  /// sheet pre-filled to clear it (out of the account if it holds
  /// money, into it if it's overdrawn).
  Future<void> _offerBalanceTransfer(AccountModel account, String serverMessage) async {
    final positive = account.currentBalance > 0;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Balance must be zero'),
        content: Text(
          '$serverMessage\n\n${account.name} currently has '
          '${AdipsFormatters.money(account.currentBalance, account.currency)}.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(positive ? 'Transfer balance out' : 'Add money to it'),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    await showTransferFormSheet(
      context,
      fromAccountId: positive ? account.id : null,
      toAccountId: positive ? null : account.id,
      amount: account.currentBalance.abs(),
    );
  }

  Future<void> _unarchive(AccountModel account) async {
    try {
      await _controller.unarchive(account.id, refreshArchived: _showArchived);
      _snack('${account.name} is active again');
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _onAction(_AccountAction action, AccountModel account) {
    switch (action) {
      case _AccountAction.edit:
        _openForm(account: account);
      case _AccountAction.archive:
        _archive(account);
      case _AccountAction.unarchive:
        _unarchive(account);
    }
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AdipsSizes.defaultSpace,
                AdipsSizes.xs,
                AdipsSizes.defaultSpace,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Show archived',
                      style: TextStyle(color: mutedColor, fontSize: AdipsSizes.fontSizesSm),
                    ),
                  ),
                  Switch(value: _showArchived, onChanged: _toggleArchived),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                // Active accounts first (backend order), then archived
                // ones when the toggle is on.
                final active = _controller.accounts.toList();
                final archived = _controller.archivedAccounts.toList();
                final accounts = [...active, if (_showArchived) ...archived];
                if (_controller.isLoading.value && accounts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: _reload,
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
                            onAction: (a) => _onAction(a, accounts[i]),
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
  const _AccountTile({
    required this.account,
    required this.onTap,
    required this.onAction,
  });

  final AccountModel account;
  final VoidCallback onTap;
  final ValueChanged<_AccountAction> onAction;

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

    return Opacity(
      // Archived rows are greyed out.
      opacity: account.isArchived ? 0.55 : 1,
      child: Container(
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
                if (account.isArchived) _Badge(label: 'Archived', color: mutedColor),
                if (account.isDefault) _Badge(label: 'Default', color: brandColor),
                if (!account.includeInTotal) _Badge(label: 'Excluded', color: mutedColor),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AdipsFormatters.money(account.currentBalance, account.currency),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: account.currentBalance < 0 ? lossColor : textColor,
                ),
              ),
              PopupMenuButton<_AccountAction>(
                tooltip: 'More',
                icon: Icon(Icons.more_vert_rounded, color: mutedColor),
                onSelected: onAction,
                itemBuilder: (_) => [
                  const PopupMenuItem(value: _AccountAction.edit, child: Text('Edit')),
                  if (account.isArchived)
                    const PopupMenuItem(
                        value: _AccountAction.unarchive, child: Text('Unarchive'))
                  else
                    const PopupMenuItem(
                        value: _AccountAction.archive, child: Text('Archive')),
                ],
              ),
            ],
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
