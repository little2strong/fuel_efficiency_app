import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class FuelEntryModel {
  const FuelEntryModel({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.mode,
    required this.distance,
    this.liters = 0,
    this.kwh = 0,
    required this.fuelCost,
    this.electricityCost = 0,
    required this.odometer,
  });

  static const storageKey = 'fuel_entries';

  final String id;
  final String vehicleId;
  final DateTime date;
  final EnergyMode mode;
  final double distance;
  final double liters;
  final double kwh;
  final double fuelCost;
  final double electricityCost;
  final double odometer;

  double get totalCost => fuelCost + electricityCost;

  double get costPerDistance => distance > 0 ? totalCost / distance : 0;

  double get costPerLiter => liters > 0 ? fuelCost / liters : 0;

  double get costPerKwh => kwh > 0 ? electricityCost / kwh : 0;

  FuelEntryModel copyWith({
    String? id,
    String? vehicleId,
    DateTime? date,
    EnergyMode? mode,
    double? distance,
    double? liters,
    double? kwh,
    double? fuelCost,
    double? electricityCost,
    double? odometer,
  }) {
    return FuelEntryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      mode: mode ?? this.mode,
      distance: distance ?? this.distance,
      liters: liters ?? this.liters,
      kwh: kwh ?? this.kwh,
      fuelCost: fuelCost ?? this.fuelCost,
      electricityCost: electricityCost ?? this.electricityCost,
      odometer: odometer ?? this.odometer,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'date': date.toIso8601String(),
        'mode': mode.storageValue,
        'distance': distance,
        'liters': liters,
        'kwh': kwh,
        'fuelCost': fuelCost,
        'electricityCost': electricityCost,
        'odometer': odometer,
      };

  factory FuelEntryModel.fromJson(Map<String, dynamic> json) {
    return FuelEntryModel(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      date: DateTime.parse(json['date'] as String),
      mode: EnergyMode.fromStorage(json['mode'] as String? ?? 'fuel'),
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      liters: (json['liters'] as num?)?.toDouble() ?? 0,
      kwh: (json['kwh'] as num?)?.toDouble() ?? 0,
      fuelCost: (json['fuelCost'] as num?)?.toDouble() ??
          (json['cost'] as num?)?.toDouble() ??
          0,
      electricityCost: (json['electricityCost'] as num?)?.toDouble() ?? 0,
      odometer: (json['odometer'] as num).toDouble(),
    );
  }

  static List<FuelEntryModel> loadAll(LocalStorageProvider storage) {
    final raw = storage.read<List<dynamic>>(storageKey) ?? [];
    return raw
        .map((item) => FuelEntryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> saveAll(
    LocalStorageProvider storage,
    List<FuelEntryModel> entries,
  ) {
    return storage.write(
      storageKey,
      entries.map((entry) => entry.toJson()).toList(),
    );
  }
}
