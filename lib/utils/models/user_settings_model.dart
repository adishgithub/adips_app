// utils/models/user_settings_model.dart

/// Mirrors adips_backend's dto.SettingsResponse.
class UserSettingsModel {
  const UserSettingsModel({required this.darkMode, required this.currency});

  final bool darkMode;
  final String currency;

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      darkMode: json['dark_mode'] as bool? ?? false,
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}
