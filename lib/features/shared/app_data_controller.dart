import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/core/services/firestore_service.dart';
import 'package:fuel_efficiency_app/core/utils/app_logger.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/shared/data_transfer_service.dart';
import 'package:fuel_efficiency_app/features/shared/efficiency_service.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

/// Single source of truth for session, settings, vehicles and entries.
///
/// Persists locally via [LocalStorageProvider] and syncs to Cloud Firestore
/// when a Firebase user is signed in.
class AppDataController extends GetxController {
  AppDataController(
    this._storage,
    this._firestore, {
    this.efficiency = const EfficiencyService(),
    this._transfer = const DataTransferService(),
  });

  final LocalStorageProvider _storage;
  final FirestoreService _firestore;
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
  final RxBool isSyncing = false.obs;
  final RxString cloudSyncError = ''.obs;

  /// Prefer the live Firebase Auth uid so Firestore rules match the signed-in user.
  String? get _uid {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) return authUid;
    return userId.value.isEmpty ? null : userId.value;
  }

  bool get _useCloud => FirebaseAuth.instance.currentUser != null && _uid != null;

  @override
  void onInit() {
    super.onInit();
    hydrate();
  }

  Future<void> hydrate() async {
    try {
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

      if (_purgeLegacyDemoDataLocal()) {
        await _persistVehicles();
        await _persistEntries();
        await _persistSettings();
      }
    } catch (error, stackTrace) {
      AppLogger.error('Hydrate failed', error, stackTrace);
    } finally {
      isHydrated.value = true;
    }
  }

  /// Pulls cloud data after sign-in, or uploads local data on first sync.
  Future<bool> syncFromCloud() async {
    final uid = _uid;
    if (uid == null) return false;

    isSyncing.value = true;
    cloudSyncError.value = '';
    var success = true;

    try {
      UserCloudData? cloud;
      try {
        cloud = await _firestore.fetchUserData(uid);
      } catch (error, stackTrace) {
        AppLogger.error('Cloud fetch failed', error, stackTrace);
        cloud = null;
        success = false;
      }

      // If the fetch failed we must not push: it could overwrite good cloud
      // data with a partial local view (or fail again). Bail out safely.
      if (cloud == null) {
        cloudSyncError.value = 'Could not sync with the cloud.';
        return false;
      }

      final cloudVehicleStamps = {
        for (final v in cloud.vehicles) v.id: v.syncStamp,
      };
      final cloudEntryStamps = {
        for (final e in cloud.entries) e.id: e.syncStamp,
      };

      if (cloud.hasRemoteData) {
        _applyCloudData(cloud);
      }

      final legacyDemoIds = _legacyDemoVehicleIds();
      final purged = _purgeLegacyDemoDataLocal();
      await _persistAllLocally();

      if (purged && legacyDemoIds.isNotEmpty) {
        await _purgeLegacyDemoDataCloud(legacyDemoIds);
      }

      // Push only when the cloud is missing a record or has an older version of
      // one, instead of re-uploading the entire dataset on every sync.
      bool vehicleNeedsPush(VehicleModel v) {
        final remote = cloudVehicleStamps[v.id];
        return remote == null || v.syncStamp.isAfter(remote);
      }

      bool entryNeedsPush(FuelEntryModel e) {
        final remote = cloudEntryStamps[e.id];
        return remote == null || e.syncStamp.isAfter(remote);
      }

      final hasLocalChanges =
          vehicles.any(vehicleNeedsPush) || entries.any(entryNeedsPush);
      final shouldPush = !cloud.hasRemoteData || purged || hasLocalChanges;
      if (shouldPush) {
        final pushed = await pushToCloud();
        success = success && pushed;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Cloud sync failed', error, stackTrace);
      cloudSyncError.value = 'Could not sync with the cloud.';
      success = false;
    } finally {
      isSyncing.value = false;
    }

    return success;
  }

  /// Uploads the current local state to Firestore.
  Future<bool> pushToCloud() async {
    final uid = _uid;
    if (uid == null) return false;

    cloudSyncError.value = '';
    final ok = await _runCloud(
      () => _firestore.pushAllData(
        uid: uid,
        displayName: userName.value,
        email: userEmail.value,
        onboardingComplete: onboardingComplete.value,
        settings: _settingsToCloud(),
        vehicles: vehicles.toList(),
        entries: entries.toList(),
      ),
      'Cloud full sync failed',
    );

    if (!ok) {
      cloudSyncError.value = 'Could not save to the cloud.';
    }
    return ok;
  }

  void _applyCloudData(UserCloudData cloud) {
    final profile = cloud.profile;
    if (profile != null) {
      if (profile.displayName.isNotEmpty) userName.value = profile.displayName;
      if (profile.email.isNotEmpty) userEmail.value = profile.email;
      onboardingComplete.value = profile.onboardingComplete;
      _applySettingsFromCloud(profile.settings);
    }

    // Merge by id (last-write-wins) instead of overwriting. This preserves
    // records created locally while offline that have not reached the cloud yet.
    final mergedVehicles = {for (final v in vehicles) v.id: v};
    for (final remote in cloud.vehicles) {
      final local = mergedVehicles[remote.id];
      mergedVehicles[remote.id] =
          (local == null || !local.syncStamp.isAfter(remote.syncStamp))
          ? remote
          : local;
    }

    final mergedEntries = {for (final e in entries) e.id: e};
    for (final remote in cloud.entries) {
      final local = mergedEntries[remote.id];
      mergedEntries[remote.id] =
          (local == null || !local.syncStamp.isAfter(remote.syncStamp))
          ? remote
          : local;
    }

    vehicles.assignAll(mergedVehicles.values);
    entries
      ..assignAll(mergedEntries.values)
      ..sort((a, b) => b.date.compareTo(a.date));

    final selected = profile?.settings['selectedVehicleId'] as String?;
    if (selected != null &&
        selected.isNotEmpty &&
        vehicles.any((v) => v.id == selected)) {
      selectedVehicleId.value = selected;
    }
    if (selectedVehicleId.value.isEmpty ||
        !vehicles.any((v) => v.id == selectedVehicleId.value)) {
      selectedVehicleId.value = vehicles.isNotEmpty ? vehicles.first.id : '';
    }
  }

  void _applySettingsFromCloud(Map<String, dynamic> settings) {
    distanceUnit.value =
        settings['distanceUnit'] as String? ?? distanceUnit.value;
    volumeUnit.value = settings['volumeUnit'] as String? ?? volumeUnit.value;
    currencySymbol.value =
        settings['currencySymbol'] as String? ?? currencySymbol.value;
    themeMode.value = _themeFromString(settings['themeMode'] as String?);
    notificationsEnabled.value =
        settings['notificationsEnabled'] as bool? ?? notificationsEnabled.value;
    defaultFuelPrice.value =
        (settings['defaultFuelPrice'] as num?)?.toDouble() ??
        defaultFuelPrice.value;
    defaultElectricityPrice.value =
        (settings['defaultElectricityPrice'] as num?)?.toDouble() ??
        defaultElectricityPrice.value;
  }

  Map<String, dynamic> _settingsToCloud() => {
    'distanceUnit': distanceUnit.value,
    'volumeUnit': volumeUnit.value,
    'currencySymbol': currencySymbol.value,
    'themeMode': _themeToString(themeMode.value),
    'notificationsEnabled': notificationsEnabled.value,
    'defaultFuelPrice': defaultFuelPrice.value,
    'defaultElectricityPrice': defaultElectricityPrice.value,
    'selectedVehicleId': selectedVehicleId.value,
  };

  Future<bool> _syncProfileToCloud() async {
    final uid = _uid;
    if (uid == null) return false;

    return _runCloud(
      () => _firestore.saveUserProfile(
        uid: uid,
        displayName: userName.value,
        email: userEmail.value,
        onboardingComplete: onboardingComplete.value,
        settings: _settingsToCloud(),
      ),
      'Cloud profile sync failed',
    );
  }

  Future<bool> _runCloud(
    Future<void> Function() action,
    String errorLabel,
  ) async {
    if (!_useCloud) return false;
    try {
      await action();
      return true;
    } catch (error, stackTrace) {
      AppLogger.error(errorLabel, error, stackTrace);
      cloudSyncError.value = 'Cloud save failed. Check your connection.';
      return false;
    }
  }

  void _clearUserDataInMemory() {
    vehicles.clear();
    entries.clear();
    selectedVehicleId.value = '';
  }

  List<String> _legacyDemoVehicleIds() => vehicles
      .where((vehicle) => vehicle.id.startsWith('demo-'))
      .map((vehicle) => vehicle.id)
      .toList();

  /// Removes bundled demo vehicles/entries from local storage only.
  bool _purgeLegacyDemoDataLocal() {
    final demoVehicleIds = _legacyDemoVehicleIds();
    if (demoVehicleIds.isEmpty) return false;

    vehicles.removeWhere((vehicle) => vehicle.id.startsWith('demo-'));
    entries.removeWhere((entry) => demoVehicleIds.contains(entry.vehicleId));

    if (demoVehicleIds.contains(selectedVehicleId.value)) {
      selectedVehicleId.value = vehicles.isNotEmpty ? vehicles.first.id : '';
    }

    return true;
  }

  Future<void> _purgeLegacyDemoDataCloud(List<String> demoVehicleIds) async {
    if (!_useCloud) return;

    for (final vehicleId in demoVehicleIds) {
      try {
        await _firestore.deleteVehicle(_uid!, vehicleId);
      } catch (error, stackTrace) {
        AppLogger.error(
          'Failed to delete legacy demo vehicle from cloud',
          error,
          stackTrace,
        );
      }
    }
  }

  Future<void> _persistAllLocally() async {
    await _persistSession();
    await _persistSettings();
    await _persistVehicles();
    await _persistEntries();
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
    await _syncProfileToCloud();
  }

  /// Updates local session from a signed-in Firebase user.
  Future<void> syncAuthUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    final previousUid = userId.value;
    final userChanged = previousUid.isNotEmpty && previousUid != uid;

    if (userChanged) {
      _clearUserDataInMemory();
    }

    loggedIn.value = true;
    userId.value = uid;
    if (name.isNotEmpty) userName.value = name;
    if (email.isNotEmpty) userEmail.value = email;
    await _persistSession();

    if (userChanged) {
      await _persistVehicles();
      await _persistEntries();
      await _persistSettings();
    }
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
    await _syncProfileToCloud();
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
    final oldDistanceUnit = distanceUnit.value;
    final oldVolumeUnit = volumeUnit.value;

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

    final convertedData = await _convertStoredUnits(
      oldDistanceUnit: oldDistanceUnit,
      newDistanceUnit: distanceUnit.value,
      oldVolumeUnit: oldVolumeUnit,
      newVolumeUnit: volumeUnit.value,
    );

    await _persistSettings();

    if (convertedData) {
      // Stored records changed, so re-upload them too (not just the profile).
      if (_useCloud) await pushToCloud();
    } else {
      await _syncProfileToCloud();
    }
  }

  /// Rescales stored distances, odometers and volumes when the user switches
  /// units so historical records stay numerically consistent with the new unit
  /// (e.g. Miles -> Kilometers). Returns true if any record was changed.
  Future<bool> _convertStoredUnits({
    required String oldDistanceUnit,
    required String newDistanceUnit,
    required String oldVolumeUnit,
    required String newVolumeUnit,
  }) async {
    final distanceFactor = _distanceFactor(oldDistanceUnit, newDistanceUnit);
    final volumeFactor = _volumeFactor(oldVolumeUnit, newVolumeUnit);
    final distanceChanged = distanceFactor != 1;
    final volumeChanged = volumeFactor != 1;
    if (!distanceChanged && !volumeChanged) return false;

    final now = DateTime.now();

    if (distanceChanged) {
      for (var i = 0; i < vehicles.length; i++) {
        vehicles[i] = vehicles[i].copyWith(
          odometer: vehicles[i].odometer * distanceFactor,
          updatedAt: now,
        );
      }
      vehicles.refresh();
    }

    if (distanceChanged || volumeChanged) {
      for (var i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(
          distance: distanceChanged
              ? entries[i].distance * distanceFactor
              : null,
          odometer: distanceChanged
              ? entries[i].odometer * distanceFactor
              : null,
          liters: volumeChanged ? entries[i].liters * volumeFactor : null,
          updatedAt: now,
        );
      }
      entries.refresh();
    }

    if (volumeChanged && defaultFuelPrice.value > 0) {
      // Price is stored per volume unit; rescale so auto-filled costs match.
      defaultFuelPrice.value = defaultFuelPrice.value / volumeFactor;
    }

    await _persistVehicles();
    await _persistEntries();
    return true;
  }

  /// Multiplier to convert a distance value from [from] unit into [to] unit.
  double _distanceFactor(String from, String to) {
    final fromKm = from.toLowerCase().startsWith('k');
    final toKm = to.toLowerCase().startsWith('k');
    if (fromKm == toKm) return 1;
    return fromKm
        ? AppConstants.milesPerKilometer // km -> miles
        : AppConstants.kilometersPerMile; // miles -> km
  }

  /// Multiplier to convert a volume value from [from] unit into [to] unit.
  double _volumeFactor(String from, String to) {
    final fromGallons = from.toLowerCase().startsWith('g');
    final toGallons = to.toLowerCase().startsWith('g');
    if (fromGallons == toGallons) return 1;
    return fromGallons
        ? AppConstants.usGallonInLitres // gallons -> litres
        : 1 / AppConstants.usGallonInLitres; // litres -> gallons
  }

  Future<void> toggleDarkMode(bool enabled) =>
      updateSettings(newThemeMode: enabled ? ThemeMode.dark : ThemeMode.light);

  Future<void> selectVehicle(String vehicleId) async {
    selectedVehicleId.value = vehicleId;
    await _persistSettings();
    await _syncProfileToCloud();
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
      updatedAt: DateTime.now(),
    );
    vehicles.add(vehicle);
    await _persistVehicles();
    selectedVehicleId.value = vehicle.id;
    await _persistSettings();
    if (_useCloud) {
      await _runCloud(
        () => _firestore.saveVehicle(_uid!, vehicle),
        'Cloud vehicle save failed',
      );
      await _syncProfileToCloud();
    }
    return vehicle;
  }

  Future<void> updateVehicle(VehicleModel updated) async {
    final index = vehicles.indexWhere((v) => v.id == updated.id);
    if (index == -1) return;
    updated = updated.copyWith(updatedAt: DateTime.now());
    vehicles[index] = updated;
    vehicles.refresh();
    await _persistVehicles();
    if (_useCloud) {
      await _runCloud(
        () => _firestore.saveVehicle(_uid!, updated),
        'Cloud vehicle save failed',
      );
    }
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
    if (_useCloud) {
      await _runCloud(
        () => _firestore.deleteVehicle(_uid!, vehicleId),
        'Cloud vehicle delete failed',
      );
    }
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
      updatedAt: DateTime.now(),
    );
    entries
      ..add(entry)
      ..sort((a, b) => b.date.compareTo(a.date));
    entries.refresh();
    await _persistEntries();
    await _syncVehicleOdometer(vehicleId);
    if (_useCloud) {
      await _runCloud(
        () => _firestore.saveEntry(_uid!, entry),
        'Cloud entry save failed',
      );
    }
  }

  Future<void> updateEntry(FuelEntryModel updated) async {
    final index = entries.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    updated = updated.copyWith(updatedAt: DateTime.now());
    entries[index] = updated;
    entries.sort((a, b) => b.date.compareTo(a.date));
    entries.refresh();
    await _persistEntries();
    await _syncVehicleOdometer(updated.vehicleId);
    if (_useCloud) {
      await _runCloud(
        () => _firestore.saveEntry(_uid!, updated),
        'Cloud entry save failed',
      );
    }
  }

  Future<void> deleteEntry(String entryId) async {
    final entry = entries.firstWhereOrNull((e) => e.id == entryId);
    entries.removeWhere((e) => e.id == entryId);
    await _persistEntries();
    if (entry != null) await _syncVehicleOdometer(entry.vehicleId);
    if (_useCloud) {
      await _runCloud(
        () => _firestore.deleteEntry(_uid!, entryId),
        'Cloud entry delete failed',
      );
    }
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
    vehicles[index] = vehicles[index].copyWith(
      odometer: latestOdometer,
      updatedAt: DateTime.now(),
    );
    vehicles.refresh();
    await _persistVehicles();
    if (_useCloud) {
      await _runCloud(
        () => _firestore.saveVehicle(_uid!, vehicles[index]),
        'Cloud vehicle save failed',
      );
    }
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
    if (_useCloud) await pushToCloud();
    AppLogger.info('Imported $imported new entries.');
    return imported;
  }

  // ---------------------------------------------------------------------------
  // Session lifecycle
  // ---------------------------------------------------------------------------
  Future<void> clearAllData() async {
    final uid = _uid;

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

    if (uid != null) {
      try {
        await _firestore.deleteAllUserData(uid);
      } catch (error, stackTrace) {
        AppLogger.error('Cloud data reset failed', error, stackTrace);
      }
    }
  }

  Future<void> logout() async {
    await clearAuthSession();
    _clearUserDataInMemory();
    await _persistVehicles();
    await _persistEntries();
    await _persistSettings();
  }
}
