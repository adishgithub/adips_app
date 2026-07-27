// common/widgets/list_tiles/manageable_item_tile.dart
import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';

/// A single row for an editable, icon+color item (a transaction type
/// or a category): colored icon circle, title, optional subtitle,
/// chevron. Shared by TransactionTypesScreen and CategoriesScreen so
/// both list rows look and behave identically.
class ManageableItemTile extends StatelessWidget {
  const ManageableItemTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.surfaceColor,
    required this.lineColor,
    required this.textColor,
    required this.mutedColor,
    this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Color surfaceColor;
  final Color lineColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusMd),
        border: Border.all(color: lineColor),
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: mutedColor)) : null,
        trailing: Icon(Icons.chevron_right_rounded, color: mutedColor),
      ),
    );
  }
}
