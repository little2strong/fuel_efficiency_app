import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/analytics/analytics_controller.dart';
import 'package:fuel_efficiency_app/features/history/history_controller.dart';
import 'package:fuel_efficiency_app/features/home/home_controller.dart';
import 'package:fuel_efficiency_app/features/main/main_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    final data = Get.find<AppDataController>();
    Get.lazyPut<MainController>(MainController.new);
    Get.lazyPut<HomeController>(() => HomeController(data));
    Get.lazyPut<HistoryController>(() => HistoryController(data));
    Get.lazyPut<AnalyticsController>(() => AnalyticsController(data));
  }
}
