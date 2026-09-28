import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/models/account_model.dart';

/// Total balance across the accounts that count toward the total
/// (include_in_total, rule A13), straight from /accounts/summary.
///
/// Totals arrive grouped by currency (D7) and are NEVER added together
/// here: the first currency is the big number, any others appear as
/// smaller lines under it.
class AccountBalance extends StatelessWidget {
  const AccountBalance({
    super.key,
    required this.totals,
    this.fallbackCurrency = 'INR',
  });

  final List<AccountSummaryTotal> totals;

  /// Shown as 0.00 when there are no totals yet (loading / no accounts).
  final String fallbackCurrency;

  @override
  Widget build(BuildContext context) {
    final AccountSummaryTotal primary = totals.isNotEmpty
        ? totals.first
        : AccountSummaryTotal(currency: fallbackCurrency, totalBalance: 0);
    final List<AccountSummaryTotal> others =
        totals.length > 1 ? totals.sublist(1) : const [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
        boxShadow: [
          BoxShadow(
            color: AdipsPalette.shadowColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
        child: Container(
          padding: const EdgeInsets.all(AdipsSizes.minPaddingAll),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AdipsPalette.darkPrimaryBrandText,
                AdipsPalette.lightPrimaryBrandText,
              ],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      color: AdipsPalette.lightPrimaryButtonText.withOpacity(0.85),
                      fontSize: AdipsSizes.fontSizesSm,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: AdipsSizes.spaceBtwFontsSm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AdipsFormatters.money(primary.totalBalance, primary.currency),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  for (final other in others) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+ ${AdipsFormatters.money(other.totalBalance, other.currency)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              Positioned(
                right: -10,
                bottom: -20,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.account_balance,
                    size: 130,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
