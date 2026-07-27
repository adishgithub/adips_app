// data/services/transaction_type_service.dart
import 'package:adips/utils/constants/api_constants.dart';
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/models/transaction_type_model.dart';

/// Talks to /api/v1/transaction-types.
class TransactionTypeService {
  Future<List<TransactionTypeModel>> list() async {
    final response = await AdipsHttpHelper.get(
      AdipsApiConstants.transactionTypes,
      cookie: AdipsHttpHelper.authCookie,
    );
    return AdipsHttpHelper.list(response)
        .map((e) => TransactionTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TransactionTypeModel> update(
    int id, {
    String? name,
    int? iconId,
    int? colorId,
  }) async {
    final response = await AdipsHttpHelper.put(
      AdipsApiConstants.transactionType(id),
      {
        if (name != null) 'name': name,
        if (iconId != null) 'icon_id': iconId,
        if (colorId != null) 'color_id': colorId,
      },
      cookie: AdipsHttpHelper.authCookie,
    );
    return TransactionTypeModel.fromJson(AdipsHttpHelper.data(response));
  }

  Future<void> delete(int id) async {
    await AdipsHttpHelper.delete(
      AdipsApiConstants.transactionType(id),
      cookie: AdipsHttpHelper.authCookie,
    );
  }
}
