import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/core/services/auth_service.dart';
import 'package:fuel_efficiency_app/core/utils/auth_error_messages.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._data, this._auth);

  final AppDataController _data;
  final AuthService _auth;

  /// 0 = Welcome, 1 = Auth, 2 = Vehicle mode, 3 = Vehicle details.
  final RxInt step = 0.obs;
  static const int lastStep = 3;

  final Rx<EnergyMode> selectedMode = EnergyMode.fuel.obs;
  final RxString selectedVehicleType = 'Car'.obs;
  final RxBool isSignUp = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isAuthLoading = false.obs;

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

  @override
  void onInit() {
    super.onInit();
    if (_data.onboardingComplete.value) {
      step.value = 1;
      isSignUp.value = false;
    }
  }

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

  Future<void> submitAuth() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    isAuthLoading.value = true;
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      final name = nameController.text.trim();

      if (isSignUp.value) {
        await _auth.signUp(
          email: email,
          password: password,
          displayName: name,
        );
      } else {
        await _auth.signIn(email: email, password: password);
      }

      await _auth.syncSession(_data);

      if (_data.onboardingComplete.value) {
        Get.offAllNamed(AppRoutes.main);
        return;
      }

      if (isSignUp.value && name.isNotEmpty) {
        nameController.text = name;
      }

      next();
    } catch (error) {
      Get.snackbar(
        isSignUp.value ? 'Sign up failed' : 'Log in failed',
        authErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAuthLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Email required',
        'Enter your email address first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (validateEmail(email) != null) {
      Get.snackbar(
        'Invalid email',
        'Enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isAuthLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email);
      Get.snackbar(
        'Reset email sent',
        'Check your inbox for password reset instructions.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (error) {
      Get.snackbar(
        'Reset failed',
        authErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAuthLoading.value = false;
    }
  }

  Future<void> finish() async {
    if (!(vehicleFormKey.currentState?.validate() ?? false)) return;
    isSubmitting.value = true;

    final user = _auth.currentUser;
    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (nameController.text.trim().isEmpty
              ? 'Driver'
              : nameController.text.trim());
    final email = user?.email?.trim().isNotEmpty == true
        ? user!.email!.trim()
        : emailController.text.trim();

    await _data.updateSession(
      completedOnboarding: true,
      loggedInState: true,
      name: displayName,
      email: email,
      uid: user?.uid,
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
