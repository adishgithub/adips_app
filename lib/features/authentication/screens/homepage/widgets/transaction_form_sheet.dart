// widgets/transaction_form_sheet.dart
import 'package:adips/common/widgets/buttons/custom_elevated_button.dart';
import 'package:adips/common/widgets/dropdowns/custom_dropdown.dart';
import 'package:adips/common/widgets/text_fields/custom_text_field.dart';
import 'package:adips/features/authentication/controllers/home/home_controller.dart';
import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/helpers/helper_functions.dart';
import 'package:adips/utils/models/app_transaction.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _paymentMethodController;
  late final TextEditingController _noteController;
  late final TextEditingController _currencyController;

  late String _type; // credit | debit
  late String _status; // pending | completed | failed

  final HomeController _controller = HomeController.instance;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountController = TextEditingController(text: tx != null ? tx.amount.toStringAsFixed(2) : '');
    _categoryController = TextEditingController(text: tx?.category ?? '');
    _descriptionController = TextEditingController(text: tx?.description ?? '');
    _paymentMethodController = TextEditingController(text: tx?.paymentMethod ?? '');
    _noteController = TextEditingController(text: tx?.note ?? '');
    _currencyController = TextEditingController(text: tx?.currency ?? 'INR');
    _type = tx?.type ?? 'debit';
    _status = tx?.status ?? 'completed';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _paymentMethodController.dispose();
    _noteController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final amount = double.parse(_amountController.text.trim());
    bool ok;

    if (widget.isEditing) {
      ok = await _controller.updateTransaction(
        widget.transaction!.id,
        amount: amount,
        type: _type,
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        paymentMethod: _paymentMethodController.text.trim(),
        note: _noteController.text.trim(),
        currency: _currencyController.text.trim().toUpperCase(),
      );
    } else {
      ok = await _controller.createTransaction(
        amount: amount,
        type: _type,
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        paymentMethod: _paymentMethodController.text.trim(),
        note: _noteController.text.trim(),
        currency: _currencyController.text.trim().toUpperCase(),
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
                  widget.isEditing ? 'Edit Transaction' : 'Add Transaction',
                  style: TextStyle(fontSize: AdipsSizes.fontSizesXxl, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: AdipsSizes.spaceBtwSections),

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

                CustomDropdown<String>(
                  value: _type,
                  items: const ['credit', 'debit'],
                  labelText: 'Type',
                  itemLabelBuilder: (v) => v == 'credit' ? 'Income (credit)' : 'Expense (debit)',
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                CustomTextField(
                  controller: _categoryController,
                  labelText: 'Category',
                  hintText: 'e.g. Food, Salary, Rent',
                  prefixIcon: Icons.category_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Category is required' : null,
                ),
                const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'e.g. Groceries for the week',
                  prefixIcon: Icons.description_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                ),
                const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                CustomDropdown<String>(
                  value: _status,
                  items: const ['pending', 'completed', 'failed'],
                  labelText: 'Status',
                  itemLabelBuilder: (v) => v[0].toUpperCase() + v.substring(1),
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
                const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                CustomTextField(
                  controller: _paymentMethodController,
                  labelText: 'Payment Method',
                  hintText: 'e.g. UPI, Card, Cash',
                  prefixIcon: Icons.payment_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Payment method is required' : null,
                ),
                const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                CustomTextField(
                  controller: _currencyController,
                  labelText: 'Currency',
                  hintText: 'e.g. INR',
                  prefixIcon: Icons.language_outlined,
                  validator: (v) {
                    if (v == null || v.trim().length != 3) return 'Use a 3-letter code, e.g. INR';
                    return null;
                  },
                ),
                const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                CustomTextField(
                  controller: _noteController,
                  labelText: 'Note (optional)',
                  hintText: 'Anything extra you want to remember',
                  prefixIcon: Icons.notes_outlined,
                ),
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
                      label: const Text('Delete Transaction', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
