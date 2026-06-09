import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class FuelController extends GetxController {
  FuelController(this._data);

  final AppDataController _data;

  final Rx<EnergyMode> selectedMode = EnergyMode.fuel.obs;
  final RxString selectedVehicleId = ''.obs;

  final TextEditingController odometerController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController litersController = TextEditingController();
  final TextEditingController fuelCostController = TextEditingController();
  final TextEditingController kwhController = TextEditingController();
  final TextEditingController electricityCostController = TextEditingController();

  RxList<VehicleModel> get vehicles => _data.vehicles;
  RxList<FuelEntryModel> get entries => _data.entries;
  RxString get currencySymbol => _data.currencySymbol;
  RxString get distanceUnit => _data.distanceUnit;
  RxBool get isHydrated => _data.isHydrated;

  @override
  void onInit() {
    super.onInit();
    if (_data.selectedVehicle != null) {
      selectedVehicleId.value = _data.selectedVehicleId.value;
      selectedMode.value = _data.selectedVehicle!.energyMode;
      odometerController.text = _data.selectedVehicle!.odometer.toStringAsFixed(0);
    } else if (_data.vehicles.isNotEmpty) {
      final first = _data.vehicles.first;
      selectedVehicleId.value = first.id;
      selectedMode.value = first.energyMode;
      odometerController.text = first.odometer.toStringAsFixed(0);
    }
  }

  VehicleModel? get selectedVehicle =>
      _data.vehicles.firstWhereOrNull((v) => v.id == selectedVehicleId.value);

  List<FuelEntryModel> get selectedEntries {
    if (selectedVehicleId.value.isEmpty) return const [];
    return entries.where((e) => e.vehicleId == selectedVehicleId.value).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void onVehicleChanged(String id) {
    selectedVehicleId.value = id;
    final vehicle = selectedVehicle;
    if (vehicle != null) {
      selectedMode.value = vehicle.energyMode;
      odometerController.text = vehicle.odometer.toStringAsFixed(0);
      _data.selectVehicle(vehicle.id);
    }
  }

  Future<void> saveEntry() async {
    final vehicle = selectedVehicle;
    if (vehicle == null) {
      Get.snackbar('No vehicle', 'Please add a vehicle first.');
      return;
    }

    final odometer = double.tryParse(odometerController.text.trim());
    final distance = double.tryParse(distanceController.text.trim());
    final liters = double.tryParse(litersController.text.trim()) ?? 0;
    final fuelCost = double.tryParse(fuelCostController.text.trim()) ?? 0;
    final kwh = double.tryParse(kwhController.text.trim()) ?? 0;
    final electricityCost =
        double.tryParse(electricityCostController.text.trim()) ?? 0;

    if (odometer == null || distance == null || distance <= 0) {
      Get.snackbar('Invalid input', 'Distance and odometer are required.');
      return;
    }

    if ((selectedMode.value == EnergyMode.fuel ||
            selectedMode.value == EnergyMode.hybrid) &&
        liters <= 0) {
      Get.snackbar('Fuel input missing', 'Enter liters for this entry.');
      return;
    }

    if ((selectedMode.value == EnergyMode.charge ||
            selectedMode.value == EnergyMode.hybrid) &&
        kwh <= 0) {
      Get.snackbar('Charge input missing', 'Enter kWh for this entry.');
      return;
    }

    await _data.addEntry(
      vehicleId: vehicle.id,
      mode: selectedMode.value,
      distance: distance,
      odometer: odometer,
      liters: liters,
      fuelCost: fuelCost,
      kwh: kwh,
      electricityCost: electricityCost,
    );

    distanceController.clear();
    litersController.clear();
    fuelCostController.clear();
    kwhController.clear();
    electricityCostController.clear();
    Get.snackbar('Saved', 'Entry added successfully');
  }

  @override
  void onClose() {
    odometerController.dispose();
    distanceController.dispose();
    litersController.dispose();
    fuelCostController.dispose();
    kwhController.dispose();
    electricityCostController.dispose();
    super.onClose();
  }
}
