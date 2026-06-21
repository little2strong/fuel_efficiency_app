import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';
import 'package:fuel_efficiency_app/core/services/auth_service.dart';
import 'package:fuel_efficiency_app/core/services/firestore_service.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';
import 'package:fuel_efficiency_app/features/shared/data_transfer_service.dart';
import 'package:fuel_efficiency_app/features/shared/efficiency_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LocalStorageProvider>(
      LocalStorageProvider(GetStorage(AppConstants.storageBoxName)),
      permanent: true,
    );
    Get.put<EfficiencyService>(const EfficiencyService(), permanent: true);
    Get.put<DataTransferService>(const DataTransferService(), permanent: true);
    Get.put<FirestoreService>(FirestoreService(), permanent: true);
    Get.put<AppDataController>(
      AppDataController(
        Get.find<LocalStorageProvider>(),
        Get.find<FirestoreService>(),
        efficiency: Get.find<EfficiencyService>(),
        transfer: Get.find<DataTransferService>(),
      ),
      permanent: true,
    );
    Get.put<AuthService>(AuthService(), permanent: true);
  }
}
