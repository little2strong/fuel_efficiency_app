import 'package:get/get.dart';
import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future<void>.delayed(AppConstants.splashDuration);
    Get.offAllNamed(AppRoutes.home);
  }
}
