import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_form_controller.dart';

class VehicleFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehicleFormController>(
      () => VehicleFormController(Get.find<AppDataController>()),
    );
  }
}
