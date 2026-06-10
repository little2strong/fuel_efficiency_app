import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

/// Handles creating and editing a fuel / charge / hybrid entry.
///
/// The active [EnergyMode] is driven by the selected vehicle, so the form
/// renders the correct sections (fuel only, charge only, or both for hybrid).
class EntryController extends GetxController {
  EntryController(this._data);

  final AppDataController _data;

  final formKey = GlobalKey<FormState>();

  final odometerController = TextEditingController();
  final litersController = TextEditingController();
  final fuelCostController = TextEditingController();
  final kwhController = TextEditingController();
  final electricityCostController = TextEditingController();
  final fuelGradeController = TextEditingController();
  final noteController = TextEditingController();

  final RxString selectedVehicleId = ''.obs;
  final Rx<DateTime> date = DateTime.now().obs;
  final RxBool fullTank = true.obs;
  final RxBool isSaving = false.obs;

  bool _autoFuelCost = true;
  bool _autoElectricCost = true;

  // Drives the live preview without a full form validation cycle.
  final RxInt _recompute = 0.obs;

  FuelEntryModel? _editing;

  bool get isEditing => _editing != null;

  RxString get currencySymbol => _data.currencySymbol;
  RxString get distanceUnit => _data.distanceUnit;
  RxString get volumeUnit => _data.volumeUnit;
  List<VehicleModel> get vehicles => _data.vehicles.toList();

  VehicleModel? get vehicle =>
      _data.vehicles.firstWhereOrNull((v) => v.id == selectedVehicleId.value);

  EnergyMode get mode => vehicle?.energyMode ?? EnergyMode.fuel;

  bool get usesUsGallons => volumeUnit.value.toLowerCase().startsWith('g');

  String get volumeLabel => usesUsGallons ? 'Gallons Added' : 'Litres Added';

