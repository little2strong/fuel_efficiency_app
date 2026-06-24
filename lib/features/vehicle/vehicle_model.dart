import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.name,
    required this.energyMode,
    required this.vehicleType,
    required this.makeModel,
    required this.year,
    this.manufacturerMpgClaim,
    this.manufacturerMiPerKwhClaim,
    this.batteryKwhCapacity,
    this.odometer = 0,
    this.updatedAt,
  });

  static const storageKey = 'vehicles';

  final String id;
  final String name;
  final EnergyMode energyMode;
  final String vehicleType;
  final String makeModel;
  final int year;
  final double? manufacturerMpgClaim;
  final double? manufacturerMiPerKwhClaim;
  final double? batteryKwhCapacity;
  final double odometer;

  /// Last time this record was created/modified. Used for cloud merge.
  final DateTime? updatedAt;

  /// Stamp used to compare two versions of the same record during sync.
  DateTime get syncStamp => updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  VehicleModel copyWith({
    String? id,
    String? name,
    EnergyMode? energyMode,
    String? vehicleType,
    String? makeModel,
    int? year,
    double? manufacturerMpgClaim,
    bool clearManufacturerClaim = false,
    double? manufacturerMiPerKwhClaim,
    bool clearManufacturerMiPerKwhClaim = false,
    double? batteryKwhCapacity,
    bool clearBatteryCapacity = false,
    double? odometer,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      energyMode: energyMode ?? this.energyMode,
      vehicleType: vehicleType ?? this.vehicleType,
      makeModel: makeModel ?? this.makeModel,
      year: year ?? this.year,
      manufacturerMpgClaim: clearManufacturerClaim
          ? null
          : manufacturerMpgClaim ?? this.manufacturerMpgClaim,
      manufacturerMiPerKwhClaim: clearManufacturerMiPerKwhClaim
          ? null
          : manufacturerMiPerKwhClaim ?? this.manufacturerMiPerKwhClaim,
      batteryKwhCapacity: clearBatteryCapacity
          ? null
          : batteryKwhCapacity ?? this.batteryKwhCapacity,
      odometer: odometer ?? this.odometer,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'energyMode': energyMode.storageValue,
    'vehicleType': vehicleType,
    'makeModel': makeModel,
    'year': year,
    'manufacturerMpgClaim': manufacturerMpgClaim,
    'manufacturerMiPerKwhClaim': manufacturerMiPerKwhClaim,
    'batteryKwhCapacity': batteryKwhCapacity,
    'odometer': odometer,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      energyMode: EnergyMode.fromStorage(
        json['energyMode'] as String? ?? 'fuel',
      ),
      vehicleType: json['vehicleType'] as String? ?? 'Car',
      makeModel: json['makeModel'] as String? ?? (json['name'] as String),
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      manufacturerMpgClaim: (json['manufacturerMpgClaim'] as num?)?.toDouble(),
      manufacturerMiPerKwhClaim: (json['manufacturerMiPerKwhClaim'] as num?)
          ?.toDouble(),
      batteryKwhCapacity: (json['batteryKwhCapacity'] as num?)?.toDouble(),
      odometer: (json['odometer'] as num?)?.toDouble() ?? 0,
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
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
