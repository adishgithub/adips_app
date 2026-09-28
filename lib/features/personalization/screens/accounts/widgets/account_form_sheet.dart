// features/personalization/screens/accounts/widgets/account_form_sheet.dart
import 'package:flutter/material.dart';

import '../../../../../common/widgets/buttons/custom_elevated_button.dart';
import '../../../../../common/widgets/dropdowns/custom_dropdown.dart';
import '../../../../../common/widgets/pickers/icon_picker_sheet.dart';
import '../../../../../common/widgets/text_fields/custom_text_field.dart';
import '../../../../../data/services/account_service.dart';
import '../../../../../utils/constants/adips_category_colors.dart';
import '../../../../../utils/constants/adips_icons.dart';
import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/models/account_model.dart';
import '../../../../../utils/services/transaction_api.dart';

/// Currencies offered in the form. Same set AdipsFormatters knows a
/// symbol for; an existing account's own currency is always added to
/// the list so editing never hides its current value.
const List<String> _kCurrencies = ['INR', 'USD', 'EUR', 'GBP'];

/// Add (account == null) or edit an account. Returns true when
/// something was saved, so the caller knows to refresh.
///
/// [defaultCurrency] pre-fills the currency in "add" mode (the user's
/// settings currency).
Future<bool?> showAccountFormSheet({
  required BuildContext context,
  required String defaultCurrency,
  AccountModel? account,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AccountFormSheet(account: account, defaultCurrency: defaultCurrency),
  );
}

class _AccountFormSheet extends StatefulWidget {
  const _AccountFormSheet({required this.account, required this.defaultCurrency});

  final AccountModel? account;
  final String defaultCurrency;

  @override
  State<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<_AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final AccountService _service = AccountService();

  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late String _type;
  late String _currency;
  late int _iconId;
  late int _colorId;
  late bool _includeInTotal;
  late bool _isDefault;

  // While the user hasn't picked an icon themselves, changing the type
  // also swaps in that type's suggested icon (create mode only).
  bool _iconTouched = false;
  bool _saving = false;

