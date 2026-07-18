import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

/// A basic, reusable dropdown field. Generic over [T] so it can be used
/// for currency, category, or any other picklist.
/// No dark/light mode handling — plain fixed colors only.
class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.itemLabelBuilder,
    this.prefixIcon,
    this.validator,
  });

  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? labelText;
  final String? hintText;

  /// How to turn an item of type [T] into display text.
  /// Defaults to `item.toString()` if not provided.
  final String Function(T item)? itemLabelBuilder;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabelBuilder != null ? itemLabelBuilder!(item) : item.toString(),
          ),
        ),
      )
          .toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdipsSizes.md,
          vertical: AdipsSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}