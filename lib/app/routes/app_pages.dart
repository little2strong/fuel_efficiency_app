import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/features/entry/entry_binding.dart';
import 'package:fuel_efficiency_app/features/entry/entry_detail_binding.dart';
import 'package:fuel_efficiency_app/features/entry/entry_detail_view.dart';
import 'package:fuel_efficiency_app/features/entry/entry_form_view.dart';
import 'package:fuel_efficiency_app/features/main/main_binding.dart';
import 'package:fuel_efficiency_app/features/main/main_view.dart';
import 'package:fuel_efficiency_app/features/onboarding/onboarding_binding.dart';
import 'package:fuel_efficiency_app/features/onboarding/onboarding_view.dart';
import 'package:fuel_efficiency_app/features/reality/reality_binding.dart';
import 'package:fuel_efficiency_app/features/reality/reality_view.dart';
import 'package:fuel_efficiency_app/features/settings/settings_binding.dart';
import 'package:fuel_efficiency_app/features/settings/settings_view.dart';
import 'package:fuel_efficiency_app/features/splash/splash_binding.dart';
import 'package:fuel_efficiency_app/features/splash/splash_view.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_binding.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_form_binding.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_form_view.dart';
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
      name: AppRoutes.onboarding,
      page: OnboardingView.new,
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.main,
      page: MainView.new,
      binding: MainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.entryForm,
      page: EntryFormView.new,
      binding: EntryBinding(),
    ),
    GetPage(
      name: AppRoutes.entryDetail,
      page: EntryDetailView.new,
      binding: EntryDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.reality,
      page: RealityView.new,
      binding: RealityBinding(),
    ),
    GetPage(
      name: AppRoutes.vehicleProfile,
      page: VehicleView.new,
      binding: VehicleBinding(),
    ),
    GetPage(
      name: AppRoutes.vehicleForm,
      page: VehicleFormView.new,
      binding: VehicleFormBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: SettingsView.new,
      binding: SettingsBinding(),
    ),
  ];
}
