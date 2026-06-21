import 'package:get/get.dart';
import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

/// Controls the bottom-navigation shell. Tab bodies are: Dashboard, History,
/// Analytics and More. The center "Add" slot is an action rather than a tab.
class MainController extends GetxController {
  final RxInt tabIndex = 0.obs;

  void changeTab(int index) {
    if (index < 0 || index > 3) return;
    tabIndex.value = index;
  }

  Future<void> openAddEntry() async {
    final data = Get.find<AppDataController>();
    if (data.vehicles.isEmpty) {
      Get.snackbar(
        'Add a vehicle first',
        'Create a vehicle before logging fuel or charge entries.',
        snackPosition: SnackPosition.BOTTOM,
      );
      await Get.toNamed(AppRoutes.vehicleForm);
      return;
    }
    await Get.toNamed(AppRoutes.entryForm);
  }
}