  // null = still checking. Currency is locked once the account has
  // transactions (A3); the server would answer 409 anyway.
  bool? _hasTransactions;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameController = TextEditingController(text: a?.name ?? '');
    _balanceController = TextEditingController(
      text: a == null ? '' : _trimZeros(a.openingBalance),
    );
    _type = a?.type ?? 'bank';
    _currency = a?.currency ?? widget.defaultCurrency.toUpperCase();
    _iconId = a?.iconId ?? AccountTypeInfo.of(_type).defaultIconId;
    _colorId = a?.colorId ?? 4;
    _includeInTotal = a?.includeInTotal ?? true;
    _isDefault = a?.isDefault ?? false;
    _iconTouched = a != null;
    if (a != null) {
      _checkHistory(a.id);
    } else {
      _hasTransactions = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// One-row list call just to learn whether the account has history.
  Future<void> _checkHistory(int accountId) async {
    try {
      final rows = await TransactionApi.list(accountId: accountId, limit: 1);
      if (mounted) setState(() => _hasTransactions = rows.isNotEmpty);
    } catch (_) {
      // Can't tell: lock it. The server is the real gate anyway.
      if (mounted) setState(() => _hasTransactions = true);
    }
  }

  static String _trimZeros(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  List<String> get _currencyOptions {
    final list = [..._kCurrencies];
    if (!list.contains(_currency)) list.add(_currency);
    return list;
  }

  Future<void> _pickIcon() async {
    final picked = await showIconPickerSheet(
      context: context,
      selectedIconId: _iconId,
      accentColor: AdipsCategoryColors.byId(_colorId),
    );
    if (picked != null) {
      setState(() {
        _iconId = picked;
        _iconTouched = true;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final opening = double.tryParse(_balanceController.text.trim()) ?? 0;

    setState(() => _saving = true);
    try {
      final a = widget.account;
      if (a == null) {
        await _service.create(
          name: name,
          type: _type,
          currency: _currency,
          iconId: _iconId,
          colorId: _colorId,
          openingBalance: opening,
          includeInTotal: _includeInTotal,
          isDefault: _isDefault,
        );
      } else {
        // Send only what changed (the backend PATCH is partial).
        // isDefault is only ever sent as true: un-defaulting is done
        // by making another account the default (A5).
        final changed = name != a.name ||
            _type != a.type ||
            _currency != a.currency ||
            opening != a.openingBalance ||
            _iconId != a.iconId ||
            _colorId != a.colorId ||
            _includeInTotal != a.includeInTotal ||
            (_isDefault && !a.isDefault);
        if (!changed) {
          if (mounted) Navigator.of(context).pop(false);
          return;
        }
        await _service.update(
          a.id,
          name: name != a.name ? name : null,
          type: _type != a.type ? _type : null,
          currency: _currency != a.currency ? _currency : null,
          openingBalance: opening != a.openingBalance ? opening : null,
          iconId: _iconId != a.iconId ? _iconId : null,
          colorId: _colorId != a.colorId ? _colorId : null,
          includeInTotal: _includeInTotal != a.includeInTotal ? _includeInTotal : null,
          isDefault: (_isDefault && !a.isDefault) ? true : null,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      // Server messages are already user-readable (e.g. duplicate
      // name 409), so show them as-is.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final brandColor =
        isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;
    final accent = AdipsCategoryColors.byId(_colorId);

    final currencyLocked = _hasTransactions != false; // checking or has history
    final wasDefault = widget.account?.isDefault ?? false;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          margin: const EdgeInsets.all(AdipsSizes.sm),
          padding: const EdgeInsets.all(AdipsSizes.md),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusLg),
            border: Border.all(color: lineColor),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                    _isEditing ? 'Edit Account' : 'Add Account',
                    style: TextStyle(
                      fontSize: AdipsSizes.fontSizesLg,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AdipsSizes.md),

                  // Icon (tap to change) + color swatches
                  Center(
                    child: InkWell(
                      onTap: _pickIcon,
                      borderRadius: BorderRadius.circular(40),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: accent),
                            ),
                            child: Icon(AdipsIcons.byId(_iconId), size: 32, color: accent),
                          ),
                          const SizedBox(height: AdipsSizes.xs),
                          Text(
                            'Change icon',
                            style: TextStyle(
                              fontSize: AdipsSizes.fontSizesEs,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AdipsSizes.sm),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AdipsSizes.sm,
                    runSpacing: AdipsSizes.sm,
                    children: [
                      for (final entry in AdipsCategoryColors.all)
                        GestureDetector(
                          onTap: () => setState(() => _colorId = entry.key),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: entry.key == _colorId ? textColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: entry.key == _colorId
                                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AdipsSizes.md),

                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Name',
                    prefixIcon: Icons.account_balance_wallet_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  CustomDropdown<String>(
                    value: _type,
                    labelText: 'Type',
                    items: AccountTypeInfo.all.map((t) => t.value).toList(),
                    itemLabelBuilder: (v) => AccountTypeInfo.of(v).label,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _type = v;
                        if (!_iconTouched) _iconId = AccountTypeInfo.of(v).defaultIconId;
                      });
                    },
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  // Disabled look without touching the shared dropdown:
                  // ignore taps and dim it.
                  IgnorePointer(
                    ignoring: currencyLocked,
                    child: Opacity(
                      opacity: currencyLocked ? 0.5 : 1,
                      child: CustomDropdown<String>(
                        value: _currency,
                        labelText: 'Currency',
                        items: _currencyOptions,
                        itemLabelBuilder: (c) => '$c (${AdipsFormatters.symbolFor(c)})',
                        onChanged: (v) {
                          if (v != null) setState(() => _currency = v);
                        },
                      ),
                    ),
                  ),
                  if (currencyLocked && _isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: AdipsSizes.xs),
                      child: Text(
                        _hasTransactions == null
                            ? 'Checking whether the currency can be changed...'
                            : 'Currency can\'t be changed once an account has transactions.',
                        style: TextStyle(fontSize: AdipsSizes.fontSizesEs, color: mutedColor),
                      ),
                    ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  CustomTextField(
                    controller: _balanceController,
                    labelText: 'Opening balance',
                    hintText: '0',
                    prefixIcon: AdipsFormatters.iconFor(_currency),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final text = (v ?? '').trim();
                      if (text.isEmpty) return null; // blank = 0
                      final n = double.tryParse(text);
                      if (n == null) return 'Enter a valid amount';
                      if (n < 0) return 'Opening balance can\'t be negative';
                      return null;
                    },
                  ),
                  const SizedBox(height: AdipsSizes.sm),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: brandColor,
                    title: Text('Include in total', style: TextStyle(color: textColor)),
                    subtitle: Text(
                      'Count this account in your Home total balance',
                      style: TextStyle(fontSize: AdipsSizes.fontSizesEs, color: mutedColor),
                    ),
                    value: _includeInTotal,
                    onChanged: (v) => setState(() => _includeInTotal = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: brandColor,
                    title: Text('Make default', style: TextStyle(color: textColor)),
                    subtitle: Text(
                      wasDefault
                          ? 'This is your default. To change it, make another account the default.'
                          : 'New transactions start on the default account',
                      style: TextStyle(fontSize: AdipsSizes.fontSizesEs, color: mutedColor),
                    ),
                    value: _isDefault,
                    // The server refuses to un-default (A5: exactly one
                    // default), so lock it on for the current default.
                    onChanged: wasDefault ? null : (v) => setState(() => _isDefault = v),
                  ),
                  const SizedBox(height: AdipsSizes.md),

                  CustomButton(
                    text: _isEditing ? 'Save' : 'Add account',
                    isLoading: _saving,
                    onPressed: _save,
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
