import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_controller.dart';

class VehicleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehicleController>(
      () => VehicleController(Get.find<AppDataController>()),
    );
  }
}
