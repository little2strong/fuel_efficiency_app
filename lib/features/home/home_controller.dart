import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/core/services/auth_service.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/main/main_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/shared/efficiency_service.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class HomeController extends GetxController {
  HomeController(this._data);

  final AppDataController _data;

  RxList<VehicleModel> get vehicles => _data.vehicles;
  RxString get selectedVehicleId => _data.selectedVehicleId;
  RxString get currencySymbol => _data.currencySymbol;
  RxString get distanceUnit => _data.distanceUnit;
  RxString get volumeUnit => _data.volumeUnit;
  RxBool get isHydrated => _data.isHydrated;

  String get userName =>
      _data.userName.value.isEmpty ? 'Driver' : _data.userName.value;

  VehicleModel? get selectedVehicle => _data.selectedVehicle;
  EnergyMode? get energyMode => selectedVehicle?.energyMode;

  EfficiencyMetric get primaryMetric =>
      selectedVehicle?.energyMode.primaryMetric ?? EfficiencyMetric.mpg;

  bool get isElectric => energyMode == EnergyMode.charge;
  bool get isHybrid => energyMode == EnergyMode.hybrid;

  List<FuelEntryModel> get recentEntries =>
      _data.selectedVehicleEntries.take(4).toList();

  double get realMpg => _data.avgMpg;
  double get realMilesPerKwh => _data.avgMilesPerKwh;
  double get claimedMpg => _data.claimedMpg;
  double get claimedMiPerKwh => _data.claimedMiPerKwh;
  double get monthlyCost => _data.monthlyFuelCost;
  double get monthlyDistance => _data.monthlyDistance;
  double get monthlyCostPerDistance => _data.monthlyCostPerDistance;
  double get totalDistance => _data.totalDistance;
  double get totalCost => _data.totalCost;
  double get avgCostPerDistance => _data.avgCostPerDistance;
  double get differencePercent => _data.differencePercent;

  /// Primary efficiency value to show in the headline card.
  double get primaryEfficiency {
    if (isElectric) return realMilesPerKwh;
    if (isHybrid) return avgCostPerDistance;
    return realMpg;
  }

  String get primaryUnit {
    if (isElectric) return 'mi/kWh';
    if (isHybrid) return 'per ${distanceUnit.value.toLowerCase()}';
    return 'MPG';
  }

  String get headlineLabel {
    if (isElectric) return 'Real Efficiency';
    if (isHybrid) return 'Cost per Mile';
    return 'Real MPG';
  }

  double? get claimedPrimary {
    if (isElectric) return claimedMiPerKwh > 0 ? claimedMiPerKwh : null;
    if (isHybrid) return null;
    return claimedMpg > 0 ? claimedMpg : null;
  }

  EfficiencyStats get trendStats => _data.statsFor(primaryMetric);

  double get trendChangePercent {
    final points = trendPoints;
    if (points.length < 2) return 0;
    final first = points.first.value;
    final last = points.last.value;
    if (first <= 0) return 0;
    return ((last - first) / first) * 100;
  }

  List<TrendPoint> get trendPoints {
    final weekly = _data.efficiency.weeklyTrend(
      _data.selectedVehicleEntries,
      primaryMetric,
      distanceUnit.value,
      volumeUnit: volumeUnit.value,
    );
    if (weekly.length >= 2) return weekly;
    return _data.efficiency.trend(
      _data.selectedVehicleEntries,
      primaryMetric,
      distanceUnit.value,
      volumeUnit: volumeUnit.value,
      maxPoints: 12,
    );
  }

  String get trendTitle {
    if (isElectric) return 'Efficiency Trend (mi/kWh)';
    if (isHybrid) {
      return 'Cost Trend (${currencySymbol.value}/${distanceUnit.value.toLowerCase()})';
    }
    return 'Efficiency Trend (MPG)';
  }

  void goToFuel() => Get.find<MainController>().openAddEntry();

  void goToVehicleProfile() => Get.toNamed(AppRoutes.vehicleProfile);

  void goToSettings() => Get.toNamed(AppRoutes.settings);

  void openEntry(FuelEntryModel entry) =>
      Get.toNamed(AppRoutes.entryDetail, arguments: entry);

  Future<void> selectVehicle(String vehicleId) =>
      _data.selectVehicle(vehicleId);

  Future<void> refreshData() async {
    await _data.hydrate();
    if (_data.loggedIn.value && Get.find<AuthService>().currentUser != null) {
      final ok = await _data.syncFromCloud();
      if (!ok && _data.cloudSyncError.value.isNotEmpty) {
        Get.snackbar(
          'Sync issue',
          _data.cloudSyncError.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