  String get volumeSuffix => usesUsGallons ? 'gal' : 'L';

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is FuelEntryModel) {
      _editing = arg;
      _prefillFromEntry(arg);
    } else {
      final vehicle =
          _data.selectedVehicle ??
          (_data.vehicles.isNotEmpty ? _data.vehicles.first : null);
      selectedVehicleId.value = vehicle?.id ?? '';
    }

    for (final c in [
      odometerController,
      litersController,
      fuelCostController,
      kwhController,
      electricityCostController,
    ]) {
      c.addListener(_onFieldChanged);
    }
    fuelCostController.addListener(_onFuelCostEdited);
    electricityCostController.addListener(_onElectricityCostEdited);
  }

  void _onFuelCostEdited() => _autoFuelCost = false;
  void _onElectricityCostEdited() => _autoElectricCost = false;

  void _onFieldChanged() {
    _applyDefaultCosts();
    _recompute.value++;
  }

  void _applyDefaultCosts() {
    final litres = double.tryParse(litersController.text.trim()) ?? 0;
    if (litres > 0 && _autoFuelCost && _data.defaultFuelPrice.value > 0) {
      final cost = litres * _data.defaultFuelPrice.value;
      fuelCostController.removeListener(_onFuelCostEdited);
      fuelCostController.text = _trim(cost);
      fuelCostController.addListener(_onFuelCostEdited);
    }
    final kwh = double.tryParse(kwhController.text.trim()) ?? 0;
    if (kwh > 0 &&
        _autoElectricCost &&
        _data.defaultElectricityPrice.value > 0) {
      final cost = kwh * _data.defaultElectricityPrice.value;
      electricityCostController.removeListener(_onElectricityCostEdited);
      electricityCostController.text = _trim(cost);
      electricityCostController.addListener(_onElectricityCostEdited);
    }
  }

  void _prefillFromEntry(FuelEntryModel entry) {
    selectedVehicleId.value = entry.vehicleId;
    date.value = entry.date;
    fullTank.value = entry.fullTank;
    odometerController.text = entry.odometer.toStringAsFixed(0);
    if (entry.liters > 0) litersController.text = _trim(entry.liters);
    if (entry.fuelCost > 0) {
      fuelCostController.text = _trim(entry.fuelCost);
      _autoFuelCost = false;
    }
    if (entry.kwh > 0) kwhController.text = _trim(entry.kwh);
    if (entry.electricityCost > 0) {
      electricityCostController.text = _trim(entry.electricityCost);
      _autoElectricCost = false;
    }
    fuelGradeController.text = entry.fuelGrade ?? '';
    noteController.text = entry.note ?? '';
  }

  String _trim(double value) {
    final s = value.toStringAsFixed(2);
    return s.endsWith('.00') ? value.toStringAsFixed(0) : s;
  }

  void onVehicleChanged(String id) {
    selectedVehicleId.value = id;
    _recompute.value++;
  }

  /// Odometer reading we measure distance from.
  double get baselineOdometer {
    if (isEditing) return _editing!.startOdometer;
    return vehicle?.odometer ?? 0;
  }

  double get _enteredOdometer =>
      double.tryParse(odometerController.text.trim()) ?? 0;

  double get _liters => double.tryParse(litersController.text.trim()) ?? 0;
  double get _fuelCost => double.tryParse(fuelCostController.text.trim()) ?? 0;
  double get _kwh => double.tryParse(kwhController.text.trim()) ?? 0;
  double get _electricityCost =>
      double.tryParse(electricityCostController.text.trim()) ?? 0;

  /// Live distance derived from odometer delta.
  double get distance {
    _recompute.value; // establish reactive dependency
    final delta = _enteredOdometer - baselineOdometer;
    return delta > 0 ? delta : 0;
  }

  double get previewMpg {
    _recompute.value;
    return _data.efficiency.mpg(
      distance: distance,
      litres: _liters,
      distanceUnit: distanceUnit.value,
      volumeUnit: volumeUnit.value,
    );
  }

  double get previewMilesPerKwh {
    _recompute.value;
    return _data.efficiency.milesPerKwh(
      distance: distance,
      kwh: _kwh,
      distanceUnit: distanceUnit.value,
    );
  }

  double get previewTotalCost {
    _recompute.value;
    return _fuelCost + _electricityCost;
  }

  double get previewCostPerDistance {
    _recompute.value;
    return _data.efficiency.costPerDistance(
      totalCost: previewTotalCost,
      distance: distance,
    );
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      date.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        date.value.hour,
        date.value.minute,
      );
    }
  }

  String? validateOdometer(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Odometer is required';
    final odometer = double.tryParse(text);
    if (odometer == null) return 'Enter a valid number';
    if (odometer <= baselineOdometer) {
      return 'Must be greater than ${baselineOdometer.toStringAsFixed(0)}';
    }
    return null;
  }

  String? validatePositive(String? value, {required bool required}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Required' : null;
    final v = double.tryParse(text);
    if (v == null) return 'Invalid number';
    if (v <= 0) return 'Must be greater than 0';
    return null;
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final v = vehicle;
    if (v == null) {
      Get.snackbar(
        'No vehicle',
        'Please select a vehicle first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isSaving.value = true;

    final note = noteController.text.trim();
    final grade = fuelGradeController.text.trim();

    if (isEditing) {
      await _data.updateEntry(
        _editing!.copyWith(
          vehicleId: v.id,
          date: date.value,
          mode: v.energyMode,
          distance: distance,
          odometer: _enteredOdometer,
          liters: v.energyMode.usesFuel ? _liters : 0,
          fuelCost: v.energyMode.usesFuel ? _fuelCost : 0,
          kwh: v.energyMode.usesCharge ? _kwh : 0,
          electricityCost: v.energyMode.usesCharge ? _electricityCost : 0,
          fullTank: fullTank.value,
          fuelGrade: grade.isEmpty ? null : grade,
          clearFuelGrade: grade.isEmpty,
          note: note.isEmpty ? null : note,
          clearNote: note.isEmpty,
        ),
      );
    } else {
      await _data.addEntry(
        vehicleId: v.id,
        mode: v.energyMode,
        distance: distance,
        odometer: _enteredOdometer,
        liters: v.energyMode.usesFuel ? _liters : 0,
        fuelCost: v.energyMode.usesFuel ? _fuelCost : 0,
        kwh: v.energyMode.usesCharge ? _kwh : 0,
        electricityCost: v.energyMode.usesCharge ? _electricityCost : 0,
        date: date.value,
        fullTank: fullTank.value,
        fuelGrade: grade.isEmpty ? null : grade,
        note: note.isEmpty ? null : note,
      );
    }

    isSaving.value = false;
    Get.back();
    Get.snackbar(
      isEditing ? 'Entry updated' : 'Entry saved',
      'Your ${v.energyMode.title.toLowerCase()} entry has been recorded.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    odometerController.dispose();
    litersController.dispose();
    fuelCostController.dispose();
    kwhController.dispose();
    electricityCostController.dispose();
    fuelGradeController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
