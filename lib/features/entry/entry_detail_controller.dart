import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/efficiency_service.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class EntryDetailController extends GetxController {
  EntryDetailController(this._data);

  final AppDataController _data;

  late final String _entryId;
  final RxBool exists = true.obs;

  RxString get currencySymbol => _data.currencySymbol;
  RxString get distanceUnit => _data.distanceUnit;
  RxString get volumeUnit => _data.volumeUnit;
  EfficiencyService get efficiency => _data.efficiency;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    _entryId = arg is FuelEntryModel ? arg.id : '';
  }

  FuelEntryModel? get entry =>
      _data.entries.firstWhereOrNull((e) => e.id == _entryId);

  VehicleModel? get vehicle {
    final e = entry;
    if (e == null) return null;
    return _data.vehicles.firstWhereOrNull((v) => v.id == e.vehicleId);
  }

  double get mpg {
    final e = entry;
    if (e == null) return 0;
    return efficiency.mpg(
      distance: e.distance,
      litres: e.liters,
      distanceUnit: distanceUnit.value,
      volumeUnit: volumeUnit.value,
    );
  }

  double get milesPerKwh {
    final e = entry;
    if (e == null) return 0;
    return efficiency.milesPerKwh(
      distance: e.distance,
      kwh: e.kwh,
      distanceUnit: distanceUnit.value,
    );
  }

  void edit() {
    final e = entry;
    if (e != null) Get.toNamed(AppRoutes.entryForm, arguments: e);
  }

  Future<void> delete() async {
    await _data.deleteEntry(_entryId);
    exists.value = false;
    Get.back();
    Get.snackbar(
      'Deleted',
      'Entry removed.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
