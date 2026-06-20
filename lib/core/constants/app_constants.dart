abstract final class AppConstants {
  static const String appName = 'Fuel Efficiency Calculator';
  static const String appTagline =
      'Track real efficiency. Save more. Drive smarter.';
  static const String appVersion = '1.0.0';
  static const String storageBoxName = 'fuel_efficiency_storage';

  static const Duration splashDuration = Duration(milliseconds: 2200);

  // Session keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLoggedIn = 'logged_in';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserId = 'user_id';

  // Settings keys
  static const String keySelectedVehicleId = 'selected_vehicle_id';
  static const String keyDistanceUnit = 'distance_unit';
  static const String keyVolumeUnit = 'volume_unit';
  static const String keyCurrencySymbol = 'currency_symbol';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyFuelPrice = 'default_fuel_price';
  static const String keyElectricityPrice = 'default_electricity_price';
  static const String keyDemoSeeded = 'demo_seeded';

  // Defaults
  static const String defaultDistanceUnit = 'Miles';
  static const String defaultVolumeUnit = 'Litres';
  static const String defaultCurrencySymbol = '£';
  static const double defaultFuelPricePerLitre = 1.45;
  static const double defaultElectricityPricePerKwh = 0.28;

  // Unit conversion
  static const double imperialGallonInLitres = 4.54609;
  static const double usGallonInLitres = 3.785411784;
  static const double milesPerKilometer = 0.621371;
  static const double kilometersPerMile = 1.609344;
}
