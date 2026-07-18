import 'package:adips/features/authentication/controllers/register/register_controller.dart';
import 'package:get/get.dart';

/// Ties [RegisterController]'s creation/disposal to the '/register' route
/// instead of to widget build() timing. `fenix: true` makes GetX
/// transparently recreate the controller if it's ever looked up again
/// after being disposed, instead of handing back a stale, disposed
/// instance.
class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
  }
}
