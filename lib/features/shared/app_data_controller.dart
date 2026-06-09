import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class AppDataController extends GetxController {
  AppDataController(this._storage);

  final LocalStorageProvider _storage;

  final RxBool onboardingComplete = false.obs;
  final RxBool loggedIn = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString distanceUnit = AppConstants.defaultDistanceUnit.obs;
  final RxString currencySymbol = AppConstants.defaultCurrencySymbol.obs;

  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxList<FuelEntryModel> entries = <FuelEntryModel>[].obs;
  final RxString selectedVehicleId = ''.obs;
  final RxBool isHydrated = false.obs;

  @override
  void onInit() {
    super.onInit();
    hydrate();
  }

  void hydrate() {
    onboardingComplete.value =
        _storage.read<bool>(AppConstants.keyOnboardingComplete) ?? false;
    loggedIn.value = _storage.read<bool>(AppConstants.keyLoggedIn) ?? false;
    userName.value = _storage.read<String>(AppConstants.keyUserName) ?? '';
    userEmail.value = _storage.read<String>(AppConstants.keyUserEmail) ?? '';
    distanceUnit.value = _storage.read<String>(AppConstants.keyDistanceUnit) ??
        AppConstants.defaultDistanceUnit;
    currencySymbol.value = _storage.read<String>(AppConstants.keyCurrencySymbol) ??
        AppConstants.defaultCurrencySymbol;

    vehicles.assignAll(VehicleModel.loadAll(_storage));
    entries
      ..assignAll(FuelEntryModel.loadAll(_storage))
      ..sort((a, b) => b.date.compareTo(a.date));

    selectedVehicleId.value =
        _storage.read<String>(AppConstants.keySelectedVehicleId) ?? '';
    if (selectedVehicleId.value.isEmpty && vehicles.isNotEmpty) {
      selectedVehicleId.value = vehicles.first.id;
    }
    isHydrated.value = true;
  }

  Future<void> _persistSession() async {
    await _storage.write(
      AppConstants.keyOnboardingComplete,
      onboardingComplete.value,
    );
    await _storage.write(AppConstants.keyLoggedIn, loggedIn.value);
    await _storage.write(AppConstants.keyUserName, userName.value);
    await _storage.write(AppConstants.keyUserEmail, userEmail.value);
  }

  Future<void> _persistSettings() async {
    await _storage.write(AppConstants.keyDistanceUnit, distanceUnit.value);
    await _storage.write(AppConstants.keyCurrencySymbol, currencySymbol.value);
    await _storage.write(
      AppConstants.keySelectedVehicleId,
      selectedVehicleId.value,
    );
  }

  Future<void> updateSession({
    required bool completedOnboarding,
    required bool loggedInState,
    required String name,
    required String email,
  }) async {
    onboardingComplete.value = completedOnboarding;
    loggedIn.value = loggedInState;
    userName.value = name;
    userEmail.value = email;
    await _persistSession();
  }

  Future<void> updateSettings({
    String? newDistanceUnit,
    String? newCurrencySymbol,
  }) async {
    if (newDistanceUnit != null) {
      distanceUnit.value = newDistanceUnit;
    }
    if (newCurrencySymbol != null) {
      currencySymbol.value = newCurrencySymbol;
    }
    await _persistSettings();
  }

  Future<void> selectVehicle(String vehicleId) async {
    selectedVehicleId.value = vehicleId;
    await _persistSettings();
  }

  Future<void> addVehicle({
    required String name,
    required EnergyMode energyMode,
    required String vehicleType,
    required String makeModel,
    required int year,
    required double odometer,
    double? manufacturerMpgClaim,
    double? batteryKwhCapacity,
  }) async {
    final vehicle = VehicleModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      energyMode: energyMode,
      vehicleType: vehicleType,
      makeModel: makeModel,
      year: year,
      manufacturerMpgClaim: manufacturerMpgClaim,
      batteryKwhCapacity: batteryKwhCapacity,
      odometer: odometer,
    );
    final updated = List<VehicleModel>.from(vehicles)..add(vehicle);
    vehicles.assignAll(updated);
    await VehicleModel.saveAll(_storage, updated);
    await selectVehicle(vehicle.id);
  }

  Future<void> addEntry({
    required String vehicleId,
    required EnergyMode mode,
    required double distance,
    required double odometer,
    double liters = 0,
    double kwh = 0,
    double fuelCost = 0,
    double electricityCost = 0,
    DateTime? date,
  }) async {
    final entry = FuelEntryModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      date: date ?? DateTime.now(),
      mode: mode,
      distance: distance,
      liters: liters,
      kwh: kwh,
      fuelCost: fuelCost,
      electricityCost: electricityCost,
      odometer: odometer,
    );
    final updated = List<FuelEntryModel>.from(entries)..add(entry);
    updated.sort((a, b) => b.date.compareTo(a.date));
    entries.assignAll(updated);
    await FuelEntryModel.saveAll(_storage, updated);

    final vehicleIndex = vehicles.indexWhere((v) => v.id == vehicleId);
    if (vehicleIndex != -1) {
      final updatedVehicle = vehicles[vehicleIndex].copyWith(odometer: odometer);
      final vehicleList = List<VehicleModel>.from(vehicles)
        ..[vehicleIndex] = updatedVehicle;
      vehicles.assignAll(vehicleList);
      await VehicleModel.saveAll(_storage, vehicleList);
    }
  }

  VehicleModel? get selectedVehicle {
    if (selectedVehicleId.value.isEmpty) return null;
    return vehicles.firstWhereOrNull((v) => v.id == selectedVehicleId.value);
  }

  List<FuelEntryModel> get selectedVehicleEntries {
    final vehicleId = selectedVehicleId.value;
    if (vehicleId.isEmpty) return const [];
    return entries.where((entry) => entry.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get avgMpg {
    final relevant = selectedVehicleEntries.where((e) => e.liters > 0).toList();
    final totalDistance =
        relevant.fold<double>(0, (sum, entry) => sum + entry.distance);
    final totalLiters = relevant.fold<double>(0, (sum, entry) => sum + entry.liters);
    if (totalLiters <= 0) return 0;
    final kmPerLiter = totalDistance / totalLiters;
    return kmPerLiter * 2.35215;
  }

  double get avgKwhPer100 {
    final relevant = selectedVehicleEntries.where((e) => e.kwh > 0).toList();
    final totalDistance =
        relevant.fold<double>(0, (sum, entry) => sum + entry.distance);
    final totalKwh = relevant.fold<double>(0, (sum, entry) => sum + entry.kwh);
    if (totalDistance <= 0) return 0;
    return (totalKwh / totalDistance) * 100;
  }

  double get avgCostPerDistance {
    final relevant = selectedVehicleEntries;
    final totalDistance =
        relevant.fold<double>(0, (sum, entry) => sum + entry.distance);
    final totalCost = relevant.fold<double>(0, (sum, entry) => sum + entry.totalCost);
    if (totalDistance <= 0) return 0;
    return totalCost / totalDistance;
  }

  double get monthlyFuelCost {
    final now = DateTime.now();
    final monthEntries = selectedVehicleEntries.where(
      (entry) => entry.date.year == now.year && entry.date.month == now.month,
    );
    return monthEntries.fold<double>(0, (sum, entry) => sum + entry.totalCost);
  }

  double get claimedMpg {
    return selectedVehicle?.manufacturerMpgClaim ?? 0;
  }

  double get realityPercent {
    final claim = claimedMpg;
    if (claim <= 0) return 0;
    return (avgMpg / claim) * 100;
  }

  double get differencePercent {
    final claim = claimedMpg;
    if (claim <= 0) return 0;
    return ((avgMpg - claim) / claim) * 100;
  }

  Future<void> clearAllData() async {
    onboardingComplete.value = false;
    loggedIn.value = false;
    userName.value = '';
    userEmail.value = '';
    selectedVehicleId.value = '';
    vehicles.clear();
    entries.clear();
    await _storage.clear();
    await _persistSettings();
  }

  Future<void> logout() async {
    loggedIn.value = false;
    await _storage.write(AppConstants.keyLoggedIn, false);
  }
}
