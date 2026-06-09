import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class OnboardingController extends GetxController {
  final RxInt step = 0.obs;
  final Rx<EnergyMode> selectedMode = EnergyMode.fuel.obs;
  final RxString selectedVehicleType = 'Car'.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController vehicleNameController = TextEditingController();
  final TextEditingController makeModelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController claimedMpgController = TextEditingController();
  final TextEditingController batteryCapacityController = TextEditingController();

  AppDataController get _data => Get.find<AppDataController>();

  @override
  void onReady() {
    super.onReady();
    // Auto-progress intro so first-time users don't feel the app is stuck.
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (step.value == 0) {
        step.value = 1;
      }
    });
  }

  void nextStep() {
    if (step.value < 4) {
      step.value += 1;
    }
  }

  void backStep() {
    if (step.value > 0) {
      step.value -= 1;
    }
  }

  void moveToSignIn() => step.value = 2;

  void moveToVehicleMode() => step.value = 3;

  Future<void> saveAndContinue() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final vehicleName = vehicleNameController.text.trim();
    final makeModel = makeModelController.text.trim();
    final year = int.tryParse(yearController.text.trim());
    final odometer = double.tryParse(odometerController.text.trim());
    final claimedMpg = double.tryParse(claimedMpgController.text.trim());
    final batteryCapacity = double.tryParse(batteryCapacityController.text.trim());

    if (name.isEmpty || email.isEmpty) {
      Get.snackbar('Missing details', 'Please enter your name and email.');
      step.value = 2;
      return;
    }

    if (vehicleName.isEmpty ||
        makeModel.isEmpty ||
        year == null ||
        odometer == null) {
      Get.snackbar('Incomplete vehicle', 'Please fill all required fields.');
      step.value = 4;
      return;
    }

    await _data.updateSession(
      completedOnboarding: true,
      loggedInState: true,
      name: name,
      email: email,
    );

    await _data.addVehicle(
      name: vehicleName,
      energyMode: selectedMode.value,
      vehicleType: selectedVehicleType.value,
      makeModel: makeModel,
      year: year,
      odometer: odometer,
      manufacturerMpgClaim:
          (selectedMode.value == EnergyMode.fuel ||
                  selectedMode.value == EnergyMode.hybrid)
              ? claimedMpg
              : null,
      batteryKwhCapacity:
          (selectedMode.value == EnergyMode.charge ||
                  selectedMode.value == EnergyMode.hybrid)
              ? batteryCapacity
              : null,
    );

    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    vehicleNameController.dispose();
    makeModelController.dispose();
    yearController.dispose();
    odometerController.dispose();
    claimedMpgController.dispose();
    batteryCapacityController.dispose();
    super.onClose();
  }
}
