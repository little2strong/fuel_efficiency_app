import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/core/utils/app_logger.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/shared/data_transfer_service.dart';
import 'package:fuel_efficiency_app/features/shared/demo_data_service.dart';
import 'package:fuel_efficiency_app/features/shared/efficiency_service.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

/// Single source of truth for session, settings, vehicles and entries.
///
/// Acts as the application repository on top of [LocalStorageProvider] and
/// exposes derived analytics through [EfficiencyService].
class AppDataController extends GetxController {
  AppDataController(
    this._storage, {
    this.efficiency = const EfficiencyService(),
    this._transfer = const DataTransferService(),
  });

  final LocalStorageProvider _storage;
  final EfficiencyService efficiency;
  final DataTransferService _transfer;

  // Session
  final RxBool onboardingComplete = false.obs;
  final RxBool loggedIn = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userId = ''.obs;

  // Settings
  final RxString distanceUnit = AppConstants.defaultDistanceUnit.obs;
  final RxString volumeUnit = AppConstants.defaultVolumeUnit.obs;
  final RxString currencySymbol = AppConstants.defaultCurrencySymbol.obs;
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxDouble defaultFuelPrice = 0.0.obs;
  final RxDouble defaultElectricityPrice = 0.0.obs;

  // Data
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxList<FuelEntryModel> entries = <FuelEntryModel>[].obs;
  final RxString selectedVehicleId = ''.obs;
  final RxBool isHydrated = false.obs;

  @override
  void onInit() {
    super.onInit();
    hydrate();
  }

  Future<void> hydrate() async {
    onboardingComplete.value =
        _storage.read<bool>(AppConstants.keyOnboardingComplete) ?? false;
    loggedIn.value = _storage.read<bool>(AppConstants.keyLoggedIn) ?? false;
    userName.value = _storage.read<String>(AppConstants.keyUserName) ?? '';
    userEmail.value = _storage.read<String>(AppConstants.keyUserEmail) ?? '';
    userId.value = _storage.read<String>(AppConstants.keyUserId) ?? '';

    distanceUnit.value =
        _storage.read<String>(AppConstants.keyDistanceUnit) ??
        AppConstants.defaultDistanceUnit;
    volumeUnit.value =
        _storage.read<String>(AppConstants.keyVolumeUnit) ??
        AppConstants.defaultVolumeUnit;
    currencySymbol.value =
        _storage.read<String>(AppConstants.keyCurrencySymbol) ??
        AppConstants.defaultCurrencySymbol;
    themeMode.value = _themeFromString(
      _storage.read<String>(AppConstants.keyThemeMode),
    );
    notificationsEnabled.value =
        _storage.read<bool>(AppConstants.keyNotifications) ?? true;
    defaultFuelPrice.value =
        (_storage.read<num>(AppConstants.keyFuelPrice) ??
                AppConstants.defaultFuelPricePerLitre)
            .toDouble();
    defaultElectricityPrice.value =
        (_storage.read<num>(AppConstants.keyElectricityPrice) ??
                AppConstants.defaultElectricityPricePerKwh)
            .toDouble();

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

  ThemeMode _themeFromString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }

  /// Loads bundled demo vehicles and entries after onboarding completes.
  /// Preserves the user's session and any vehicle they created during setup.
  Future<void> loadDemoContent() async {
    if (_storage.read<bool>(AppConstants.keyDemoSeeded) == true) return;

    final demo = DemoDataService.create();
    if (defaultFuelPrice.value <= 0) {
      defaultFuelPrice.value = demo.defaultFuelPrice;
    }
    if (defaultElectricityPrice.value <= 0) {
      defaultElectricityPrice.value = demo.defaultElectricityPrice;
    }

    final vehicleIds = vehicles.map((v) => v.id).toSet();
    for (final vehicle in demo.vehicles) {
      if (!vehicleIds.contains(vehicle.id)) {
        vehicles.add(vehicle);
      }
    }

    final entryIds = entries.map((e) => e.id).toSet();
    for (final entry in demo.entries) {
      if (!entryIds.contains(entry.id)) {
        entries.add(entry);
      }
    }
    entries.sort((a, b) => b.date.compareTo(a.date));

    if (vehicles.any((v) => v.id == 'demo-golf')) {
      selectedVehicleId.value = 'demo-golf';
    }

    await _persistSettings();
    await _persistVehicles();
    await _persistEntries();
    await _storage.write(AppConstants.keyDemoSeeded, true);
  }

