// widgets/transaction_form_sheet.dart
import 'package:adips/common/widgets/buttons/custom_elevated_button.dart';
import 'package:adips/common/widgets/dropdowns/custom_dropdown.dart';
import 'package:adips/common/widgets/pickers/category_picker_sheet.dart';
import 'package:adips/common/widgets/text_fields/custom_picker_field.dart';
import 'package:adips/common/widgets/text_fields/custom_text_field.dart';
import 'package:adips/data/services/settings_service.dart';
import 'package:adips/data/services/transaction_category_service.dart';
import 'package:adips/data/services/transaction_type_service.dart';
import 'package:adips/features/authentication/controllers/home/home_controller.dart';
import 'package:adips/utils/constants/adips_category_colors.dart';
import 'package:adips/utils/constants/adips_icons.dart';
import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/helpers/helper_functions.dart';
import 'package:adips/utils/models/app_transaction.dart';
import 'package:adips/utils/models/transaction_category_model.dart';
import 'package:adips/utils/models/transaction_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Payment method is a fixed, hardcoded picklist — every transaction
/// is settled through one of these rails, so there's no need for it
/// to be free text like it used to be.
const List<String> _paymentMethods = ['UPI', 'CASH', 'CARD', 'BANK'];

/// Opens the add/edit sheet. Pass an existing [transaction] to edit +
/// delete it; pass null to create a new one.
Future<void> showTransactionFormSheet(BuildContext context, {AppTransaction? transaction}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TransactionFormSheet(transaction: transaction),
  );
}

class TransactionFormSheet extends StatefulWidget {
  const TransactionFormSheet({super.key, this.transaction});

  final AppTransaction? transaction;

  bool get isEditing => transaction != null;

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();

  final TransactionTypeService _typeService = TransactionTypeService();
  final TransactionCategoryService _categoryService = TransactionCategoryService();
  final SettingsService _settingsService = SettingsService();
  final HomeController _controller = HomeController.instance;

  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _noteController;

  List<TransactionTypeModel> _types = [];
  List<TransactionCategoryModel> _categories = [];
  TransactionCategoryModel? _selectedCategory;

  late DateTime _date;
  late String _status; // pending | completed | failed
  late String _paymentMethod;

  /// Fetched from Settings, never user-editable here — the amount is
  /// always logged in the account's configured currency.
  String _currency = 'INR';

