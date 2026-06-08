import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.name,
    required this.fuelType,
    this.odometer = 0,
  });

  static const storageKey = 'vehicles';

  final String id;
  final String name;
  final String fuelType;
  final double odometer;

  VehicleModel copyWith({
    String? id,
    String? name,
    String? fuelType,
    double? odometer,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      fuelType: fuelType ?? this.fuelType,
      odometer: odometer ?? this.odometer,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fuelType': fuelType,
        'odometer': odometer,
      };

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      fuelType: json['fuelType'] as String,
      odometer: (json['odometer'] as num?)?.toDouble() ?? 0,
    );
  }

  static List<VehicleModel> loadAll(LocalStorageProvider storage) {
    final raw = storage.read<List<dynamic>>(storageKey) ?? [];
    return raw
        .map((item) => VehicleModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> saveAll(
    LocalStorageProvider storage,
    List<VehicleModel> vehicles,
  ) {
    return storage.write(
      storageKey,
      vehicles.map((vehicle) => vehicle.toJson()).toList(),
    );
  }
}