  // ---------------------------------------------------------------------------
  // Persistence helpers
  // ---------------------------------------------------------------------------
  Future<void> _persistSession() async {
    await _storage.write(
      AppConstants.keyOnboardingComplete,
      onboardingComplete.value,
    );
    await _storage.write(AppConstants.keyLoggedIn, loggedIn.value);
    await _storage.write(AppConstants.keyUserName, userName.value);
    await _storage.write(AppConstants.keyUserEmail, userEmail.value);
    await _storage.write(AppConstants.keyUserId, userId.value);
  }

  Future<void> _persistSettings() async {
    await _storage.write(AppConstants.keyDistanceUnit, distanceUnit.value);
    await _storage.write(AppConstants.keyVolumeUnit, volumeUnit.value);
    await _storage.write(AppConstants.keyCurrencySymbol, currencySymbol.value);
    await _storage.write(
      AppConstants.keyThemeMode,
      _themeToString(themeMode.value),
    );
    await _storage.write(
      AppConstants.keyNotifications,
      notificationsEnabled.value,
    );
    await _storage.write(AppConstants.keyFuelPrice, defaultFuelPrice.value);
    await _storage.write(
      AppConstants.keyElectricityPrice,
      defaultElectricityPrice.value,
    );
    await _storage.write(
      AppConstants.keySelectedVehicleId,
      selectedVehicleId.value,
    );
  }

  Future<void> _persistVehicles() =>
      VehicleModel.saveAll(_storage, vehicles.toList());

  Future<void> _persistEntries() =>
      FuelEntryModel.saveAll(_storage, entries.toList());

  // ---------------------------------------------------------------------------
  // Session & settings mutations
  // ---------------------------------------------------------------------------
  Future<void> updateSession({
    required bool completedOnboarding,
    required bool loggedInState,
    required String name,
    required String email,
    String? uid,
  }) async {
    onboardingComplete.value = completedOnboarding;
    loggedIn.value = loggedInState;
    userName.value = name;
    userEmail.value = email;
    if (uid != null) userId.value = uid;
    await _persistSession();
  }

