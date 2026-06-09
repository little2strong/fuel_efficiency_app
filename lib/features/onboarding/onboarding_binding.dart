import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/onboarding/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(OnboardingController.new);
  }
}
