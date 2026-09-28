// widgets/transfer_form_sheet.dart
import 'package:adips/common/widgets/buttons/custom_elevated_button.dart';
import 'package:adips/common/widgets/pickers/account_picker_sheet.dart';
import 'package:adips/common/widgets/text_fields/custom_picker_field.dart';
import 'package:adips/common/widgets/text_fields/custom_text_field.dart';
import 'package:adips/features/authentication/controllers/accounts/account_controller.dart';
import 'package:adips/features/authentication/controllers/home/home_controller.dart';
import 'package:adips/utils/constants/adips_category_colors.dart';
import 'package:adips/utils/constants/adips_icons.dart';
import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/helpers/helper_functions.dart';
import 'package:adips/utils/models/account_model.dart';
import 'package:adips/utils/models/transfer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Opens the transfer sheet. Pass an existing [transfer] to edit or
/// delete it (both legs change together, X6); pass null to create one.
Future<void> showTransferFormSheet(BuildContext context, {TransferModel? transfer}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TransferFormSheet(transfer: transfer),
  );
}

class TransferFormSheet extends StatefulWidget {
  const TransferFormSheet({super.key, this.transfer});

  final TransferModel? transfer;

  bool get isEditing => transfer != null;

  @override
  State<TransferFormSheet> createState() => _TransferFormSheetState();
}

