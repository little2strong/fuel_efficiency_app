import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/services/auth_service.dart';
import 'package:fuel_efficiency_app/core/utils/app_logger.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class SplashController extends GetxController {
  AppDataController get _data => Get.find<AppDataController>();
  AuthService get _auth => Get.find<AuthService>();

  @override
  void onReady() {
    super.onReady();
    _navigateByState();
  }

  Future<void> _navigateByState() async {
    await Future<void>.delayed(AppConstants.splashDuration);
    if (!isClosed && Get.currentRoute != AppRoutes.splash) return;

    try {
      // Ensure Firebase Auth has restored before reading currentUser.
      await Get.find<AuthService>().ensureInitialized();
      await _data.hydrate();
      await _auth.syncSession(_data);
    } catch (error, stackTrace) {
      AppLogger.error('Startup failed', error, stackTrace);
    }

    if (!isClosed && Get.currentRoute != AppRoutes.splash) return;

    final hasFirebaseUser = _auth.currentUser != null;
    if (!hasFirebaseUser) {
      await _data.clearAuthSession();
    }

    if (!_data.onboardingComplete.value || !hasFirebaseUser) {
      await Get.offAllNamed(AppRoutes.onboarding);
      return;
    }
    await Get.offAllNamed(AppRoutes.main);
  }
}
