import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class SettingsController extends GetxController {
  SettingsController(this._data);

  final AppDataController _data;

  final RxString appVersion = '1.0.0'.obs;

  String get appName => AppConstants.appName;

  RxString get distanceUnit => _data.distanceUnit;
  RxString get currencySymbol => _data.currencySymbol;

  Future<void> setDistanceUnit(String value) async {
    await _data.updateSettings(newDistanceUnit: value);
  }

  Future<void> setCurrency(String value) async {
    await _data.updateSettings(newCurrencySymbol: value);
  }

  Future<void> exportData() async {
    Get.snackbar('Export', 'Export will be added in next iteration.');
  }

  Future<void> backupData() async {
    Get.snackbar('Backup', 'Backup is planned for cloud sync update.');
  }

  Future<void> logout() async {
    await _data.logout();
  }

  Future<void> resetAll() async {
    await _data.clearAllData();
  }
}
