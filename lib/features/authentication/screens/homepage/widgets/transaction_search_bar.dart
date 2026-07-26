// widgets/transaction_search_bar.dart
import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class TransactionSearchBar extends StatelessWidget {
  const TransactionSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final hintColor = isDark
        ? AdipsPalette.darkTextFieldPlaceHolderText
        : AdipsPalette.lightTextFieldPlaceHolderText;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
        border: Border.all(color: lineColor),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintText: 'Search transactions...',
          hintStyle: TextStyle(fontSize: 14, color: hintColor),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: hintColor),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
            icon: Icon(Icons.close_rounded, size: 18, color: hintColor),
            onPressed: () {
              controller.clear();
              onChanged('');
            },
          ),
        ),
      ),
    );
  }
}