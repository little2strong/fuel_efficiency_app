import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/entry/entry_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class EntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EntryController>(
      () => EntryController(Get.find<AppDataController>()),
    );
  }
}
