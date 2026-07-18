import 'package:adips/common/widgets/buttons/custom_elevated_button.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/local_storage/storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Sample landing page shown right after registration.
/// Reads the values passed via Get.arguments from RegisterController.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        (Get.arguments as Map<String, dynamic>?) ?? {};

    final String fullName = args['fullName'] ?? 'Not provided';
    final String email = args['email'] ?? 'Not provided';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AdipsSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AdipsSizes.spaceBtwSections),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: AdipsSizes.spaceBtwSections),
            const Text(
              "Welcome!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AdipsSizes.spaceBtwSections),

            // Details card
            Container(
              padding: const EdgeInsets.all(AdipsSizes.md),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusMg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: "Full Name", value: fullName),
                  const Divider(height: AdipsSizes.spaceBtwItems),
                  _DetailRow(label: "Email", value: email),
                ],
              ),
            ),
            const SizedBox(height: AdipsSizes.spaceBtwSections),

            // Logout
            CustomButton(
              text: "Logout",
              onPressed: () async {
                final token = AdipsLocalStorage.token;
                try {
                  await AdipsHttpHelper.post(
                    '/logout',
                    {},
                    cookie: token != null ? 'Authorization=$token' : null,
                  );
                } catch (_) {
                  // Even if the network call fails, still clear locally
                  // and send the user back to Login.
                }
                await AdipsLocalStorage.clearToken();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}