import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class FuelController extends GetxController {
  FuelController(this._storage);

  final LocalStorageProvider _storage;

  final RxList<FuelEntryModel> entries = <FuelEntryModel>[].obs;
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    isLoading.value = true;
    vehicles.assignAll(VehicleModel.loadAll(_storage));
    entries
      ..assignAll(FuelEntryModel.loadAll(_storage))
      ..sort((a, b) => b.date.compareTo(a.date));
    isLoading.value = false;
  }

  Future<void> addEntry({
    required String vehicleId,
    required double liters,
    required double cost,
    required double odometer,
  }) async {
    final entry = FuelEntryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      date: DateTime.now(),
      liters: liters,
      cost: cost,
      odometer: odometer,
    );

    final updated = FuelEntryModel.loadAll(_storage)..add(entry);
    await FuelEntryModel.saveAll(_storage, updated);
    loadData();
    Get.back();
    Get.snackbar('Success', 'Fuel entry added');
  }
}
