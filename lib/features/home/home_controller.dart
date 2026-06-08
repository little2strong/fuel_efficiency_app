import 'package:get/get.dart';
import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class HomeController extends GetxController {
  HomeController(this._storage);

  final LocalStorageProvider _storage;

  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxList<FuelEntryModel> recentEntries = <FuelEntryModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  void loadDashboard() {
    isLoading.value = true;
    vehicles.assignAll(VehicleModel.loadAll(_storage));
    recentEntries
      ..assignAll(FuelEntryModel.loadAll(_storage))
      ..sort((a, b) => b.date.compareTo(a.date));
    if (recentEntries.length > 5) {
      recentEntries.removeRange(5, recentEntries.length);
    }
    isLoading.value = false;
  }

  void goToFuel() => Get.toNamed(AppRoutes.fuel);

  void goToVehicle() => Get.toNamed(AppRoutes.vehicle);

  void goToSettings() => Get.toNamed(AppRoutes.settings);
}
