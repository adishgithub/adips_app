// widgets/delete_account_sheet.dart
import 'package:adips/common/widgets/dropdowns/custom_dropdown.dart';
import 'package:adips/features/authentication/controllers/accounts/account_controller.dart';
import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/helpers/helper_functions.dart';
import 'package:adips/utils/models/account_model.dart';
import 'package:flutter/material.dart';

/// Opens the merge-delete sheet for an account that has transactions
/// (A9/A10). The user picks where the transactions go, sees exactly
/// what will happen (server-side preview), and confirms.
///
/// Returns the chosen target account id when the user confirms, or null
/// if they cancel. The sheet only previews; the caller performs the
/// delete with that id.
///
/// [targets] must already be filtered to the accounts the server will
/// accept: active, same currency, not [account] itself (D7, A12).
Future<int?> showDeleteAccountSheet(
  BuildContext context, {
  required AccountModel account,
  required List<AccountModel> targets,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DeleteAccountSheet(account: account, targets: targets),
  );
}

class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({super.key, required this.account, required this.targets});

  final AccountModel account;
  final List<AccountModel> targets;

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  final AccountController _controller = AccountController.instance;

  AccountModel? _target;
  AccountDeletePreview? _preview;
  bool _loadingPreview = false;
  String? _error;

  // Bumped on every preview request so a slow, older response can't
  // overwrite the preview of the target the user picked last.
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    // Prefer the default account as the destination, else the first.
    _target = widget.targets.where((a) => a.isDefault).firstOrNull ??
        widget.targets.firstOrNull;
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    final target = _target;
    if (target == null) return;
    final seq = ++_seq;
    setState(() {
      _loadingPreview = true;
      _preview = null;
      _error = null;
    });
    try {
      final preview = await _controller.deletePreview(widget.account.id, target.id);
      if (!mounted || seq != _seq) return;
      setState(() => _preview = preview);
    } catch (e) {
      if (!mounted || seq != _seq) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted && seq == _seq) setState(() => _loadingPreview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;

    final account = widget.account;
    final target = _target;
    final preview = _preview;
    final canConfirm = target != null && preview != null && !_loadingPreview;

    return Padding(
      // Keeps the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AdipsSizes.cardRadiusLg)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AdipsSizes.defaultSpace,
          AdipsSizes.sm,
          AdipsSizes.defaultSpace,
          AdipsSizes.defaultSpace,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AdipsSizes.spaceBtwItems),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  'Delete ${account.name}',
                  style: TextStyle(
                    fontSize: AdipsSizes.fontSizesXxl,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AdipsSizes.sm),
                Text(
                  '${account.name} has transactions. Choose the account that '
                  'should take them over; ${account.name} is then removed. '
                  'This can\'t be undone.',
                  style: TextStyle(color: mutedColor),
                ),
                const SizedBox(height: AdipsSizes.spaceBtwSections),

                CustomDropdown<AccountModel>(
                  value: target,
                  labelText: 'Move transactions to',
                  items: widget.targets,
                  itemLabelBuilder: (a) => a.name,
                  onChanged: (a) {
                    if (a == null || a.id == _target?.id) return;
                    setState(() => _target = a);
                    _loadPreview();
                  },
                ),
                const SizedBox(height: AdipsSizes.spaceBtwItems),

                if (_loadingPreview)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AdipsSizes.sm),
                    child: LinearProgressIndicator(),
                  )
                else if (_error != null)
                  Text(_error!, style: TextStyle(color: lossColor))
                else if (preview != null && target != null)
                  Container(
                    padding: const EdgeInsets.all(AdipsSizes.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusMd),
                      border: Border.all(color: lineColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PreviewRow(
                          label: 'Transactions moved',
                          value: '${preview.movedTransactionCount}',
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                        if (preview.collapsedTransferCount > 0) ...[
                          const SizedBox(height: AdipsSizes.xs),
                          _PreviewRow(
                            label: 'Transfers between the two (removed)',
                            value: '${preview.collapsedTransferCount}',
                            textColor: textColor,
                            mutedColor: mutedColor,
                          ),
                        ],
                        const SizedBox(height: AdipsSizes.xs),
                        _PreviewRow(
                          label: '${account.name} balance (added)',
                          value: AdipsFormatters.money(
                              preview.sourceCurrentBalance, account.currency),
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                        const SizedBox(height: AdipsSizes.xs),
                        _PreviewRow(
                          label: '${target.name} balance',
                          value:
                              '${AdipsFormatters.money(preview.targetBalanceBefore, target.currency)}'
                              '  →  '
                              '${AdipsFormatters.money(preview.targetBalanceAfter, target.currency)}',
                          textColor: textColor,
                          mutedColor: mutedColor,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AdipsSizes.spaceBtwSections),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lossColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: canConfirm ? () => Navigator.of(context).pop(target.id) : null,
                    child: const Text('Delete and move transactions'),
                  ),
                ),
                const SizedBox(height: AdipsSizes.xs),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: mutedColor)),
        ),
        const SizedBox(width: AdipsSizes.sm),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: textColor,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
