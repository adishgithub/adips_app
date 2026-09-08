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
/// - No saved token              -> Onboarding (first run, or logged out)
/// - Saved token confirmed valid -> Home (skip onboarding/login)
/// - Saved token confirmed bad
///   (server said 401)           -> Login (skip onboarding — they already
///                                   have an account, just need to sign
///                                   back in)
/// - Couldn't confirm either way
///   (timeout / cold start /
///   no connection)               -> Home anyway, using cached user info.
///   The backend runs on Render's free tier and can take 20-50s+ to wake
///   from a cold start; a slow/failed request here does NOT mean the
///   token is invalid. Treating it as invalid was logging users out for
///   no reason every time the server had spun down. We optimistically
///   let them in and let the rest of the app re-sync in the background.
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
      // Longer than the default 15s: Render free-tier cold starts can
      // take a while, and we'd rather wait than falsely fail this call.
      timeout: const Duration(seconds: 45),
    );
    final user = AdipsHttpHelper.data(validateResponse);
    final fullName = (user['name'] ?? '').toString();
    final email = (user['email'] ?? '').toString();

    await AdipsLocalStorage.saveCachedUser(fullName, email);

    return StartDestination(
      StartRoute.home,
      arguments: {'fullName': fullName, 'email': email},
    );
  } on ApiException catch (e) {
    if (e.statusCode == 401) {
      // Server explicitly rejected the token — this is a real logout.
      await AdipsLocalStorage.clearToken();
      return const StartDestination(StartRoute.login);
    }
    // Some other server-side error (500 etc). Don't discard a token
    // that might still be perfectly valid.
    return StartDestination(
      StartRoute.home,
      arguments: {
        'fullName': AdipsLocalStorage.cachedFullName ?? '',
        'email': AdipsLocalStorage.cachedEmail ?? '',
        'offlineRetry': true,
      },
    );
  } catch (_) {
    // Timeout, no connectivity, DNS hiccup, cold-starting server, etc.
    // We genuinely don't know if the token is valid — assume it is and
    // let the app re-check in the background instead of forcing a
    // re-login.
    return StartDestination(
      StartRoute.home,
      arguments: {
        'fullName': AdipsLocalStorage.cachedFullName ?? '',
        'email': AdipsLocalStorage.cachedEmail ?? '',
        'offlineRetry': true,
      },
    );
  }
}