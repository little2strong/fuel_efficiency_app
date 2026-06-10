import 'package:get/get.dart';
import 'package:fuel_efficiency_app/app/routes/app_routes.dart';

/// Controls the bottom-navigation shell. Tab bodies are: Dashboard, History,
/// Analytics and More. The center "Add" slot is an action rather than a tab.
class MainController extends GetxController {
  final RxInt tabIndex = 0.obs;

  void changeTab(int index) {
    if (index < 0 || index > 3) return;
    tabIndex.value = index;
  }

  Future<void> openAddEntry() async {
    await Get.toNamed(AppRoutes.entryForm);
  }
}
