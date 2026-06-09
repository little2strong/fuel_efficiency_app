import 'package:get/get.dart';
import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class HomeController extends GetxController {
  HomeController(this._data);

  final AppDataController _data;

  RxList<VehicleModel> get vehicles => _data.vehicles;
  RxList<FuelEntryModel> get entries => _data.entries;
  RxString get selectedVehicleId => _data.selectedVehicleId;
  RxString get currencySymbol => _data.currencySymbol;
  RxString get distanceUnit => _data.distanceUnit;
  RxBool get isHydrated => _data.isHydrated;

  String get userName => _data.userName.value.isEmpty ? 'Driver' : _data.userName.value;

  VehicleModel? get selectedVehicle => _data.selectedVehicle;

  List<FuelEntryModel> get recentEntries =>
      _data.selectedVehicleEntries.take(5).toList();

  double get realMpg => _data.avgMpg;

  double get claimedMpg => _data.claimedMpg;

  double get monthlyFuelCost => _data.monthlyFuelCost;

  double get avgCostPerDistance => _data.avgCostPerDistance;

  double get realityPercent => _data.realityPercent;

  double get differencePercent => _data.differencePercent;

  void goToFuel() => Get.toNamed(AppRoutes.fuel);

  void goToVehicle() => Get.toNamed(AppRoutes.vehicle);

  void goToSettings() => Get.toNamed(AppRoutes.settings);

  Future<void> selectVehicle(String vehicleId) => _data.selectVehicle(vehicleId);

  void refreshData() => _data.hydrate();
}
