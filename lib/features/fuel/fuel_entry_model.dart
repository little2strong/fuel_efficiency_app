import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';

class FuelEntryModel {
  const FuelEntryModel({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.liters,
    required this.cost,
    required this.odometer,
  });

  static const storageKey = 'fuel_entries';

  final String id;
  final String vehicleId;
  final DateTime date;
  final double liters;
  final double cost;
  final double odometer;

  double get costPerLiter => liters > 0 ? cost / liters : 0;

  FuelEntryModel copyWith({
    String? id,
    String? vehicleId,
    DateTime? date,
    double? liters,
    double? cost,
    double? odometer,
  }) {
    return FuelEntryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      liters: liters ?? this.liters,
      cost: cost ?? this.cost,
      odometer: odometer ?? this.odometer,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'date': date.toIso8601String(),
        'liters': liters,
        'cost': cost,
        'odometer': odometer,
      };

  factory FuelEntryModel.fromJson(Map<String, dynamic> json) {
    return FuelEntryModel(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      date: DateTime.parse(json['date'] as String),
      liters: (json['liters'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
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
