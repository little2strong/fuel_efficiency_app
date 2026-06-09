import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/features/splash/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed_rounded,
              size: 72,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Track real efficiency. See the real difference.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
