enum EnergyMode {
  fuel,
  charge,
  hybrid;

  String get title {
    switch (this) {
      case EnergyMode.fuel:
        return 'Fuel';
      case EnergyMode.charge:
        return 'Charge';
      case EnergyMode.hybrid:
        return 'Fuel + Charge';
    }
  }

  String get subtitle {
    switch (this) {
      case EnergyMode.fuel:
        return 'Petrol / Diesel';
      case EnergyMode.charge:
        return 'Electric Vehicle';
      case EnergyMode.hybrid:
        return 'Plug-in Hybrid';
    }
  }

  String get storageValue {
    switch (this) {
      case EnergyMode.fuel:
        return 'fuel';
      case EnergyMode.charge:
        return 'charge';
      case EnergyMode.hybrid:
        return 'hybrid';
    }
  }

  static EnergyMode fromStorage(String value) {
    switch (value) {
      case 'charge':
        return EnergyMode.charge;
      case 'hybrid':
        return EnergyMode.hybrid;
      default:
        return EnergyMode.fuel;
    }
  }
}
