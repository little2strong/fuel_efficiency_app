import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:fuel_efficiency_app/app/bindings/initial_binding.dart';
import 'package:fuel_efficiency_app/app/routes/app_pages.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(AppConstants.storageBoxName);
  runApp(const FuelEfficiencyApp());
}

class FuelEfficiencyApp extends StatelessWidget {
  const FuelEfficiencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage(AppConstants.storageBoxName);
    final storedTheme = box.read<String>(AppConstants.keyThemeMode);
    final initialThemeMode = switch (storedTheme) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: initialThemeMode,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
