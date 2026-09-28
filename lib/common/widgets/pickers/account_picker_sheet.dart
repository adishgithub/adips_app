// common/widgets/pickers/account_picker_sheet.dart
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_category_colors.dart';
import '../../../utils/constants/adips_icons.dart';
import '../../../utils/constants/adips_palette.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/models/account_model.dart';

/// Opens a sheet listing [accounts] (icon, color, name, type and
/// current balance — same look as the category picker). Returns the
/// picked account, or null if dismissed.
///
/// The caller decides WHICH accounts are offered (e.g. only active
/// ones, or only same-currency ones) by filtering [accounts] first.
/// Rows listed in [disabledReasons] (account id -> short reason) are
/// shown greyed out with the reason and can't be picked — used later
/// by merge-delete to explain why a target isn't allowed.
Future<AccountModel?> showAccountPickerSheet({
  required BuildContext context,
  required List<AccountModel> accounts,
  AccountModel? selected,
  String title = 'Choose an account',
  String emptyMessage = 'No accounts available.',
  Map<int, String> disabledReasons = const {},
}) {
  return showModalBottomSheet<AccountModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AccountPickerSheet(
      accounts: accounts,
      selected: selected,
      title: title,
      emptyMessage: emptyMessage,
      disabledReasons: disabledReasons,
    ),
  );
}

class AccountPickerSheet extends StatelessWidget {
  const AccountPickerSheet({
    super.key,
    required this.accounts,
    required this.title,
    required this.emptyMessage,
    this.selected,
    this.disabledReasons = const {},
  });

  final List<AccountModel> accounts;
  final AccountModel? selected;
  final String title;
  final String emptyMessage;
  final Map<int, String> disabledReasons;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final brandColor =
        isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          margin: const EdgeInsets.all(AdipsSizes.sm),
          padding: const EdgeInsets.all(AdipsSizes.md),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusLg),
            border: Border.all(color: lineColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AdipsSizes.sm),
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: AdipsSizes.fontSizesLg,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: AdipsSizes.sm),
              Flexible(
                child: accounts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: AdipsSizes.lg),
                        child: Text(emptyMessage, style: TextStyle(color: mutedColor)),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          for (final account in accounts)
                            _AccountRow(
                              account: account,
                              isSelected: account.id == selected?.id,
                              disabledReason: disabledReasons[account.id],
                              textColor: textColor,
                              mutedColor: mutedColor,
                              lineColor: lineColor,
                              brandColor: brandColor,
                              lossColor: lossColor,
                              onTap: () => Navigator.of(context).pop(account),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.account,
    required this.isSelected,
    required this.disabledReason,
    required this.textColor,
    required this.mutedColor,
    required this.lineColor,
    required this.brandColor,
    required this.lossColor,
    required this.onTap,
  });

  final AccountModel account;
  final bool isSelected;
  final String? disabledReason;
  final Color textColor;
  final Color mutedColor;
  final Color lineColor;
  final Color brandColor;
  final Color lossColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool disabled = disabledReason != null;
    final Color accent = AdipsCategoryColors.byId(account.colorId);
    final bool negative = account.currentBalance < 0;

    // Second line: why it's disabled, else "Type · Default".
    final String subtitle = disabled
        ? disabledReason!
        : [
            AccountTypeInfo.of(account.type).label,
            if (account.isDefault) 'Default',
          ].join(' · ');

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
        child: Container(
          margin: const EdgeInsets.only(bottom: AdipsSizes.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: AdipsSizes.sm,
            vertical: AdipsSizes.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
            border: Border.all(color: isSelected ? brandColor : lineColor),
            color: isSelected ? brandColor.withValues(alpha: 0.08) : Colors.transparent,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: accent.withValues(alpha: 0.15),
                child: Icon(AdipsIcons.byId(account.iconId), color: accent, size: 18),
              ),
              const SizedBox(width: AdipsSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AdipsSizes.xs),
              Text(
                AdipsFormatters.money(account.currentBalance, account.currency),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: negative ? lossColor : textColor,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: AdipsSizes.xs),
                Icon(Icons.check_circle_rounded, color: brandColor, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
