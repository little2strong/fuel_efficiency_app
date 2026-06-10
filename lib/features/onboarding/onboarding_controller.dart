import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._data);

  final AppDataController _data;

  /// 0 = Welcome, 1 = Auth, 2 = Vehicle mode, 3 = Vehicle details.
  final RxInt step = 0.obs;
  static const int lastStep = 3;

  final Rx<EnergyMode> selectedMode = EnergyMode.fuel.obs;
  final RxString selectedVehicleType = 'Car'.obs;
  final RxBool isSignUp = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isSubmitting = false.obs;

  static const vehicleTypes = ['Car', 'SUV', 'Van', 'Truck', 'Motorbike'];

  final loginFormKey = GlobalKey<FormState>();
  final vehicleFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final vehicleNameController = TextEditingController();
  final makeModelController = TextEditingController();
  final yearController = TextEditingController();
  final odometerController = TextEditingController();
  final claimedMpgController = TextEditingController();
  final claimedMiPerKwhController = TextEditingController();
  final batteryCapacityController = TextEditingController();

  void next() {
    if (step.value < lastStep) step.value += 1;
  }

  void back() {
    if (step.value > 0) step.value -= 1;
  }

  void togglePassword() => obscurePassword.toggle();

  void toggleAuthMode() => isSignUp.toggle();

  String? validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(text)) return 'Enter a valid email';
    return null;
  }

  String? validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  String? validateName(String? value) {
    if (!isSignUp.value) return null;
    return validateRequired(value, 'Name');
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  String? validateYear(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
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

  /// Static auth — validates form then advances to vehicle setup.
  void submitAuth() {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
    next();
  }

  /// Static social auth — pre-fills profile fields and advances.
  void socialSignIn(String provider) {
    if (nameController.text.trim().isEmpty) {
      nameController.text = provider == 'apple' ? 'Apple User' : 'Google User';
    }
    if (emailController.text.trim().isEmpty) {
      emailController.text =
          '${provider == 'apple' ? 'apple' : 'google'}.user@example.com';
    }
    next();
  }

  Future<void> finish() async {
    if (!(vehicleFormKey.currentState?.validate() ?? false)) return;
    isSubmitting.value = true;

    final displayName = nameController.text.trim().isEmpty
        ? 'Driver'
        : nameController.text.trim();
    final email = emailController.text.trim().isEmpty
        ? 'driver@example.com'
        : emailController.text.trim();

    await _data.updateSession(
      completedOnboarding: true,
      loggedInState: true,
      name: displayName,
      email: email,
    );

    await _data.addVehicle(
      name: vehicleNameController.text.trim(),
      energyMode: selectedMode.value,
      vehicleType: selectedVehicleType.value,
      makeModel: makeModelController.text.trim(),
      year: int.tryParse(yearController.text.trim()) ?? DateTime.now().year,
      odometer: double.tryParse(odometerController.text.trim()) ?? 0,
      manufacturerMpgClaim: selectedMode.value.usesFuel
          ? double.tryParse(claimedMpgController.text.trim())
          : null,
      manufacturerMiPerKwhClaim: selectedMode.value.usesCharge
          ? double.tryParse(claimedMiPerKwhController.text.trim())
          : null,
      batteryKwhCapacity: selectedMode.value.usesCharge
          ? double.tryParse(batteryCapacityController.text.trim())
          : null,
    );

    await _data.loadDemoContent();

    isSubmitting.value = false;
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    vehicleNameController.dispose();
    makeModelController.dispose();
    yearController.dispose();
    odometerController.dispose();
    claimedMpgController.dispose();
    claimedMiPerKwhController.dispose();
    batteryCapacityController.dispose();
    super.onClose();
  }
}
