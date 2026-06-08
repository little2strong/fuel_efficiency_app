import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_controller.dart';

class VehicleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehicleController>(
      () => VehicleController(Get.find<LocalStorageProvider>()),
    );
  }
}
