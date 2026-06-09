import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class VehicleController extends GetxController {
  VehicleController(this._data);

  final AppDataController _data;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController makeModelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController claimedMpgController = TextEditingController();
  final TextEditingController batteryController = TextEditingController();

  final Rx<EnergyMode> energyMode = EnergyMode.fuel.obs;
  final RxString vehicleType = 'Car'.obs;

  RxList<VehicleModel> get vehicles => _data.vehicles;
  RxString get selectedVehicleId => _data.selectedVehicleId;
  RxBool get isHydrated => _data.isHydrated;

  Future<void> addVehicle({
    required BuildContext context,
  }) async {
    final name = nameController.text.trim();
    final makeModel = makeModelController.text.trim();
    final year = int.tryParse(yearController.text.trim());
    final odometer = double.tryParse(odometerController.text.trim());
    final claim = double.tryParse(claimedMpgController.text.trim());
    final battery = double.tryParse(batteryController.text.trim());

    if (name.isEmpty || makeModel.isEmpty || year == null || odometer == null) {
      Get.snackbar('Missing fields', 'Fill in all required vehicle details.');
      return;
    }

    await _data.addVehicle(
      name: name,
      energyMode: energyMode.value,
      vehicleType: vehicleType.value,
      makeModel: makeModel,
      year: year,
      odometer: odometer,
      manufacturerMpgClaim:
          (energyMode.value == EnergyMode.fuel || energyMode.value == EnergyMode.hybrid)
              ? claim
              : null,
      batteryKwhCapacity:
          (energyMode.value == EnergyMode.charge || energyMode.value == EnergyMode.hybrid)
              ? battery
              : null,
    );

    clearForm();
    if (context.mounted) {
      Get.snackbar('Success', 'Vehicle added');
    }
  }

  Future<void> selectVehicle(String id) => _data.selectVehicle(id);

  void clearForm() {
    nameController.clear();
    makeModelController.clear();
    yearController.clear();
    odometerController.clear();
    claimedMpgController.clear();
    batteryController.clear();
    energyMode.value = EnergyMode.fuel;
    vehicleType.value = 'Car';
  }

  @override
  void onClose() {
    nameController.dispose();
    makeModelController.dispose();
    yearController.dispose();
    odometerController.dispose();
    claimedMpgController.dispose();
    batteryController.dispose();
    super.onClose();
  }
}
