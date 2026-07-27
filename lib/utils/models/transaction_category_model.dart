// utils/models/transaction_category_model.dart

/// Mirrors adips_backend's dto.TransactionCategoryResponse.
class TransactionCategoryModel {
  const TransactionCategoryModel({
    required this.id,
    required this.transactionTypeId,
    required this.name,
    required this.iconId,
    required this.colorId,
    required this.sortOrder,
    required this.isDefault,
  });

  final int id;
  final int transactionTypeId;
  final String name;
  final int iconId;
  final int colorId;
  final int sortOrder;
  final bool isDefault;

  factory TransactionCategoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionCategoryModel(
      id: json['id'] as int,
      transactionTypeId: json['transaction_type_id'] as int,
      name: json['name'] as String,
      iconId: json['icon_id'] as int,
      colorId: json['color_id'] as int,
      sortOrder: json['sort_order'] as int? ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  TransactionCategoryModel copyWith({
    int? transactionTypeId,
    String? name,
    int? iconId,
    int? colorId,
    int? sortOrder,
  }) {
    return TransactionCategoryModel(
      id: id,
      transactionTypeId: transactionTypeId ?? this.transactionTypeId,
      name: name ?? this.name,
      iconId: iconId ?? this.iconId,
      colorId: colorId ?? this.colorId,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault,
    );
  }
}
