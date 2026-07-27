// data/services/transaction_category_service.dart
import 'package:adips/utils/constants/api_constants.dart';
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/models/transaction_category_model.dart';

/// Talks to /api/v1/categories.
class TransactionCategoryService {
  /// [typeName] is a type NAME ("Income"/"Expense"/...), not an id —
  /// pass null/empty to fetch categories across every type.
  Future<List<TransactionCategoryModel>> list({String? typeName}) async {
    final query = (typeName != null && typeName.isNotEmpty)
        ? '?type=${Uri.encodeQueryComponent(typeName)}'
        : '';
    final response = await AdipsHttpHelper.get(
      '${AdipsApiConstants.categories}$query',
      cookie: AdipsHttpHelper.authCookie,
    );
    return AdipsHttpHelper.list(response)
        .map((e) => TransactionCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TransactionCategoryModel> update(
    int id, {
    int? transactionTypeId,
    String? name,
    int? iconId,
    int? colorId,
  }) async {
    final response = await AdipsHttpHelper.put(
      AdipsApiConstants.category(id),
      {
        if (transactionTypeId != null) 'transaction_type_id': transactionTypeId,
        if (name != null) 'name': name,
        if (iconId != null) 'icon_id': iconId,
        if (colorId != null) 'color_id': colorId,
      },
      cookie: AdipsHttpHelper.authCookie,
    );
    return TransactionCategoryModel.fromJson(AdipsHttpHelper.data(response));
  }

  Future<void> delete(int id) async {
    await AdipsHttpHelper.delete(
      AdipsApiConstants.category(id),
      cookie: AdipsHttpHelper.authCookie,
    );
  }

  /// items: list of {id, sort_order} pairs for every category whose
  /// position changed, applied by the backend as a single transaction.
  Future<void> reorder(List<Map<String, int>> items) async {
    await AdipsHttpHelper.patch(
      AdipsApiConstants.categoriesReorder,
      {'items': items},
      cookie: AdipsHttpHelper.authCookie,
    );
  }
}
