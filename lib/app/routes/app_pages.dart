import 'package:get/get.dart';
import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_binding.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_view.dart';
import 'package:fuel_efficiency_app/features/home/home_binding.dart';
import 'package:fuel_efficiency_app/features/home/home_view.dart';
import 'package:fuel_efficiency_app/features/settings/settings_binding.dart';
import 'package:fuel_efficiency_app/features/settings/settings_view.dart';
import 'package:fuel_efficiency_app/features/splash/splash_binding.dart';
import 'package:fuel_efficiency_app/features/splash/splash_view.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_binding.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_view.dart';

abstract final class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: SplashView.new,
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: HomeView.new,
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.fuel,
      page: FuelView.new,
      binding: FuelBinding(),
    ),
    GetPage(
      name: AppRoutes.vehicle,
      page: VehicleView.new,
      binding: VehicleBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: SettingsView.new,
      binding: SettingsBinding(),
    ),
  ];
}
