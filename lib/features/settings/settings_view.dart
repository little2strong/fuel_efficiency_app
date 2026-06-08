import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/settings/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
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
        ],
      ),
    );
  }
}
