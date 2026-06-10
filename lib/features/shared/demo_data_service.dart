import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

/// Bundled demo dataset so every screen is populated on first launch.
///
/// Values are hand-tuned so aggregate efficiency maths match the reference
/// design (e.g. Golf real MPG ≈ 52.4 vs claimed 58.0 → −9.7%).
class DemoDataPayload {
  const DemoDataPayload({
    required this.userName,
    required this.userEmail,
    required this.vehicles,
    required this.entries,
    required this.selectedVehicleId,
    required this.defaultFuelPrice,
    required this.defaultElectricityPrice,
  });

  final String userName;
  final String userEmail;
  final List<VehicleModel> vehicles;
  final List<FuelEntryModel> entries;
  final String selectedVehicleId;
  final double defaultFuelPrice;
  final double defaultElectricityPrice;
}

abstract final class DemoDataService {
  static const fuelPricePerLitre = 1.45;
  static const electricityPricePerKwh = 0.28;

  static DemoDataPayload create() {
    final now = DateTime.now();
    final vehicles = _vehicles();
    final entries = _entries(now);
    return DemoDataPayload(
      userName: 'Alex',
      userEmail: 'alex.driver@example.com',
      vehicles: vehicles,
      entries: entries,
      selectedVehicleId: 'demo-golf',
      defaultFuelPrice: fuelPricePerLitre,
      defaultElectricityPrice: electricityPricePerKwh,
    );
  }

  static List<VehicleModel> _vehicles() {
    return const [
      VehicleModel(
        id: 'demo-golf',
        name: 'Daily Driver',
        energyMode: EnergyMode.fuel,
        vehicleType: 'Car',
        makeModel: 'VW Golf 1.5 TSI',
        year: 2022,
        manufacturerMpgClaim: 58.0,
        odometer: 28450,
      ),
      VehicleModel(
        id: 'demo-tesla',
        name: 'Commuter EV',
        energyMode: EnergyMode.charge,
        vehicleType: 'Car',
        makeModel: 'Tesla Model 3 LR',
        year: 2023,
        manufacturerMiPerKwhClaim: 4.2,
        batteryKwhCapacity: 75,
        odometer: 15800,
      ),
      VehicleModel(
        id: 'demo-bmw',
        name: 'Weekend Hybrid',
        energyMode: EnergyMode.hybrid,
        vehicleType: 'Car',
        makeModel: 'BMW 330e',
        year: 2021,
        manufacturerMpgClaim: 62.0,
        manufacturerMiPerKwhClaim: 3.2,
        batteryKwhCapacity: 12,
        odometer: 32100,
      ),
    ];
  }

