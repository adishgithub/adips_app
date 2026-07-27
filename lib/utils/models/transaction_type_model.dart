// utils/models/transaction_type_model.dart

/// Mirrors adips_backend's dto.TransactionTypeResponse.
class TransactionTypeModel {
  const TransactionTypeModel({
    required this.id,
    required this.name,
    required this.iconId,
    required this.colorId,
    required this.isDefault,
  });

  final int id;
  final String name;
  final int iconId;
  final int colorId;
  final bool isDefault;

  factory TransactionTypeModel.fromJson(Map<String, dynamic> json) {
    return TransactionTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      iconId: json['icon_id'] as int,
      colorId: json['color_id'] as int,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  TransactionTypeModel copyWith({
    String? name,
    int? iconId,
    int? colorId,
  }) {
    return TransactionTypeModel(
      id: id,
      name: name ?? this.name,
      iconId: iconId ?? this.iconId,
      colorId: colorId ?? this.colorId,
      isDefault: isDefault,
    );
  }
}
