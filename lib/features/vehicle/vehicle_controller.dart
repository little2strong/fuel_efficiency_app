import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class VehicleController extends GetxController {
  VehicleController(this._data);

  final AppDataController _data;

  RxList<VehicleModel> get vehicles => _data.vehicles;
  RxString get selectedVehicleId => _data.selectedVehicleId;
  RxString get currencySymbol => _data.currencySymbol;
  RxString get distanceUnit => _data.distanceUnit;
  RxBool get isHydrated => _data.isHydrated;

  VehicleModel? get vehicle => _data.selectedVehicle;

  double get avgMpg => _data.avgMpg;
  double get avgMilesPerKwh => _data.avgMilesPerKwh;
  double get avgCostPerDistance => _data.avgCostPerDistance;
  double get totalDistance => _data.totalDistance;
  double get totalCost => _data.totalCost;
  int get daysTracked => _data.daysTracked;
  int get entryCount => _data.selectedVehicleEntries.length;

  Future<void> selectVehicle(String id) => _data.selectVehicle(id);

  void addVehicle() => Get.toNamed(AppRoutes.vehicleForm);

  void editVehicle() {
    final v = vehicle;
    if (v != null) Get.toNamed(AppRoutes.vehicleForm, arguments: v);
  }

  Future<void> deleteVehicle(String id) => _data.deleteVehicle(id);
}
