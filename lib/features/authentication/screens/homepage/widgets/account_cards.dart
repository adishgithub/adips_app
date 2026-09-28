import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_category_colors.dart';
import '../../../../../utils/constants/adips_icons.dart';
import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/models/account_model.dart';

/// Horizontally scrolling row of account cards under the total
/// balance: icon, name and current balance for each account.
///
/// An account with include_in_total = false (A13) is still listed but
/// faded and tagged "Not in total", so the user can see why it isn't
/// part of the number above.
///
/// [selectedId] / [onTap] filter Home by account (1.9). When [onClear]
/// is given, a leading "All" card is shown; it is highlighted while
/// [selectedId] is null and calls [onClear] when tapped.
class AccountCards extends StatelessWidget {
  const AccountCards({
    super.key,
    required this.accounts,
    this.selectedId,
    this.onTap,
    this.onClear,
  });

  final List<AccountModel> accounts;
  final int? selectedId;
  final ValueChanged<AccountModel>? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return const SizedBox.shrink();

    final bool showAll = onClear != null;
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length + (showAll ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: AdipsSizes.sm),
        itemBuilder: (context, index) {
          if (showAll && index == 0) {
            return _AllCard(isSelected: selectedId == null, onTap: onClear!);
          }
          final account = accounts[showAll ? index - 1 : index];
          return _AccountCard(
            account: account,
            isSelected: account.id == selectedId,
            onTap: onTap == null ? null : () => onTap!(account),
          );
        },
      ),
    );
  }
}

/// Narrow "All" card that clears the account filter.
class _AllCard extends StatelessWidget {
  const _AllCard({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final brandColor =
        isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
      child: Container(
        width: 64,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
          border: Border.all(
            color: isSelected ? brandColor : lineColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_outlined,
                size: 20, color: isSelected ? brandColor : textColor),
            const SizedBox(height: 4),
            Text(
              'All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? brandColor : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  final AccountModel account;
  final bool isSelected;
  final VoidCallback? onTap;

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

    final Color accent = AdipsCategoryColors.byId(account.colorId);
    final bool negative = account.currentBalance < 0;

    return Opacity(
      opacity: account.includeInTotal ? 1 : 0.6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(AdipsSizes.sm),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
            border: Border.all(
              color: isSelected ? brandColor : lineColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: accent.withValues(alpha: 0.15),
                    child: Icon(AdipsIcons.byId(account.iconId), color: accent, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  AdipsFormatters.money(account.currentBalance, account.currency),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: negative ? lossColor : textColor,
                  ),
                ),
              ),
              Text(
                account.includeInTotal ? AccountTypeInfo.of(account.type).label : 'Not in total',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
