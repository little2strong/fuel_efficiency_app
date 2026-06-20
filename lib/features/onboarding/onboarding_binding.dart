import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/services/auth_service.dart';
import 'package:fuel_efficiency_app/features/onboarding/onboarding_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(
        Get.find<AppDataController>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
