import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/settings/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(Get.find<AppDataController>()),
    );
  }
}
