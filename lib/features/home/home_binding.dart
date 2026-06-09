import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/home/home_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<AppDataController>()),
    );
  }
}