  /// Updates local session from a signed-in Firebase user.
  Future<void> syncAuthUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    loggedIn.value = true;
    userId.value = uid;
    if (name.isNotEmpty) userName.value = name;
    if (email.isNotEmpty) userEmail.value = email;
    await _persistSession();
  }

  /// Clears auth state while keeping onboarding and app data.
  Future<void> clearAuthSession() async {
    loggedIn.value = false;
    userId.value = '';
    userName.value = '';
    userEmail.value = '';
    await _persistSession();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    userName.value = name;
    userEmail.value = email;
    await _persistSession();
  }

  Future<void> updateSettings({
    String? newDistanceUnit,
    String? newVolumeUnit,
    String? newCurrencySymbol,
    ThemeMode? newThemeMode,
    bool? newNotifications,
    double? newFuelPrice,
    double? newElectricityPrice,
  }) async {
    if (newDistanceUnit != null) distanceUnit.value = newDistanceUnit;
    if (newVolumeUnit != null) volumeUnit.value = newVolumeUnit;
    if (newCurrencySymbol != null) currencySymbol.value = newCurrencySymbol;
    if (newThemeMode != null) {
      themeMode.value = newThemeMode;
      Get.changeThemeMode(newThemeMode);
    }
    if (newNotifications != null) notificationsEnabled.value = newNotifications;
    if (newFuelPrice != null) defaultFuelPrice.value = newFuelPrice;
    if (newElectricityPrice != null) {
      defaultElectricityPrice.value = newElectricityPrice;
    }
    await _persistSettings();
  }

  Future<void> toggleDarkMode(bool enabled) =>
      updateSettings(newThemeMode: enabled ? ThemeMode.dark : ThemeMode.light);

  Future<void> selectVehicle(String vehicleId) async {
    selectedVehicleId.value = vehicleId;
    await _persistSettings();
  }

  // ---------------------------------------------------------------------------
  // Vehicle CRUD
  // ---------------------------------------------------------------------------
  Future<VehicleModel> addVehicle({
    required String name,
    required EnergyMode energyMode,
    required String vehicleType,
    required String makeModel,
    required int year,
    required double odometer,
    double? manufacturerMpgClaim,
    double? manufacturerMiPerKwhClaim,
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
      manufacturerMiPerKwhClaim: manufacturerMiPerKwhClaim,
      batteryKwhCapacity: batteryKwhCapacity,
      odometer: odometer,
    );
    vehicles.add(vehicle);
    await _persistVehicles();
    await selectVehicle(vehicle.id);
    return vehicle;
  }

  Future<void> updateVehicle(VehicleModel updated) async {
    final index = vehicles.indexWhere((v) => v.id == updated.id);
    if (index == -1) return;
    vehicles[index] = updated;
    vehicles.refresh();
    await _persistVehicles();
  }

  Future<void> deleteVehicle(String vehicleId) async {
    vehicles.removeWhere((v) => v.id == vehicleId);
    entries.removeWhere((e) => e.vehicleId == vehicleId);
    if (selectedVehicleId.value == vehicleId) {
      selectedVehicleId.value = vehicles.isNotEmpty ? vehicles.first.id : '';
    }
    await _persistVehicles();
    await _persistEntries();
    await _persistSettings();
  }

  // ---------------------------------------------------------------------------
  // Entry CRUD
  // ---------------------------------------------------------------------------
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
    String? fuelGrade,
    bool fullTank = true,
    String? note,
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
      fuelGrade: fuelGrade,
      fullTank: fullTank,
      note: note,
    );
    entries
      ..add(entry)
      ..sort((a, b) => b.date.compareTo(a.date));
    entries.refresh();
    await _persistEntries();
    await _syncVehicleOdometer(vehicleId);
  }

  Future<void> updateEntry(FuelEntryModel updated) async {
    final index = entries.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    entries[index] = updated;
    entries.sort((a, b) => b.date.compareTo(a.date));
    entries.refresh();
    await _persistEntries();
    await _syncVehicleOdometer(updated.vehicleId);
  }

  Future<void> deleteEntry(String entryId) async {
    final entry = entries.firstWhereOrNull((e) => e.id == entryId);
    entries.removeWhere((e) => e.id == entryId);
    await _persistEntries();
    if (entry != null) await _syncVehicleOdometer(entry.vehicleId);
  }

  /// Keeps a vehicle's odometer aligned with its most recent entry.
  Future<void> _syncVehicleOdometer(String vehicleId) async {
    final index = vehicles.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;
    final vehicleEntries = entries
        .where((e) => e.vehicleId == vehicleId)
        .toList();
    if (vehicleEntries.isEmpty) return;
    final latestOdometer = vehicleEntries
        .map((e) => e.odometer)
        .reduce((a, b) => a > b ? a : b);
    if (vehicles[index].odometer == latestOdometer) return;
    vehicles[index] = vehicles[index].copyWith(odometer: latestOdometer);
    vehicles.refresh();
    await _persistVehicles();
  }

  // ---------------------------------------------------------------------------
  // Derived data
  // ---------------------------------------------------------------------------
  VehicleModel? get selectedVehicle {
    if (selectedVehicleId.value.isEmpty) return null;
    return vehicles.firstWhereOrNull((v) => v.id == selectedVehicleId.value);
  }

  List<FuelEntryModel> entriesFor(String vehicleId) {
    return entries.where((e) => e.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<FuelEntryModel> get selectedVehicleEntries =>
      selectedVehicleId.value.isEmpty
      ? const []
      : entriesFor(selectedVehicleId.value);

  EfficiencyStats statsFor(EfficiencyMetric metric) => efficiency.stats(
    selectedVehicleEntries,
    metric,
    distanceUnit.value,
    volumeUnit: volumeUnit.value,
  );

  double get avgMpg => statsFor(EfficiencyMetric.mpg).average;

  double get avgMilesPerKwh => statsFor(EfficiencyMetric.milesPerKwh).average;

  double get avgCostPerDistance =>
      statsFor(EfficiencyMetric.costPerDistance).average;

  double get monthlyFuelCost => efficiency.monthlyCost(selectedVehicleEntries);

  double get totalDistance =>
      selectedVehicleEntries.fold<double>(0, (sum, e) => sum + e.distance);

  double get totalCost =>
      selectedVehicleEntries.fold<double>(0, (sum, e) => sum + e.totalCost);

  int get daysTracked {
    final list = selectedVehicleEntries;
    if (list.isEmpty) return 0;
    final earliest = list
        .map((e) => e.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime.now().difference(earliest).inDays + 1;
  }

  double get claimedMpg => selectedVehicle?.manufacturerMpgClaim ?? 0;

  double get claimedMiPerKwh => selectedVehicle?.manufacturerMiPerKwhClaim ?? 0;

  double get realityPercent {
    final vehicle = selectedVehicle;
    if (vehicle == null) return 0;
    if (vehicle.energyMode == EnergyMode.charge) {
      return efficiency.realityPercent(avgMilesPerKwh, claimedMiPerKwh);
    }
    if (vehicle.energyMode == EnergyMode.hybrid) {
      final fuelPct = claimedMpg > 0
          ? efficiency.realityPercent(avgMpg, claimedMpg)
          : 0.0;
      final electricPct = claimedMiPerKwh > 0
          ? efficiency.realityPercent(avgMilesPerKwh, claimedMiPerKwh)
          : 0.0;
      if (fuelPct > 0 && electricPct > 0) return (fuelPct + electricPct) / 2;
      return fuelPct > 0 ? fuelPct : electricPct;
    }
    return efficiency.realityPercent(avgMpg, claimedMpg);
  }

  double get differencePercent {
    final vehicle = selectedVehicle;
    if (vehicle == null) return 0;
    if (vehicle.energyMode == EnergyMode.charge) {
      return efficiency.differencePercent(avgMilesPerKwh, claimedMiPerKwh);
    }
    if (vehicle.energyMode == EnergyMode.hybrid) {
      return efficiency.differencePercent(avgMpg, claimedMpg);
    }
    return efficiency.differencePercent(avgMpg, claimedMpg);
  }

  double get monthlyDistance =>
      efficiency.monthlyDistance(selectedVehicleEntries);

  double get monthlyCostPerDistance =>
      efficiency.monthlyCostPerDistance(selectedVehicleEntries);

  double get savingsVsClaim {
    final vehicle = selectedVehicle;
    if (vehicle == null) return 0;
    if (vehicle.energyMode == EnergyMode.charge) {
      return efficiency.savingsVsElectricClaim(
        entries: selectedVehicleEntries,
        claimedMiPerKwh: claimedMiPerKwh,
        distanceUnit: distanceUnit.value,
      );
    }
    if (vehicle.energyMode == EnergyMode.hybrid) {
      var total = 0.0;
      if (claimedMpg > 0) {
        total += efficiency.savingsVsClaim(
          entries: selectedVehicleEntries,
          claimedMpg: claimedMpg,
          distanceUnit: distanceUnit.value,
          volumeUnit: volumeUnit.value,
        );
      }
      if (claimedMiPerKwh > 0) {
        total += efficiency.savingsVsElectricClaim(
          entries: selectedVehicleEntries,
          claimedMiPerKwh: claimedMiPerKwh,
          distanceUnit: distanceUnit.value,
        );
      }
      return total;
    }
    return efficiency.savingsVsClaim(
      entries: selectedVehicleEntries,
      claimedMpg: claimedMpg,
      distanceUnit: distanceUnit.value,
      volumeUnit: volumeUnit.value,
    );
  }

  // ---------------------------------------------------------------------------
  // Import / export
  // ---------------------------------------------------------------------------
  Future<void> exportJson() => _transfer.exportJson(
    vehicles: vehicles.toList(),
    entries: entries.toList(),
  );

  Future<void> exportCsv() => _transfer.exportCsv(entries.toList());

  Future<String> saveBackup() => _transfer.saveBackup(
    vehicles: vehicles.toList(),
    entries: entries.toList(),
  );

  Future<int> importFromJson(String raw, {bool merge = true}) async {
    final payload = _transfer.parseJson(raw);
    if (!merge) {
      vehicles.clear();
      entries.clear();
    }
    final vehicleIds = vehicles.map((v) => v.id).toSet();
    for (final v in payload.vehicles) {
      if (!vehicleIds.contains(v.id)) {
        vehicles.add(v);
        vehicleIds.add(v.id);
      }
    }
    final entryIds = entries.map((e) => e.id).toSet();
    var imported = 0;
    for (final e in payload.entries) {
      if (!entryIds.contains(e.id)) {
        entries.add(e);
        entryIds.add(e.id);
        imported++;
      }
    }
    entries.sort((a, b) => b.date.compareTo(a.date));
    if (selectedVehicleId.value.isEmpty && vehicles.isNotEmpty) {
      selectedVehicleId.value = vehicles.first.id;
    }
    await _persistVehicles();
    await _persistEntries();
    await _persistSettings();
    AppLogger.info('Imported $imported new entries.');
    return imported;
  }

  // ---------------------------------------------------------------------------
  // Session lifecycle
  // ---------------------------------------------------------------------------
  Future<void> clearAllData() async {
    onboardingComplete.value = false;
    loggedIn.value = false;
    userName.value = '';
    userEmail.value = '';
    userId.value = '';
    selectedVehicleId.value = '';
    vehicles.clear();
    entries.clear();
    await _storage.clear();
    await _persistSettings();
  }

  Future<void> logout() async {
    await clearAuthSession();
  }
}
