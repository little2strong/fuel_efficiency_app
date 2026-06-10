import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/splash/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Must be eager — SplashView does not reference controller in build(),
    // so lazyPut would never instantiate it and onReady() would never run.
    Get.put<SplashController>(SplashController());
  }
}
