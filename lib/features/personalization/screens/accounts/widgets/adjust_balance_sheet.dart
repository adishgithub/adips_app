// widgets/adjust_balance_sheet.dart
import 'package:adips/common/widgets/buttons/custom_elevated_button.dart';
import 'package:adips/common/widgets/text_fields/custom_text_field.dart';
import 'package:adips/features/authentication/controllers/accounts/account_controller.dart';
import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/helpers/helper_functions.dart';
import 'package:adips/utils/models/account_model.dart';
import 'package:flutter/material.dart';

/// Opens the "Adjust balance" sheet: the user types the balance they
/// really see in their bank / wallet, and the server records one
/// correcting credit or debit for the difference (section 8.6).
///
/// Returns the server's result once the adjustment is saved (check
/// [AccountAdjustResult.changed] — it's false when the balance already
/// matched), or null if the user cancels.
Future<AccountAdjustResult?> showAdjustBalanceSheet(
  BuildContext context, {
  required AccountModel account,
}) {
  return showModalBottomSheet<AccountAdjustResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AdjustBalanceSheet(account: account),
  );
}

class AdjustBalanceSheet extends StatefulWidget {
  const AdjustBalanceSheet({super.key, required this.account});

  final AccountModel account;

  @override
  State<AdjustBalanceSheet> createState() => _AdjustBalanceSheetState();
}

class _AdjustBalanceSheetState extends State<AdjustBalanceSheet> {
  // Same bound as the backend (numeric(14,2) headroom).
  static const double _maxAbs = 999999999999;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _balanceController;
  final TextEditingController _noteController = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _balanceController = TextEditingController(
      text: widget.account.currentBalance.toStringAsFixed(2),
    );
    // Rebuild on every keystroke so the "difference" line stays live.
    _balanceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double? get _actual => double.tryParse(_balanceController.text.trim());

  /// actual - calculated, rounded to cents like the server does.
  double? get _difference {
    final actual = _actual;
    if (actual == null) return null;
    return ((actual - widget.account.currentBalance) * 100).roundToDouble() / 100;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final actual = _actual;
    if (actual == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await AccountController.instance.adjust(
        widget.account.id,
        actualBalance: actual,
        note: _noteController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(result);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;

    final account = widget.account;
    final diff = _difference;

    String hint;
    if (diff == null) {
      hint = '';
    } else if (diff == 0) {
      hint = 'Matches the calculated balance — nothing will be recorded.';
    } else {
      final kind = diff > 0 ? 'credit' : 'debit';
      hint = 'A $kind of ${AdipsFormatters.money(diff.abs(), account.currency)} will be '
          'recorded as "Balance Adjustment".';
    }

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
            child: Form(
              key: _formKey,
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
                    'Adjust ${account.name}',
                    style: TextStyle(
                      fontSize: AdipsSizes.fontSizesXxl,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AdipsSizes.sm),
                  Text(
                    'Calculated balance: '
                    '${AdipsFormatters.money(account.currentBalance, account.currency)}. '
                    'Enter what you actually have and the difference is recorded '
                    'as one correcting transaction.',
                    style: TextStyle(color: mutedColor),
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwSections),

                  CustomTextField(
                    controller: _balanceController,
                    labelText: 'Actual balance',
                    hintText: '0.00',
                    prefixIcon: Icons.account_balance_wallet_outlined,
                    // Signed: a negative balance is allowed (D5).
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (value) {
                      final v = double.tryParse((value ?? '').trim());
                      if (v == null) return 'Enter a valid amount';
                      if (v.abs() > _maxAbs) return 'Amount is too large';
                      return null;
                    },
                  ),
                  if (hint.isNotEmpty) ...[
                    const SizedBox(height: AdipsSizes.xs),
                    Text(
                      hint,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: AdipsSizes.fontSizesSm,
                      ),
                    ),
                  ],
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  CustomTextField(
                    controller: _noteController,
                    labelText: 'Note (optional)',
                    hintText: 'e.g. Bank statement, 30 Sep',
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: AdipsSizes.sm),
                    Text(_error!, style: TextStyle(color: lossColor)),
                  ],
                  const SizedBox(height: AdipsSizes.spaceBtwSections),

                  CustomButton(
                    text: 'Adjust balance',
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                  const SizedBox(height: AdipsSizes.xs),
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
