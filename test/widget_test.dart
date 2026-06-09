import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:fuel_efficiency_app/core/constants/app_constants.dart';
import 'package:fuel_efficiency_app/main.dart';

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  setUp(() async {
    await GetStorage.init(AppConstants.storageBoxName);
    await GetStorage(AppConstants.storageBoxName).erase();
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FuelEfficiencyApp());
    await tester.pump();

    expect(find.text('Fuel Efficiency Calculator'), findsOneWidget);
    expect(find.byIcon(Icons.speed_rounded), findsOneWidget);

    await tester.pump(AppConstants.splashDuration);
    await tester.pumpAndSettle();
  });
}
