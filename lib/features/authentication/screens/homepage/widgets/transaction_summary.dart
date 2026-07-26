// widgets/transaction_summary.dart
import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class TransactionSummary extends StatelessWidget {
  const TransactionSummary({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalTransactions,
  });

  final double totalIncome;
  final double totalExpenses;
  final int totalTransactions;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final gainColor = isDark ? AdipsPalette.darkGain : AdipsPalette.lightGain;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;
    final actionColor = isDark ? AdipsPalette.darkAction : AdipsPalette.lightAction;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
        border: Border.all(color: lineColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _SummaryTile(
                icon: Icons.trending_up_rounded,
                iconColor: gainColor,
                label: 'Total Income',
                value: '₹${AdipsFormatters.formatCurrency(totalIncome)}',
                valueColor: gainColor,
                mutedColor: mutedColor,
              ),
            ),
            VerticalDivider(color: lineColor, thickness: 1, width: 1, indent: 4, endIndent: 4),
            Expanded(
              child: _SummaryTile(
                icon: Icons.trending_down_rounded,
                iconColor: lossColor,
                label: 'Total Expenses',
                value: '₹${AdipsFormatters.formatCurrency(totalExpenses)}',
                valueColor: lossColor,
                mutedColor: mutedColor,
              ),
            ),
            VerticalDivider(color: lineColor, thickness: 1, width: 1, indent: 4, endIndent: 4),
            Expanded(
              child: _SummaryTile(
                icon: Icons.description_outlined,
                iconColor: actionColor,
                label: 'Total Transactions',
                value: '$totalTransactions',
                valueColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.mutedColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: valueColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: mutedColor),
        ),
      ],
    );
  }
}