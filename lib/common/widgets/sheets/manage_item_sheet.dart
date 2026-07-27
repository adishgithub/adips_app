// common/widgets/sheets/manage_item_sheet.dart
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_category_colors.dart';
import '../../../utils/constants/adips_icons.dart';
import '../../../utils/constants/adips_palette.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../buttons/custom_elevated_button.dart';
import '../dropdowns/custom_dropdown.dart';
import '../pickers/icon_picker_sheet.dart';

/// One entry for the optional "type" dropdown shown when editing a
/// category (a transaction type has no such dropdown — it *is* the
/// type). Kept generic here so this sheet doesn't need to import the
/// TransactionTypeModel directly.
class ManageItemTypeOption {
  const ManageItemTypeOption({required this.id, required this.label});
  final int id;
  final String label;
}

/// Shared edit sheet used by both the Transaction Types screen and
/// the Categories screen — same name field, icon picker, and delete
/// button; the type dropdown only renders when [typeOptions] is
/// passed in (i.e. only for categories).
///
/// Returns true if the item was saved or deleted (so the caller knows
/// to refresh its list), false/null otherwise.
Future<bool?> showManageItemSheet({
  required BuildContext context,
  required String title,
  required String initialName,
  required int initialIconId,
  required int initialColorId,
  required bool isDefault,
  List<ManageItemTypeOption>? typeOptions,
  int? initialTypeId,
  required Future<void> Function({
    required String name,
    required int iconId,
    int? typeId,
  }) onSave,
  required Future<void> Function() onDelete,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ManageItemSheet(
      title: title,
      initialName: initialName,
      initialIconId: initialIconId,
      initialColorId: initialColorId,
      isDefault: isDefault,
      typeOptions: typeOptions,
      initialTypeId: initialTypeId,
      onSave: onSave,
      onDelete: onDelete,
    ),
  );
}

class _ManageItemSheet extends StatefulWidget {
  const _ManageItemSheet({
    required this.title,
    required this.initialName,
    required this.initialIconId,
    required this.initialColorId,
    required this.isDefault,
    required this.typeOptions,
    required this.initialTypeId,
    required this.onSave,
    required this.onDelete,
  });

  final String title;
  final String initialName;
  final int initialIconId;
  final int initialColorId;
  final bool isDefault;
  final List<ManageItemTypeOption>? typeOptions;
  final int? initialTypeId;
  final Future<void> Function({required String name, required int iconId, int? typeId}) onSave;
  final Future<void> Function() onDelete;

  @override
  State<_ManageItemSheet> createState() => _ManageItemSheetState();
}

class _ManageItemSheetState extends State<_ManageItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _iconId;
  late int? _typeId;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _iconId = widget.initialIconId;
    _typeId = widget.initialTypeId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon(Color accentColor) async {
    final picked = await showIconPickerSheet(
      context: context,
      selectedIconId: _iconId,
      accentColor: accentColor,
    );
    if (picked != null) setState(() => _iconId = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(name: _nameController.text.trim(), iconId: _iconId, typeId: _typeId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onDelete();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;
    final accentColor = AdipsCategoryColors.byId(widget.initialColorId);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AdipsSizes.sm),
          padding: const EdgeInsets.all(AdipsSizes.md),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusLg),
            border: Border.all(color: lineColor),
          ),
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
                  widget.title,
                  style: TextStyle(
                    fontSize: AdipsSizes.fontSizesLg,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AdipsSizes.md),

                // Icon picker button
                Center(
                  child: InkWell(
                    onTap: () => _pickIcon(accentColor),
                    borderRadius: BorderRadius.circular(40),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor),
                          ),
                          child: Icon(AdipsIcons.byId(_iconId), size: 32, color: accentColor),
                        ),
                        const SizedBox(height: AdipsSizes.xs),
                        Text(
                          'Change icon',
                          style: TextStyle(fontSize: AdipsSizes.fontSizesEs, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AdipsSizes.md),

                // Name field
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    filled: true,
                    fillColor: isDark ? AdipsPalette.darkCanvas : AdipsPalette.lightCanvas,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
                      borderSide: BorderSide(color: lineColor),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Name is required' : null,
                ),

                // Type dropdown — categories only
                if (widget.typeOptions != null) ...[
                  const SizedBox(height: AdipsSizes.spaceBtwInputFields),
                  CustomDropdown<int>(
                    value: _typeId,
                    labelText: 'Transaction Type',
                    items: widget.typeOptions!.map((t) => t.id).toList(),
                    itemLabelBuilder: (id) =>
                        widget.typeOptions!.firstWhere((t) => t.id == id).label,
                    onChanged: (value) => setState(() => _typeId = value),
                    validator: (value) => value == null ? 'Select a type' : null,
                  ),
                ],

                const SizedBox(height: AdipsSizes.spaceBtwSections),

                CustomButton(
                  text: 'Save',
                  isLoading: _isSaving,
                  onPressed: _isDeleting ? null : _save,
                ),
                const SizedBox(height: AdipsSizes.sm),

                // Delete — hidden entirely for system-default items,
                // which the backend rejects deleting anyway.
                if (!widget.isDefault)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving || _isDeleting ? null : _delete,
                      icon: _isDeleting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: lossColor),
                            )
                          : Icon(Icons.delete_outline_rounded, color: lossColor),
                      label: Text('Delete', style: TextStyle(color: lossColor)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: lossColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AdipsSizes.buttonRadius),
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'Default items can\'t be deleted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: AdipsSizes.fontSizesEs, color: mutedColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