  /// Fuel entries tuned for ~52.4 MPG aggregate (3650 miles / 316.3 L).
  static List<FuelEntryModel> _golfEntries(DateTime now) {
    const vehicleId = 'demo-golf';
    const fuelGrade = 'Shell V-Power';
    final entries = <FuelEntryModel>[
      _fuel(
        id: 'golf-1',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 112)),
        odometer: 25120,
        distance: 320,
        litres: 27.7,
        fuelGrade: fuelGrade,
      ),
      _fuel(
        id: 'golf-2',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 95)),
        odometer: 25480,
        distance: 360,
        litres: 31.2,
        fuelGrade: fuelGrade,
      ),
      _fuel(
        id: 'golf-3',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 78)),
        odometer: 25840,
        distance: 360,
        litres: 31.2,
      ),
      _fuel(
        id: 'golf-4',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 58)),
        odometer: 26200,
        distance: 360,
        litres: 31.2,
      ),
      _fuel(
        id: 'golf-5',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 38)),
        odometer: 26560,
        distance: 360,
        litres: 31.2,
      ),
      _fuel(
        id: 'golf-6',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 22)),
        odometer: 26930,
        distance: 370,
        litres: 32.1,
        fuelGrade: 'BP Ultimate',
      ),
      _fuel(
        id: 'golf-7',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 12)),
        odometer: 27680,
        distance: 750,
        litres: 65.0,
        note: 'M6 motorway run',
      ),
      _fuel(
        id: 'golf-8',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 3)),
        odometer: 28450,
        distance: 770,
        litres: 66.7,
        fuelGrade: fuelGrade,
        fullTank: true,
      ),
    ];
    return entries;
  }

  /// Charge entries tuned for ~3.75 mi/kWh aggregate (3800 miles / 1013 kWh).
  static List<FuelEntryModel> _teslaEntries(DateTime now) {
    const vehicleId = 'demo-tesla';
    return [
      _charge(
        id: 'tesla-1',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 105)),
        odometer: 12200,
        distance: 200,
        kwh: 53.3,
      ),
      _charge(
        id: 'tesla-2',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 88)),
        odometer: 12750,
        distance: 550,
        kwh: 146.7,
        note: 'Home charge',
      ),
      _charge(
        id: 'tesla-3',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 70)),
        odometer: 13300,
        distance: 550,
        kwh: 146.7,
      ),
      _charge(
        id: 'tesla-4',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 52)),
        odometer: 13850,
        distance: 550,
        kwh: 146.7,
      ),
      _charge(
        id: 'tesla-5',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 35)),
        odometer: 14400,
        distance: 550,
        kwh: 146.7,
        note: 'Supercharger',
      ),
      _charge(
        id: 'tesla-6',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 18)),
        odometer: 14950,
        distance: 550,
        kwh: 146.7,
      ),
      _charge(
        id: 'tesla-7',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 8)),
        odometer: 15400,
        distance: 450,
        kwh: 120.0,
      ),
      _charge(
        id: 'tesla-8',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 2)),
        odometer: 15800,
        distance: 400,
        kwh: 106.7,
      ),
    ];
  }

  /// Hybrid entries with both fuel and electric components.
  static List<FuelEntryModel> _bmwEntries(DateTime now) {
    const vehicleId = 'demo-bmw';
    return [
      _hybrid(
        id: 'bmw-1',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 100)),
        odometer: 29800,
        distance: 280,
        litres: 18.5,
        kwh: 8.2,
      ),
      _hybrid(
        id: 'bmw-2',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 82)),
        odometer: 30180,
        distance: 380,
        litres: 22.0,
        kwh: 10.5,
      ),
      _hybrid(
        id: 'bmw-3',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 65)),
        odometer: 30560,
        distance: 380,
        litres: 21.5,
        kwh: 11.0,
        note: 'Mixed commute',
      ),
      _hybrid(
        id: 'bmw-4',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 48)),
        odometer: 30940,
        distance: 380,
        litres: 22.5,
        kwh: 9.8,
      ),
      _hybrid(
        id: 'bmw-5',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 30)),
        odometer: 31320,
        distance: 380,
        litres: 21.0,
        kwh: 12.0,
      ),
      _hybrid(
        id: 'bmw-6',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 15)),
        odometer: 31700,
        distance: 380,
        litres: 20.5,
        kwh: 11.5,
      ),
      _hybrid(
        id: 'bmw-7',
        vehicleId: vehicleId,
        date: now.subtract(const Duration(days: 5)),
        odometer: 32100,
        distance: 400,
        litres: 21.8,
        kwh: 10.0,
        fuelGrade: 'Shell V-Power',
      ),
    ];
  }

  static List<FuelEntryModel> _entries(DateTime now) {
    return [..._golfEntries(now), ..._teslaEntries(now), ..._bmwEntries(now)]
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static FuelEntryModel _fuel({
    required String id,
    required String vehicleId,
    required DateTime date,
    required double odometer,
    required double distance,
    required double litres,
    String? fuelGrade,
    bool fullTank = true,
    String? note,
  }) {
    return FuelEntryModel(
      id: id,
      vehicleId: vehicleId,
      date: date,
      mode: EnergyMode.fuel,
      distance: distance,
      liters: litres,
      fuelCost: litres * fuelPricePerLitre,
      odometer: odometer,
      fuelGrade: fuelGrade,
      fullTank: fullTank,
      note: note,
    );
  }

  static FuelEntryModel _charge({
    required String id,
    required String vehicleId,
    required DateTime date,
    required double odometer,
    required double distance,
    required double kwh,
    String? note,
  }) {
    return FuelEntryModel(
      id: id,
      vehicleId: vehicleId,
      date: date,
      mode: EnergyMode.charge,
      distance: distance,
      kwh: kwh,
      electricityCost: kwh * electricityPricePerKwh,
      odometer: odometer,
      note: note,
    );
  }

  static FuelEntryModel _hybrid({
    required String id,
    required String vehicleId,
    required DateTime date,
    required double odometer,
    required double distance,
    required double litres,
    required double kwh,
    String? fuelGrade,
    String? note,
  }) {
    return FuelEntryModel(
      id: id,
      vehicleId: vehicleId,
      date: date,
      mode: EnergyMode.hybrid,
      distance: distance,
      liters: litres,
      kwh: kwh,
      fuelCost: litres * fuelPricePerLitre,
      electricityCost: kwh * electricityPricePerKwh,
      odometer: odometer,
      fuelGrade: fuelGrade,
      fullTank: true,
      note: note,
    );
  }
}
