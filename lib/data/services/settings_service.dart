// data/services/settings_service.dart
import 'package:adips/utils/constants/api_constants.dart';
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/models/user_settings_model.dart';

/// Talks to GET/PATCH /api/v1/settings. Every screen should go
/// through this instead of calling AdipsHttpHelper directly.
class SettingsService {
  Future<UserSettingsModel> getSettings() async {
    final response = await AdipsHttpHelper.get(
      AdipsApiConstants.settings,
      cookie: AdipsHttpHelper.authCookie,
    );
    return UserSettingsModel.fromJson(AdipsHttpHelper.data(response));
  }

  Future<UserSettingsModel> updateCurrency(String currency) async {
    final response = await AdipsHttpHelper.patch(
      AdipsApiConstants.settings,
      {'currency': currency},
      cookie: AdipsHttpHelper.authCookie,
    );
    return UserSettingsModel.fromJson(AdipsHttpHelper.data(response));
  }
}
