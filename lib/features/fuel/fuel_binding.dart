import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_controller.dart';

class FuelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FuelController>(
      () => FuelController(Get.find<LocalStorageProvider>()),
    );
  }
}
