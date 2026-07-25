import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class AccountBalance extends StatelessWidget {
  const AccountBalance({
    super.key,
    required this.accountBalance,
  });

  final double accountBalance;

  @override
  Widget build(BuildContext context) {
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
                    'Account Balance',
                    style: TextStyle(
                      color: AdipsPalette.lightPrimaryButtonText.withOpacity(0.85),
                      fontSize: AdipsSizes.fontSizesSm,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: AdipsSizes.spaceBtwFontsSm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '₹',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: AdipsSizes.spaceBtwFontsSm),
                      Text(
                        AdipsFormatters.formatCurrency(accountBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
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