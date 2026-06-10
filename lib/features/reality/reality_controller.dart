import 'package:get/get.dart';

import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class RealityController extends GetxController {
  RealityController(this._data);

  final AppDataController _data;

  RxString get currencySymbol => _data.currencySymbol;
  RxString get distanceUnit => _data.distanceUnit;

  VehicleModel? get vehicle => _data.selectedVehicle;
  EnergyMode? get mode => vehicle?.energyMode;

  bool get hasClaim {
    if (vehicle == null) return false;
    switch (vehicle!.energyMode) {
      case EnergyMode.fuel:
        return _data.claimedMpg > 0;
      case EnergyMode.charge:
        return _data.claimedMiPerKwh > 0;
      case EnergyMode.hybrid:
        return _data.claimedMpg > 0 || _data.claimedMiPerKwh > 0;
    }
  }

  bool get hasData {
    if (vehicle == null) return false;
    switch (vehicle!.energyMode) {
      case EnergyMode.fuel:
        return _data.avgMpg > 0;
      case EnergyMode.charge:
        return _data.avgMilesPerKwh > 0;
      case EnergyMode.hybrid:
        return _data.avgMpg > 0 || _data.avgMilesPerKwh > 0;
    }
  }

  double get claimedMpg => _data.claimedMpg;
  double get claimedMiPerKwh => _data.claimedMiPerKwh;
  double get realMpg => _data.avgMpg;
  double get realMilesPerKwh => _data.avgMilesPerKwh;
  double get realityPercent => _data.realityPercent;
  double get differencePercent => _data.differencePercent;
  double get savings => _data.savingsVsClaim;

  double get fuelRealityPercent =>
      _data.efficiency.realityPercent(realMpg, claimedMpg);

  double get electricRealityPercent =>
      _data.efficiency.realityPercent(realMilesPerKwh, claimedMiPerKwh);

  double get fuelDifferencePercent =>
      _data.efficiency.differencePercent(realMpg, claimedMpg);

  double get electricDifferencePercent =>
      _data.efficiency.differencePercent(realMilesPerKwh, claimedMiPerKwh);

  String get verdict {
    final diff = differencePercent;
    if (mode == EnergyMode.hybrid) {
      if (fuelDifferencePercent >= 0 && electricDifferencePercent >= 0) {
        return 'Beating both fuel and electric claims';
      }
      if (fuelDifferencePercent >= -5 && electricDifferencePercent >= -5) {
        return 'Very close to manufacturer claims';
      }
      return 'Mixed results vs manufacturer claims';
    }
    if (diff >= 0) return 'Beating the manufacturer claim';
    if (diff >= -5) return 'Very close to the claim';
    if (diff >= -15) return 'Slightly below the claim';
    return 'Well below the claim';
  }

  String get gaugeCaption {
    if (mode == EnergyMode.charge) {
      return "You're getting ${realityPercent.toStringAsFixed(1)}% of claimed efficiency";
    }
    if (mode == EnergyMode.hybrid) {
      return 'Combined performance vs manufacturer claims';
    }
    return "You're getting ${realityPercent.toStringAsFixed(1)}% of claimed MPG";
  }
}
