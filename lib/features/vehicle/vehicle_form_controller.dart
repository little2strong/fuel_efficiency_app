import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class VehicleFormController extends GetxController {
  VehicleFormController(this._data);

  final AppDataController _data;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final makeModelController = TextEditingController();
  final yearController = TextEditingController();
  final odometerController = TextEditingController();
  final claimedMpgController = TextEditingController();
  final claimedMiPerKwhController = TextEditingController();
  final batteryController = TextEditingController();

  final Rx<EnergyMode> energyMode = EnergyMode.fuel.obs;
  final RxString vehicleType = 'Car'.obs;
  final RxBool isSaving = false.obs;

  static const vehicleTypes = ['Car', 'Motorbike', 'Truck', 'Van', 'SUV'];

  VehicleModel? _editing;
  bool get isEditing => _editing != null;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is VehicleModel) {
      _editing = arg;
      nameController.text = arg.name;
      makeModelController.text = arg.makeModel;
      yearController.text = arg.year.toString();
      odometerController.text = arg.odometer.toStringAsFixed(0);
      claimedMpgController.text = arg.manufacturerMpgClaim?.toString() ?? '';
      claimedMiPerKwhController.text =
          arg.manufacturerMiPerKwhClaim?.toString() ?? '';
      batteryController.text = arg.batteryKwhCapacity?.toString() ?? '';
      energyMode.value = arg.energyMode;
      vehicleType.value = vehicleTypes.contains(arg.vehicleType)
          ? arg.vehicleType
          : 'Car';
    }
  }

  String? validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  String? validateYear(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Year is required';
    final year = int.tryParse(text);
    if (year == null) return 'Invalid year';
    if (year < 1950 || year > DateTime.now().year + 1) return 'Out of range';
    return null;
  }

  String? validateOdometer(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Odometer is required';
    if (double.tryParse(text) == null) return 'Enter a number';
    return null;
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;

    final claim = energyMode.value.usesFuel
        ? double.tryParse(claimedMpgController.text.trim())
        : null;
    final miPerKwhClaim = energyMode.value.usesCharge
        ? double.tryParse(claimedMiPerKwhController.text.trim())
        : null;
    final battery = energyMode.value.usesCharge
        ? double.tryParse(batteryController.text.trim())
        : null;

    if (isEditing) {
      await _data.updateVehicle(
        _editing!.copyWith(
          name: nameController.text.trim(),
          makeModel: makeModelController.text.trim(),
          year: int.tryParse(yearController.text.trim()),
          odometer: double.tryParse(odometerController.text.trim()),
          energyMode: energyMode.value,
          vehicleType: vehicleType.value,
          manufacturerMpgClaim: claim,
          clearManufacturerClaim: claim == null,
          manufacturerMiPerKwhClaim: miPerKwhClaim,
          clearManufacturerMiPerKwhClaim: miPerKwhClaim == null,
          batteryKwhCapacity: battery,
          clearBatteryCapacity: battery == null,
        ),
      );
    } else {
      await _data.addVehicle(
        name: nameController.text.trim(),
        energyMode: energyMode.value,
        vehicleType: vehicleType.value,
        makeModel: makeModelController.text.trim(),
        year: int.tryParse(yearController.text.trim()) ?? DateTime.now().year,
        odometer: double.tryParse(odometerController.text.trim()) ?? 0,
        manufacturerMpgClaim: claim,
        manufacturerMiPerKwhClaim: miPerKwhClaim,
        batteryKwhCapacity: battery,
      );
    }

    isSaving.value = false;
    Get.back();
    Get.snackbar(
      isEditing ? 'Vehicle updated' : 'Vehicle added',
      nameController.text.trim(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    makeModelController.dispose();
    yearController.dispose();
    odometerController.dispose();
    claimedMpgController.dispose();
    claimedMiPerKwhController.dispose();
    batteryController.dispose();
    super.onClose();
  }
}
