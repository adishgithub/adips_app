import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/local_storage/storage_utility.dart';

/// Where the app should land once startup checks are done.
enum StartRoute { onboarding, login, home }

class StartDestination {
  final StartRoute route;
  final Map<String, dynamic>? arguments;

  const StartDestination(this.route, {this.arguments});
}

/// Decides where to send the user on launch:
/// - No saved token           -> Onboarding (first run, or logged out)
/// - Saved token still valid  -> straight to Home (skip onboarding/login)
/// - Saved token expired/bad  -> Login (skip onboarding — they already have
///                                an account, just need to sign back in)
///
/// Runs during app startup (see main.dart) while the native splash screen
/// is being held on screen, so there's no separate loading UI needed.
Future<StartDestination> resolveStartDestination() async {
  final token = AdipsLocalStorage.token;

  if (token == null) {
    return const StartDestination(StartRoute.onboarding);
  }

  try {
    final validateResponse = await AdipsHttpHelper.get(
      '/api/v1/users/validate',
      cookie: 'Authorization=$token',
    );
    final user = AdipsHttpHelper.data(validateResponse);
    final fullName = (user['name'] ?? '').toString();
    final email = (user['email'] ?? '').toString();

    return StartDestination(
      StartRoute.home,
      arguments: {'fullName': fullName, 'email': email},
    );
  } catch (_) {
    // Token missing/expired/invalid, or the request failed — clear it
    // and fall back to Login rather than Onboarding.
    await AdipsLocalStorage.clearToken();
    return const StartDestination(StartRoute.login);
  }
}