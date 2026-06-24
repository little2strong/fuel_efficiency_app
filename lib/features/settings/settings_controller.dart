import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/utils/app_logger.dart';
import 'package:fuel_efficiency_app/core/services/auth_service.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class SettingsController extends GetxController {
  SettingsController(this._data);

  final AppDataController _data;

  String get appName => AppConstants.appName;
  String get appVersion => AppConstants.appVersion;

  RxString get distanceUnit => _data.distanceUnit;
  RxString get volumeUnit => _data.volumeUnit;
  RxString get currencySymbol => _data.currencySymbol;
  Rx<ThemeMode> get themeMode => _data.themeMode;
  RxBool get notificationsEnabled => _data.notificationsEnabled;
  RxDouble get fuelPrice => _data.defaultFuelPrice;
  RxDouble get electricityPrice => _data.defaultElectricityPrice;
  RxString get userName => _data.userName;
  RxString get userEmail => _data.userEmail;

  bool get isDarkMode => _data.themeMode.value == ThemeMode.dark;

  /// Short label for the active volume unit (e.g. "L" or "gal").
  String get volumeUnitShort =>
      _data.volumeUnit.value.toLowerCase().startsWith('g') ? 'gal' : 'L';

  Future<void> setDistanceUnit(String value) =>
      _data.updateSettings(newDistanceUnit: value);

  Future<void> setVolumeUnit(String value) =>
      _data.updateSettings(newVolumeUnit: value);

  Future<void> setCurrency(String value) =>
      _data.updateSettings(newCurrencySymbol: value);

  Future<void> toggleDarkMode(bool enabled) => _data.toggleDarkMode(enabled);

  Future<void> toggleNotifications(bool enabled) async {
    await _data.updateSettings(newNotifications: enabled);
    Get.snackbar(
      'Notifications',
      enabled ? 'Reminders enabled.' : 'Reminders disabled.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> setEnergyPrices({double? fuel, double? electricity}) => _data
      .updateSettings(newFuelPrice: fuel, newElectricityPrice: electricity);

  Future<void> exportJson() async {
    try {
      await _data.exportJson();
    } catch (e, s) {
      AppLogger.error('Export JSON failed', e, s);
      Get.snackbar(
        'Export failed',
        'Could not export data.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> exportCsv() async {
    try {
      await _data.exportCsv();
    } catch (e, s) {
      AppLogger.error('Export CSV failed', e, s);
      Get.snackbar(
        'Export failed',
        'Could not export entries.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> backup() async {
    try {
      final path = await _data.saveBackup();
      Get.snackbar(
        'Backup saved',
        'Stored at $path',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e, s) {
      AppLogger.error('Backup failed', e, s);
      Get.snackbar(
        'Backup failed',
        'Could not create a backup.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<int?> importFromText(String raw) async {
    try {
      final count = await _data.importFromJson(raw);
      Get.snackbar(
        'Import complete',
        'Added $count new entries.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return count;
    } catch (e, s) {
      AppLogger.error('Import failed', e, s);
      Get.snackbar(
        'Import failed',
        'The data could not be read.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<void> logout() async {
    await Get.find<AuthService>().signOut();
    await _data.logout();
  }

  Future<void> resetAll() async {
    await Get.find<AuthService>().signOut();
    await _data.clearAllData();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    await Get.find<AuthService>().updateDisplayName(name);
    await _data.updateProfile(name: name, email: email);
  }
}