class _TransferFormSheetState extends State<TransferFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final HomeController _controller = HomeController.instance;
  final AccountController _accounts = AccountController.instance;

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _date;

  /// Null while editing a transfer whose account was archived since
  /// (the field then shows the name saved on the transfer and the
  /// account is left unchanged on save).
  AccountModel? _from;
  AccountModel? _to;

  /// Edit mode only: true once changing From forced To to be cleared
  /// (different currency, or same as the new From). To then must be
  /// picked again instead of silently keeping the old account.
  bool _toCleared = false;

  bool _loadingAccounts = false;

  /// Both accounts always share a currency (X3), so it follows From.
  String get _currency => _from?.currency ?? widget.transfer?.currency ?? 'INR';

  @override
  void initState() {
    super.initState();
    final t = widget.transfer;
    _amountController =
        TextEditingController(text: t != null ? t.amount.toStringAsFixed(2) : '');
    _noteController = TextEditingController(text: t?.note ?? '');
    _date = t?.transactionDate ?? DateTime.now();
    // Rebuild on every keystroke so the overdraft warning stays live.
    _amountController.addListener(() => setState(() {}));
    _selectInitialAccounts();
    if (_accounts.accounts.isEmpty) _loadAccounts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectInitialAccounts() {
    final t = widget.transfer;
    if (t != null) {
      _from = _accounts.byId(t.fromAccountId);
      _to = _accounts.byId(t.toAccountId);
    } else {
      // New transfer: money usually leaves the default account.
      _from = _accounts.defaultAccount;
    }
  }

  /// Home normally has accounts loaded already; fetch only if not.
  Future<void> _loadAccounts() async {
    setState(() => _loadingAccounts = true);
    await _accounts.load();
    if (!mounted) return;
    setState(() {
      _selectInitialAccounts();
      _loadingAccounts = false;
    });
  }

  Future<void> _pickFrom() async {
    final picked = await showAccountPickerSheet(
      context: context,
      accounts: _accounts.activeAccounts,
      selected: _from,
      title: 'Transfer from',
      emptyMessage: 'No accounts yet — add one in Settings > Accounts.',
    );
    if (picked == null) return;
    setState(() {
      _from = picked;
      // To must differ from From and share its currency (X1, X3).
      if (_to != null && (_to!.id == picked.id || _to!.currency != picked.currency)) {
        _to = null;
        _toCleared = true;
      }
    });
  }

  Future<void> _pickTo() async {
    // Only same-currency accounts, and never the source (X1, X3).
    final options = _accounts.activeAccounts
        .where((a) => a.id != _from?.id && a.currency == _currency)
        .toList();
    final picked = await showAccountPickerSheet(
      context: context,
      accounts: options,
      selected: _to,
      title: 'Transfer to',
      emptyMessage: 'No other $_currency accounts to transfer to.',
    );
    if (picked != null) {
      setState(() {
        _to = picked;
        _toCleared = false;
      });
    }
  }

  void _swap() {
    if (_from == null || _to == null) return;
    setState(() {
      final tmp = _from;
      _from = _to;
      _to = tmp;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        // Keep the time-of-day so ordering within a day stays sensible.
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
          _date.second,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();
    bool ok;

    if (widget.isEditing) {
      final t = widget.transfer!;
      // Send only what changed (backend PATCH is partial).
      final fromId = (_from != null && _from!.id != t.fromAccountId) ? _from!.id : null;
      final toId = (_to != null && _to!.id != t.toAccountId) ? _to!.id : null;
      final newAmount = (amount - t.amount).abs() > 0.004 ? amount : null;
      final newDate = !_date.isAtSameMomentAs(t.transactionDate) ? _date : null;
      final newNote = note != t.note ? note : null;

      if (fromId == null &&
          toId == null &&
          newAmount == null &&
          newDate == null &&
          newNote == null) {
        Navigator.of(context).pop();
        return;
      }
      ok = await _controller.updateTransfer(
        t.transferGroupId,
        fromAccountId: fromId,
        toAccountId: toId,
        amount: newAmount,
        transactionDate: newDate,
        note: newNote,
      );
    } else {
      ok = await _controller.createTransfer(
        fromAccountId: _from!.id,
        toAccountId: _to!.id,
        amount: amount,
        transactionDate: _date,
        note: note,
      );
    }

    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transfer?'),
        content: const Text(
          'Both sides of the transfer are removed and both account '
          'balances go back to what they were. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await _controller.deleteTransfer(widget.transfer!.transferGroupId);
    if (ok && mounted) Navigator.of(context).pop();
  }

  Widget _accountLeading(AccountModel? a, Color mutedColor) => Icon(
        a != null ? AdipsIcons.byId(a.iconId) : Icons.account_balance_wallet_outlined,
        color: a != null ? AdipsCategoryColors.byId(a.colorId) : mutedColor,
      );

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final cautionColor = isDark ? AdipsPalette.darkCaution : AdipsPalette.lightCaution;
    final brandColor =
        isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;

    // Soft overdraft warning (X8): informs, never blocks. Only on
    // create, where the source balance doesn't yet include this
    // transfer.
    final parsedAmount = double.tryParse(_amountController.text.trim());
    final bool overdraws = !widget.isEditing &&
        _from != null &&
        parsedAmount != null &&
        parsedAmount > _from!.currentBalance;

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
          child: _loadingAccounts
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
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
                            margin:
                                const EdgeInsets.only(bottom: AdipsSizes.spaceBtwItems),
                            decoration: BoxDecoration(
                              color: textColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Text(
                          widget.isEditing ? 'Edit Transfer' : 'Transfer',
                          style: TextStyle(
                            fontSize: AdipsSizes.fontSizesXxl,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: AdipsSizes.spaceBtwSections),

                        // From
                        CustomPickerField(
                          labelText: 'From',
                          valueText: _from?.name ?? widget.transfer?.fromAccountName ?? '',
                          leading: _accountLeading(_from, mutedColor),
                          onTap: _pickFrom,
                          validator: (_) => (_from == null && !widget.isEditing)
                              ? 'Select the source account'
                              : null,
                        ),

                        // Swap From <-> To
                        Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            tooltip: 'Swap accounts',
                            icon: Icon(Icons.swap_vert_rounded, color: brandColor),
                            onPressed: (_from != null && _to != null) ? _swap : null,
                          ),
                        ),

                        // To — same currency as From, never From itself.
                        CustomPickerField(
                          labelText: 'To',
                          valueText: _to?.name ??
                              (_toCleared ? '' : widget.transfer?.toAccountName ?? ''),
                          leading: _accountLeading(_to, mutedColor),
                          onTap: _pickTo,
                          validator: (_) {
                            if (_to == null && (!widget.isEditing || _toCleared)) {
                              return 'Select the destination account';
                            }
                            if (_from != null && _to != null && _from!.id == _to!.id) {
                              return 'From and To must be different';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                        // Amount, in the accounts' currency.
                        CustomTextField(
                          controller: _amountController,
                          labelText: 'Amount',
                          hintText: 'e.g. 2000',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: AdipsFormatters.iconFor(_currency),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Amount is required';
                            final parsed = double.tryParse(v.trim());
                            if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                            return null;
                          },
                        ),
                        if (overdraws)
                          Padding(
                            padding: const EdgeInsets.only(top: AdipsSizes.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    size: 16, color: cautionColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${_from!.name} has '
                                    '${AdipsFormatters.money(_from!.currentBalance, _from!.currency)}'
                                    ', so this will overdraw it. You can still continue.',
                                    style: TextStyle(
                                      fontSize: AdipsSizes.fontSizesEs,
                                      color: cautionColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                        // Date
                        CustomPickerField(
                          labelText: 'Date',
                          valueText: DateFormat('d MMM yyyy').format(_date),
                          leading: const Icon(Icons.calendar_today_outlined),
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                        // Note — optional
                        CustomTextField(
                          controller: _noteController,
                          labelText: 'Note (optional)',
                          hintText: 'e.g. Cash withdrawal',
                          prefixIcon: Icons.notes_outlined,
                        ),
                        const SizedBox(height: AdipsSizes.spaceBtwSections),

                        Obx(
                          () => CustomButton(
                            text: widget.isEditing ? 'Save Changes' : 'Transfer',
                            isLoading: _controller.isMutating.value,
                            onPressed: _save,
                          ),
                        ),

                        if (widget.isEditing) ...[
                          const SizedBox(height: AdipsSizes.spaceBtwItems),
                          Obx(
                            () => TextButton.icon(
                              onPressed:
                                  _controller.isMutating.value ? null : _confirmDelete,
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              label: const Text(
                                'Delete Transfer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