  bool _loadingOptions = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountController =
        TextEditingController(text: tx != null ? tx.amount.toStringAsFixed(2) : '');
    _descriptionController = TextEditingController(text: tx?.description ?? '');
    _noteController = TextEditingController(text: tx?.note ?? '');
    _date = tx?.transactionDate ?? DateTime.now();
    _status = tx?.status ?? 'completed';
    _paymentMethod = _normalizePaymentMethod(tx?.paymentMethod);
    if (tx != null) _currency = tx.currency;
    _loadOptions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Old transactions may carry a payment method from before this was
  /// a fixed list (e.g. "Net Banking", "Wallet", lowercase "upi").
  /// Match case-insensitively against the hardcoded list and fall
  /// back to the first option rather than crashing the dropdown on
  /// an unknown value.
  String _normalizePaymentMethod(String? raw) {
    if (raw == null) return _paymentMethods.first;
    final match = _paymentMethods.where((m) => m.toLowerCase() == raw.toLowerCase());
    return match.isNotEmpty ? match.first : _paymentMethods.first;
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loadingOptions = true;
      _loadError = null;
    });
    try {
      final types = await _typeService.list();
      final categories = await _categoryService.list();
      final settings = await _settingsService.getSettings();

      TransactionCategoryModel? initialCategory;
      final tx = widget.transaction;
      if (tx != null) {
        final matches = categories.where(
              (c) => c.name.toLowerCase() == tx.category.toLowerCase(),
        );
        if (matches.isNotEmpty) initialCategory = matches.first;
        // If no match (category renamed/deleted since), leave
        // initialCategory null — the field falls back to showing
        // tx.category / tx.categoryIconId directly (see build()), and
        // the user can explicitly pick a replacement category.
      } else if (categories.isNotEmpty) {
        initialCategory = categories.first;
      }

      if (mounted) {
        setState(() {
          _types = types;
          _categories = categories;
          _selectedCategory = initialCategory;
          if (tx == null) _currency = settings.currency;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingOptions = false);
    }
  }

  /// The backend's Transaction.Type is a credit/debit *direction*,
  /// separate from the per-user Income/Expense/Transfer TransactionType
  /// resource managed in Settings. Income maps to a credit; every
  /// other type (Expense, Transfer, or a custom type) maps to a debit
  /// (money leaving the account).
  String _directionFor(int transactionTypeId) {
    final match = _types.where((t) => t.id == transactionTypeId);
    if (match.isEmpty) return 'debit';
    return match.first.name.toLowerCase() == 'income' ? 'credit' : 'debit';
  }

  Future<void> _pickCategory() async {
    final picked = await showCategoryPickerSheet(
      context: context,
      types: _types,
      categories: _categories,
      selected: _selectedCategory,
    );
    if (picked != null) setState(() => _selectedCategory = picked);
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
        // Keep the original time-of-day (or "now") instead of
        // resetting to midnight, so ordering within the same day
        // stays sensible.
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
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a category')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final amount = double.parse(_amountController.text.trim());
    final category = _selectedCategory!;
    final direction = _directionFor(category.transactionTypeId);
    bool ok;

    if (widget.isEditing) {
      ok = await _controller.updateTransaction(
        widget.transaction!.id,
        amount: amount,
        type: direction,
        category: category.name,
        categoryIconId: category.iconId,
        categoryColorId: category.colorId,
        description: _descriptionController.text.trim(),
        status: _status,
        paymentMethod: _paymentMethod,
        note: _noteController.text.trim(),
        currency: _currency,
        transactionDate: _date,
      );
    } else {
      ok = await _controller.createTransaction(
        amount: amount,
        type: direction,
        category: category.name,
        categoryIconId: category.iconId,
        categoryColorId: category.colorId,
        description: _descriptionController.text.trim(),
        status: _status,
        paymentMethod: _paymentMethod,
        note: _noteController.text.trim(),
        currency: _currency,
        transactionDate: _date,
      );
    }

    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
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

    final ok = await _controller.deleteTransaction(widget.transaction!.id);
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;

    // What the category field displays: the picked category's name,
    // or — if editing a transaction whose category couldn't be
    // matched to a current one (renamed/deleted) — the name saved on
    // the transaction itself, so the field is never blank.
    final String categoryLabel = _selectedCategory?.name ?? widget.transaction?.category ?? '';
    final IconData categoryIcon = _selectedCategory != null
        ? AdipsIcons.byId(_selectedCategory!.iconId)
        : (widget.transaction != null && widget.transaction!.categoryIconId > 0
        ? AdipsIcons.byId(widget.transaction!.categoryIconId)
        : Icons.category_outlined);
    final Color categoryIconColor = _selectedCategory != null
        ? AdipsCategoryColors.byId(_selectedCategory!.colorId)
        : (widget.transaction != null && widget.transaction!.categoryColorId > 0
        ? AdipsCategoryColors.byId(widget.transaction!.categoryColorId)
        : mutedColor);

    return Padding(
      // Keeps the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AdipsSizes.cardRadiusLg)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AdipsSizes.defaultSpace,
          AdipsSizes.sm,
          AdipsSizes.defaultSpace,
          AdipsSizes.defaultSpace,
        ),
        child: SafeArea(
          top: false,
          child: _loadingOptions
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          )
              : _loadError != null
              ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: AdipsSizes.sm),
                TextButton(onPressed: _loadOptions, child: const Text('Retry')),
              ],
            ),
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
                      margin: const EdgeInsets.only(bottom: AdipsSizes.spaceBtwItems),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    widget.isEditing ? 'Edit Transaction' : 'Add Transaction',
                    style: TextStyle(
                      fontSize: AdipsSizes.fontSizesXxl,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwSections),

                  // Amount
                  CustomTextField(
                    controller: _amountController,
                    labelText: 'Amount',
                    hintText: 'e.g. 500',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Icons.currency_rupee,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Amount is required';
                      final parsed = double.tryParse(v.trim());
                      if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  // Category — a single picker that carries the
                  // category's type/direction, icon, and color
                  // together (see Settings > Categories for the
                  // same icon/color pairing).
                  CustomPickerField(
                    labelText: 'Category',
                    valueText: categoryLabel,
                    leading: Icon(categoryIcon, color: categoryIconColor),
                    onTap: _pickCategory,
                    validator: (_) =>
                    _selectedCategory == null ? 'Select a category' : null,
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  // Date — defaults to today, editable via the
                  // native date picker.
                  CustomPickerField(
                    labelText: 'Date',
                    valueText: DateFormat('d MMM yyyy').format(_date),
                    leading: const Icon(Icons.calendar_today_outlined),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    labelText: 'Description',
                    hintText: 'e.g. Groceries for the week',
                    prefixIcon: Icons.description_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  // Status
                  CustomDropdown<String>(
                    value: _status,
                    items: const ['pending', 'completed', 'failed'],
                    labelText: 'Status',
                    itemLabelBuilder: (v) => v[0].toUpperCase() + v.substring(1),
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  // Payment Method — fixed picklist.
                  CustomDropdown<String>(
                    value: _paymentMethod,
                    items: _paymentMethods,
                    labelText: 'Payment Method',
                    itemLabelBuilder: (v) => v,
                    onChanged: (v) =>
                        setState(() => _paymentMethod = v ?? _paymentMethod),
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  // Note — optional
                  CustomTextField(
                    controller: _noteController,
                    labelText: 'Note (optional)',
                    hintText: 'Anything extra you want to remember',
                    prefixIcon: Icons.notes_outlined,
                  ),
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                  // Currency is fetched from Settings (see
                  // _loadOptions) and sent as-is on every
                  // create/update request below. It is never
                  // shown or editable in this form, or
                  // anywhere else in the app — the account
                  // has exactly one currency.
                  const SizedBox(height: AdipsSizes.spaceBtwSections),

                  Obx(
                        () => CustomButton(
                      text: widget.isEditing ? 'Save Changes' : 'Add Transaction',
                      isLoading: _controller.isMutating.value,
                      onPressed: _save,
                    ),
                  ),

                  if (widget.isEditing) ...[
                    const SizedBox(height: AdipsSizes.spaceBtwItems),
                    Obx(
                          () => TextButton.icon(
                        onPressed: _controller.isMutating.value ? null : _confirmDelete,
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text(
                          'Delete Transaction',
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