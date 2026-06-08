import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';

class SettingsController extends GetxController {
  final RxString appVersion = '1.0.0'.obs;

  String get appName => AppConstants.appName;
}
