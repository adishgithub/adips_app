import 'package:adips/common/widgets/buttons/custom_elevated_button.dart';
import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/helpers/helper_functions.dart';
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/local_storage/storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Account / profile screen — reached from Settings > Account.
/// Shows the logged-in user's details and lets them log out (clears
/// the saved token locally and tells the backend to drop the auth
/// cookie), which is the "logout and all" functionality this screen
/// owns.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    final token = AdipsLocalStorage.token;
    try {
      await AdipsHttpHelper.post(
        '/api/v1/users/logout',
        {},
        cookie: token != null ? 'Authorization=$token' : null,
      );
    } catch (_) {
      // Even if the network call fails, still clear locally and send
      // the user back to Login — a failed logout call shouldn't trap
      // them in the app.
    }
    await AdipsLocalStorage.clearToken();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = (Get.arguments as Map<String, dynamic>?) ?? {};
    final String fullName = (args['fullName'] as String?)?.trim().isNotEmpty == true
        ? args['fullName'] as String
        : 'Not provided';
    final String email = (args['email'] as String?)?.trim().isNotEmpty == true
        ? args['email'] as String
        : 'Not provided';

    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final backgroundColor = isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground;
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final brandColor = isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AdipsSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AdipsSizes.spaceBtwItems),
              CircleAvatar(
                radius: 40,
                backgroundColor: brandColor,
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: AdipsSizes.spaceBtwSections),
              Text(
                fullName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: AdipsSizes.spaceBtwSections),

              // Details card
              Container(
                padding: const EdgeInsets.all(AdipsSizes.md),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border.all(color: lineColor),
                  borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusMg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(label: 'Full Name', value: fullName, textColor: textColor, mutedColor: mutedColor),
                    Divider(height: AdipsSizes.spaceBtwItems, color: lineColor),
                    _DetailRow(label: 'Email', value: email, textColor: textColor, mutedColor: mutedColor),
                  ],
                ),
              ),
              const SizedBox(height: AdipsSizes.spaceBtwSections),

              CustomButton(
                text: 'Logout',
                isLoading: _isLoggingOut,
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: mutedColor)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
          ),
        ),
      ],
    );
  }
}
