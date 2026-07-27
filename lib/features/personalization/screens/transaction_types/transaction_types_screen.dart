// features/personalization/screens/transaction_types/transaction_types_screen.dart
import 'package:flutter/material.dart';

import '../../../../common/widgets/list_tiles/manageable_item_tile.dart';
import '../../../../common/widgets/sheets/manage_item_sheet.dart';
import '../../../../data/services/transaction_type_service.dart';
import '../../../../utils/constants/adips_category_colors.dart';
import '../../../../utils/constants/adips_icons.dart';
import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/models/transaction_type_model.dart';

class TransactionTypesScreen extends StatefulWidget {
  const TransactionTypesScreen({super.key});

  @override
  State<TransactionTypesScreen> createState() => _TransactionTypesScreenState();
}

class _TransactionTypesScreenState extends State<TransactionTypesScreen> {
  final TransactionTypeService _service = TransactionTypeService();

  List<TransactionTypeModel> _types = [];
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
      final types = await _service.list();
      if (mounted) setState(() => _types = types);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEditSheet(TransactionTypeModel type) async {
    final changed = await showManageItemSheet(
      context: context,
      title: 'Edit Transaction Type',
      initialName: type.name,
      initialIconId: type.iconId,
      initialColorId: type.colorId,
      isDefault: type.isDefault,
      onSave: ({required name, required iconId, typeId}) async {
        await _service.update(type.id, name: name, iconId: iconId);
      },
      onDelete: () async {
        await _service.delete(type.id);
      },
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;

    return Scaffold(
      backgroundColor: isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Transaction Types'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _load)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdipsSizes.defaultSpace,
                        vertical: AdipsSizes.md,
                      ),
                      itemCount: _types.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AdipsSizes.sm),
                      itemBuilder: (context, index) {
                        final type = _types[index];
                        return ManageableItemTile(
                          icon: AdipsIcons.byId(type.iconId),
                          color: AdipsCategoryColors.byId(type.colorId),
                          title: type.name,
                          subtitle: type.isDefault ? 'Default' : null,
                          surfaceColor: surfaceColor,
                          lineColor: lineColor,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          onTap: () => _openEditSheet(type),
                        );
                      },
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
