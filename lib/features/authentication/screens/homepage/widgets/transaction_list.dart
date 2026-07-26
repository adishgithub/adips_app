// widgets/transaction_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/models/transaction_item.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key, required this.transactions});

  final List<TransactionItem> transactions;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No transactions found',
            style: TextStyle(color: mutedColor, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: lineColor),
      itemBuilder: (context, index) => _TransactionTile(item: transactions[index]),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final gainColor = isDark ? AdipsPalette.darkGain : AdipsPalette.lightGain;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;

    final bool isIncome = item.type == TransactionType.income;
    final Color amountColor = isIncome ? gainColor : lossColor;
    final String sign = isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.category.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.category.icon, size: 20, color: item.category.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM yyyy').format(item.date),
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign ₹${AdipsFormatters.formatCurrency(item.amount)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: amountColor),
          ),
        ],
      ),
    );
  }
}