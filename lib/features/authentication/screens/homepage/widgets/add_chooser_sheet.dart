// widgets/add_chooser_sheet.dart
import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import 'transaction_form_sheet.dart';
import 'transfer_form_sheet.dart';

enum _AddChoice { transaction, transfer }

/// What the Home "Add" button opens: a small sheet asking whether to
/// add a Transaction (income/expense on one account) or a Transfer
/// (money moved between two of your accounts), then opens the
/// matching form. Keeping them separate is what stops a transfer
/// from being recorded as a plain expense (G6).
Future<void> showAddChooserSheet(BuildContext context) async {
  final choice = await showModalBottomSheet<_AddChoice>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddChooserSheet(),
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case _AddChoice.transaction:
      await showTransactionFormSheet(context);
    case _AddChoice.transfer:
      await showTransferFormSheet(context);
  }
}

class _AddChooserSheet extends StatelessWidget {
  const _AddChooserSheet();

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final brandColor =
        isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;

    Widget option({
      required IconData icon,
      required String title,
      required String subtitle,
      required _AddChoice value,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
        onTap: () => Navigator.of(context).pop(value),
        child: Container(
          padding: const EdgeInsets.all(AdipsSizes.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
            border: Border.all(color: lineColor),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: brandColor.withOpacity(0.12),
                child: Icon(icon, color: brandColor),
              ),
              const SizedBox(width: AdipsSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AdipsSizes.fontSizesMd,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: AdipsSizes.fontSizesEs, color: mutedColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: mutedColor),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Container(
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
              'What would you like to add?',
              style: TextStyle(
                fontSize: AdipsSizes.fontSizesLg,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AdipsSizes.md),
            option(
              icon: Icons.receipt_long_outlined,
              title: 'Transaction',
              subtitle: 'Income or expense on one account',
              value: _AddChoice.transaction,
            ),
            const SizedBox(height: AdipsSizes.sm),
            option(
              icon: Icons.swap_horiz_rounded,
              title: 'Transfer',
              subtitle: 'Move money between your accounts',
              value: _AddChoice.transfer,
            ),
          ],
        ),
      ),
    );
  }
}
