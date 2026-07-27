// features/personalization/screens/add_transaction/add_transaction_screen.dart
import 'package:flutter/material.dart';

import '../../../../common/widgets/buttons/custom_elevated_button.dart';
import '../../../../common/widgets/dropdowns/custom_dropdown.dart';
import '../../../../common/widgets/text_fields/custom_text_field.dart';
import '../../../../data/services/transaction_category_service.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/services/transaction_type_service.dart';
import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/models/transaction_category_model.dart';
import '../../../../utils/models/transaction_type_model.dart';

const List<String> _statusOptions = ['Pending', 'Done', 'Failed'];
const List<String> _paymentMethods = ['UPI', 'Card', 'Cash', 'Net Banking', 'Wallet', 'Other'];
const List<String> _currencies = ['INR', 'USD', 'EUR'];

/// Opens the Add Transaction sheet. Returns true if a transaction was
/// created, so the caller (home screen) knows to refresh its list.
Future<bool?> showAddTransactionSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddTransactionSheet(),
  );
}

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final TransactionTypeService _typeService = TransactionTypeService();
  final TransactionCategoryService _categoryService = TransactionCategoryService();
  final TransactionService _transactionService = TransactionService();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  List<TransactionTypeModel> _types = [];
  List<TransactionCategoryModel> _categories = [];
  TransactionTypeModel? _selectedType;
  TransactionCategoryModel? _selectedCategory;

  String _status = 'Done'; // default
  String _paymentMethod = 'UPI'; // default
  String _currency = 'INR'; // default

  bool _loadingTypes = true;
  bool _loadingCategories = false;
  bool _submitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    setState(() {
      _loadingTypes = true;
      _loadError = null;
    });
    try {
      final types = await _typeService.list();
      if (mounted) {
        setState(() {
          _types = types;
          _selectedType = types.isNotEmpty ? types.first : null;
        });
      }
      if (_selectedType != null) await _loadCategories(_selectedType!);
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingTypes = false);
    }
  }

  Future<void> _loadCategories(TransactionTypeModel type) async {
    setState(() {
      _loadingCategories = true;
      _selectedCategory = null;
    });
    try {
      final categories = await _categoryService.list(typeName: type.name);
      if (mounted) {
        setState(() {
          _categories = categories;
          _selectedCategory = categories.isNotEmpty ? categories.first : null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not load categories: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  /// The backend's Transaction.Type is a credit/debit *direction*,
  /// separate from the per-user Income/Expense/Transfer TransactionType
  /// resource managed in Settings. Income maps to a credit; Expense
  /// and Transfer both map to a debit (money leaving the account).
  String _directionFor(TransactionTypeModel type) {
    return type.name.toLowerCase() == 'income' ? 'credit' : 'debit';
  }

  String get _statusValue {
    switch (_status) {
      case 'Pending':
        return 'pending';
      case 'Failed':
        return 'failed';
      case 'Done':
      default:
        return 'completed';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null || _selectedCategory == null) return;

    setState(() => _submitting = true);
    try {
      await _transactionService.create(
        amount: double.parse(_amountController.text.trim()),
        type: _directionFor(_selectedType!),
        category: _selectedCategory!.name,
        description: _descriptionController.text.trim(),
        status: _statusValue,
        paymentMethod: _paymentMethod,
        note: _noteController.text.trim(),
        currency: _currency,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;

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
          child: _loadingTypes
              ? const Center(
                  heightFactor: 4,
                  child: CircularProgressIndicator(),
                )
              : _loadError != null
                  ? Center(
                      heightFactor: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_loadError!, textAlign: TextAlign.center),
                          const SizedBox(height: AdipsSizes.sm),
                          TextButton(onPressed: _loadTypes, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
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
                              'Add Transaction',
                              style: TextStyle(
                                fontSize: AdipsSizes.fontSizesLg,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: AdipsSizes.md),

                            // Amount — not null
                            CustomTextField(
                              controller: _amountController,
                              labelText: 'Amount',
                              hintText: '0.00',
                              prefixIcon: Icons.currency_rupee_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                final amount = double.tryParse((value ?? '').trim());
                                if (amount == null || amount <= 0) {
                                  return 'Enter a valid amount';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                            // Type + Category — same reusable dropdown widget, linked
                            CustomDropdown<TransactionTypeModel>(
                              value: _selectedType,
                              labelText: 'Type',
                              items: _types,
                              itemLabelBuilder: (t) => t.name,
                              onChanged: (type) {
                                if (type == null) return;
                                setState(() => _selectedType = type);
                                _loadCategories(type);
                              },
                              validator: (value) => value == null ? 'Select a type' : null,
                            ),
                            const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                            _loadingCategories
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: AdipsSizes.sm),
                                    child: LinearProgressIndicator(),
                                  )
                                : CustomDropdown<TransactionCategoryModel>(
                                    value: _selectedCategory,
                                    labelText: 'Category',
                                    items: _categories,
                                    itemLabelBuilder: (c) => c.name,
                                    onChanged: (category) =>
                                        setState(() => _selectedCategory = category),
                                    validator: (value) =>
                                        value == null ? 'Select a category' : null,
                                  ),
                            const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                            // Description
                            CustomTextField(
                              controller: _descriptionController,
                              labelText: 'Description',
                              hintText: 'e.g. Dinner with friends',
                              validator: (value) => (value == null || value.trim().isEmpty)
                                  ? 'Description is required'
                                  : null,
                            ),
                            const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                            // Status — not null, default Done
                            CustomDropdown<String>(
                              value: _status,
                              labelText: 'Status',
                              items: _statusOptions,
                              itemLabelBuilder: (s) => s,
                              onChanged: (value) => setState(() => _status = value ?? _status),
                            ),
                            const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                            // Payment Method — default UPI
                            CustomDropdown<String>(
                              value: _paymentMethod,
                              labelText: 'Payment Method',
                              items: _paymentMethods,
                              itemLabelBuilder: (s) => s,
                              onChanged: (value) =>
                                  setState(() => _paymentMethod = value ?? _paymentMethod),
                            ),
                            const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                            // Note — optional
                            CustomTextField(
                              controller: _noteController,
                              labelText: 'Note (optional)',
                              hintText: 'Anything else to remember',
                            ),
                            const SizedBox(height: AdipsSizes.spaceBtwInputFields),

                            // Currency — default INR
                            CustomDropdown<String>(
                              value: _currency,
                              labelText: 'Currency',
                              items: _currencies,
                              itemLabelBuilder: (s) => s,
                              onChanged: (value) => setState(() => _currency = value ?? _currency),
                            ),
                            const SizedBox(height: AdipsSizes.spaceBtwSections),

                            CustomButton(
                              text: 'Add Transaction',
                              isLoading: _submitting,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: AdipsSizes.sm),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
