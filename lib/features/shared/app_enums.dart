import 'package:flutter/material.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';

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
        return 'Electric';
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

  IconData get icon {
    switch (this) {
      case EnergyMode.fuel:
        return Icons.local_gas_station_rounded;
      case EnergyMode.charge:
        return Icons.bolt_rounded;
      case EnergyMode.hybrid:
        return Icons.eco_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EnergyMode.fuel:
        return AppColors.fuel;
      case EnergyMode.charge:
        return AppColors.charge;
      case EnergyMode.hybrid:
        return AppColors.hybrid;
    }
  }

  Color get surface {
    switch (this) {
      case EnergyMode.fuel:
        return AppColors.fuelSurface;
      case EnergyMode.charge:
        return AppColors.chargeSurface;
      case EnergyMode.hybrid:
        return AppColors.hybridSurface;
    }
  }

  bool get usesFuel => this == EnergyMode.fuel || this == EnergyMode.hybrid;

  bool get usesCharge => this == EnergyMode.charge || this == EnergyMode.hybrid;

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
