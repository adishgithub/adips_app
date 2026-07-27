// features/personalization/screens/categories/categories_screen.dart
import 'package:flutter/material.dart';

import '../../../../common/widgets/list_tiles/manageable_item_tile.dart';
import '../../../../common/widgets/sheets/manage_item_sheet.dart';
import '../../../../data/services/transaction_category_service.dart';
import '../../../../data/services/transaction_type_service.dart';
import '../../../../utils/constants/adips_category_colors.dart';
import '../../../../utils/constants/adips_icons.dart';
import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/models/transaction_category_model.dart';
import '../../../../utils/models/transaction_type_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TransactionTypeService _typeService = TransactionTypeService();
  final TransactionCategoryService _categoryService = TransactionCategoryService();

  List<TransactionTypeModel> _types = [];
  List<TransactionCategoryModel> _categories = [];
  int? _selectedTypeId; // null == "All"
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final types = await _typeService.list();
      final categories = await _categoryService.list();
      // Keep whatever's already rendered as the default sort within
      // each type: sort_order ASC, same as the backend's own ordering.
      categories.sort((a, b) {
        if (a.transactionTypeId != b.transactionTypeId) {
          return a.transactionTypeId.compareTo(b.transactionTypeId);
        }
        return a.sortOrder.compareTo(b.sortOrder);
      });
      if (mounted) {
        setState(() {
          _types = types;
          _categories = categories;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<TransactionCategoryModel> get _visibleCategories {
    if (_selectedTypeId == null) return _categories;
    return _categories.where((c) => c.transactionTypeId == _selectedTypeId).toList();
  }

  String _typeName(int typeId) {
    final match = _types.where((t) => t.id == typeId);
    return match.isEmpty ? '' : match.first.name;
  }

  Future<void> _openEditSheet(TransactionCategoryModel category) async {
    final changed = await showManageItemSheet(
      context: context,
      title: 'Edit Category',
      initialName: category.name,
      initialIconId: category.iconId,
      initialColorId: category.colorId,
      isDefault: category.isDefault,
      typeOptions:
          _types.map((t) => ManageItemTypeOption(id: t.id, label: t.name)).toList(),
      initialTypeId: category.transactionTypeId,
      onSave: ({required name, required iconId, typeId}) async {
        await _categoryService.update(
          category.id,
          name: name,
          iconId: iconId,
          transactionTypeId: typeId,
        );
      },
      onDelete: () async {
        await _categoryService.delete(category.id);
      },
    );
    if (changed == true) _load();
  }

  /// Persists a drag-reorder within the currently filtered (single
  /// type) list — reordering only ever makes sense within one type
  /// since sort_order is scoped per user+type on the backend.
  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    final visible = List<TransactionCategoryModel>.from(_visibleCategories);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);

    setState(() {
      // Splice the reordered subset back into the full list, keeping
      // every other type's categories untouched.
      final others = _categories.where((c) => c.transactionTypeId != _selectedTypeId).toList();
      _categories = [...others, ...visible]
        ..sort((a, b) => a.transactionTypeId.compareTo(b.transactionTypeId));
    });

    try {
      await _categoryService.reorder([
        for (int i = 0; i < visible.length; i++) {'id': visible[i].id, 'sort_order': i},
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save the new order: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
      _load(); // fall back to server truth if the save failed
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final brandColor = isDark
        ? AdipsPalette.darkPrimaryBrandText
        : AdipsPalette.lightPrimaryBrandText;

    return Scaffold(
      backgroundColor: isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _load)
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AdipsSizes.defaultSpace,
                          AdipsSizes.sm,
                          AdipsSizes.defaultSpace,
                          0,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: _selectedTypeId == null,
                                onTap: () => setState(() => _selectedTypeId = null),
                              ),
                              for (final type in _types) ...[
                                const SizedBox(width: AdipsSizes.xs),
                                _FilterChip(
                                  label: type.name,
                                  selected: _selectedTypeId == type.id,
                                  onTap: () => setState(() => _selectedTypeId = type.id),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AdipsSizes.defaultSpace),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AdipsSizes.md),
                          decoration: BoxDecoration(
                            color: brandColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusMd),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AdipsSizes.xs),
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
                                ),
                                child: Icon(Icons.grid_view_rounded, color: brandColor, size: 20),
                              ),
                              const SizedBox(width: AdipsSizes.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Customise your categories',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: AdipsSizes.fontSizesSm,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedTypeId == null
                                          ? 'Tap a category to edit it. Filter by type to drag and reorder.'
                                          : 'Tap to edit. Long press and drag to reorder.',
                                      style: TextStyle(
                                        fontSize: AdipsSizes.fontSizesEs,
                                        color: mutedColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _visibleCategories.isEmpty
                            ? Center(
                                child: Text('No categories yet', style: TextStyle(color: mutedColor)),
                              )
                            : _selectedTypeId == null
                                ? ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AdipsSizes.defaultSpace,
                                    ),
                                    itemCount: _visibleCategories.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: AdipsSizes.sm),
                                    itemBuilder: (context, index) {
                                      final category = _visibleCategories[index];
                                      return ManageableItemTile(
                                        icon: AdipsIcons.byId(category.iconId),
                                        color: AdipsCategoryColors.byId(category.colorId),
                                        title: category.name,
                                        subtitle: _typeName(category.transactionTypeId),
                                        surfaceColor: surfaceColor,
                                        lineColor: lineColor,
                                        textColor: textColor,
                                        mutedColor: mutedColor,
                                        onTap: () => _openEditSheet(category),
                                      );
                                    },
                                  )
                                : ReorderableListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AdipsSizes.defaultSpace,
                                    ),
                                    itemCount: _visibleCategories.length,
                                    onReorder: _handleReorder,
                                    itemBuilder: (context, index) {
                                      final category = _visibleCategories[index];
                                      return Padding(
                                        key: ValueKey('category-${category.id}'),
                                        padding: const EdgeInsets.only(bottom: AdipsSizes.sm),
                                        child: ManageableItemTile(
                                          icon: AdipsIcons.byId(category.iconId),
                                          color: AdipsCategoryColors.byId(category.colorId),
                                          title: category.name,
                                          subtitle: _typeName(category.transactionTypeId),
                                          surfaceColor: surfaceColor,
                                          lineColor: lineColor,
                                          textColor: textColor,
                                          mutedColor: mutedColor,
                                          onTap: () => _openEditSheet(category),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                      const SizedBox(height: AdipsSizes.sm),
                    ],
                  ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final brandColor = isDark
        ? AdipsPalette.darkPrimaryBrandText
        : AdipsPalette.lightPrimaryBrandText;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? brandColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? brandColor : lineColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? brandColor : textColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: AdipsSizes.fontSizesSm,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AdipsSizes.sm),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
