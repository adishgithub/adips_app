import 'package:adips/features/authentication/controllers/home/home_controller.dart';
import 'package:get/get.dart';

/// Ties [HomeController]'s creation/disposal to the '/home' route.
/// `fenix: true` so GetX transparently recreates it if it's ever
/// looked up again after being disposed (e.g. after logging out and
/// back in), instead of handing back a stale instance.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
