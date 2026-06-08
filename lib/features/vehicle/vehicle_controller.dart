import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class VehicleController extends GetxController {
  VehicleController(this._storage);

  final LocalStorageProvider _storage;

  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadVehicles();
  }

  void loadVehicles() {
    isLoading.value = true;
    vehicles.assignAll(VehicleModel.loadAll(_storage));
    isLoading.value = false;
  }

  Future<void> addVehicle({
    required String name,
    required String fuelType,
    required double odometer,
  }) async {
    final vehicle = VehicleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      fuelType: fuelType,
      odometer: odometer,
    );

    final updated = VehicleModel.loadAll(_storage)..add(vehicle);
    await VehicleModel.saveAll(_storage, updated);
    loadVehicles();
    Get.back();
    Get.snackbar('Success', 'Vehicle added');
  }
}
