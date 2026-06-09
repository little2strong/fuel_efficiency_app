import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/settings/settings_controller.dart';
import 'package:fuel_efficiency_app/app/routes/app_routes.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App name'),
            subtitle: Text(controller.appName),
          ),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.system_update_alt),
              title: const Text('Version'),
              subtitle: Text(controller.appVersion.value),
            ),
          ),
          const Divider(),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Units'),
              subtitle: Text(controller.distanceUnit.value),
              trailing: DropdownButton<String>(
                value: controller.distanceUnit.value,
                items: const [
                  DropdownMenuItem(value: 'Miles', child: Text('Miles')),
                  DropdownMenuItem(value: 'Kilometers', child: Text('Kilometers')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.setDistanceUnit(value);
                  }
                },
              ),
            ),
          ),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Currency'),
              subtitle: Text(controller.currencySymbol.value),
              trailing: DropdownButton<String>(
                value: controller.currencySymbol.value,
                items: const [
                  DropdownMenuItem(value: '\$', child: Text('\$')),
                  DropdownMenuItem(value: '€', child: Text('€')),
                  DropdownMenuItem(value: '£', child: Text('£')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.setCurrency(value);
                  }
                },
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Data Export'),
            subtitle: const Text('Export your data'),
            onTap: controller.exportData,
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Back up your data'),
            onTap: controller.backupData,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read privacy details'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            subtitle: const Text('Version and credits'),
            onTap: () {},
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.tonal(
              onPressed: () async {
                await controller.logout();
                Get.offAllNamed(AppRoutes.onboarding);
              },
              child: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () async {
                await controller.resetAll();
                Get.offAllNamed(AppRoutes.onboarding);
              },
              child: const Text('Reset App Data'),
            ),
          ),
        ],
      ),
    );
  }
}
