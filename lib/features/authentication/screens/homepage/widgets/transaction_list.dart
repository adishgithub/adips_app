// widgets/transaction_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/adips_category_colors.dart';
import '../../../../../utils/constants/adips_icons.dart';
import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/helpers/category_style.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/models/app_transaction.dart';
import '../../../../../utils/models/home_list_item.dart';
import '../../../controllers/home/home_controller.dart';
import 'transaction_form_sheet.dart';
import 'transfer_form_sheet.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key, required this.items});

  final List<HomeListItem> items;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;

    if (items.isEmpty) {
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
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: lineColor),
      itemBuilder: (context, index) => switch (items[index]) {
        TransactionRow(:final transaction) => _TransactionTile(item: transaction),
        final TransferRow row => _TransferTile(row: row),
      },
    );
  }
}

/// A collapsed transfer: "Main Account -> Cash", neutral colour (it
/// is neither income nor expense), swap icon, no +/- sign. Tapping
/// opens the transfer sheet to edit or delete both legs together.
class _TransferTile extends StatelessWidget {
  const _TransferTile({required this.row});

  final TransferRow row;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final neutralColor = isDark ? AdipsPalette.darkAction : AdipsPalette.lightAction;

    return InkWell(
      onTap: () => showTransferFormSheet(context, transfer: row.toModel()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: neutralColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.swap_horiz_rounded, size: 22, color: neutralColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${row.debit.accountName} \u2192 ${row.credit.accountName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('d MMM yyyy').format(row.date)} · Transfer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AdipsFormatters.money(row.amount, row.currency),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final AppTransaction item;

  /// A transfer leg (shown alone when Home is filtered to an
  /// account) edits the whole transfer, never a single leg (T4).
  Future<void> _open(BuildContext context) async {
    if (!item.isTransfer) {
      await showTransactionFormSheet(context, transaction: item);
      return;
    }
    final transfer = await HomeController.instance.loadTransfer(item.transferGroupId!);
    if (transfer != null && context.mounted) {
      await showTransferFormSheet(context, transfer: transfer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final gainColor = isDark ? AdipsPalette.darkGain : AdipsPalette.lightGain;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;

    final bool isIncome = item.isCredit;
    final Color amountColor = isIncome ? gainColor : lossColor;
    final String sign = isIncome ? '+' : '-';
    // Prefer the icon/color the user actually picked in the category
    // dropdown (stored on the transaction itself) — only fall back to
    // guessing from the category name for rows created before this
    // snapshot existed (category_icon_id/category_color_id == 0).
    final Color categoryColor = item.categoryColorId > 0
        ? AdipsCategoryColors.byId(item.categoryColorId)
        : CategoryStyle.colorFor(item.category);
    final IconData categoryIcon = item.categoryIconId > 0
        ? AdipsIcons.byId(item.categoryIconId)
        : CategoryStyle.iconFor(item.category);

    return InkWell(
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(categoryIcon, size: 20, color: categoryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // date · category · account (account omitted if the
                    // server sent no name).
                    [
                      DateFormat('d MMM yyyy').format(item.transactionDate),
                      item.category,
                      if (item.accountName.isNotEmpty) item.accountName,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$sign ${AdipsFormatters.money(item.amount, item.currency)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: amountColor),
                ),
                if (item.status != 'completed') ...[
                  const SizedBox(height: 2),
                  Text(
                    item.status,
                    style: TextStyle(fontSize: 10, color: mutedColor),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}