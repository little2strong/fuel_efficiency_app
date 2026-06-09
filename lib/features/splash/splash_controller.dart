import 'package:get/get.dart';
import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class SplashController extends GetxController {
  AppDataController get _data => Get.find<AppDataController>();

  @override
  void onReady() {
    super.onReady();
    _navigateByState();
  }

  Future<void> _navigateByState() async {
    await Future<void>.delayed(AppConstants.splashDuration);
    if (Get.currentRoute != AppRoutes.splash) {
      return;
    }
    if (!_data.onboardingComplete.value || !_data.loggedIn.value) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }
    Get.offAllNamed(AppRoutes.home);
  }
}
