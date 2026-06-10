import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/entry/entry_detail_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class EntryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EntryDetailController>(
      () => EntryDetailController(Get.find<AppDataController>()),
    );
  }
}
