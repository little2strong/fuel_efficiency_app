import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/core/providers/local_storage_provider.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LocalStorageProvider>(
      LocalStorageProvider(GetStorage(AppConstants.storageBoxName)),
      permanent: true,
    );
  }
}
