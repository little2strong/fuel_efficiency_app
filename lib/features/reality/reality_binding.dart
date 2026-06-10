import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/reality/reality_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class RealityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RealityController>(
      () => RealityController(Get.find<AppDataController>()),
    );
  }
}
