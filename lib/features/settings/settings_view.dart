import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/app_card.dart';
import 'package:fuel_efficiency_app/core/widgets/app_logo.dart';
import 'package:fuel_efficiency_app/features/settings/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Obx(
            () => AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.userName.value.isEmpty
                              ? 'Driver'
                              : controller.userName.value,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          controller.userEmail.value.isEmpty
                              ? 'No email set'
                              : controller.userEmail.value,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _editProfile(context),
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Edit profile',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _GroupTitle('Units'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Obx(
                  () => _DropdownTile(
                    icon: Icons.straighten_rounded,
                    title: 'Distance Unit',
                    value: controller.distanceUnit.value,
                    options: const ['Miles', 'Kilometers'],
                    onChanged: controller.setDistanceUnit,
                  ),
                ),
                _divider(context),
                Obx(
                  () => _DropdownTile(
                    icon: Icons.local_drink_rounded,
                    title: 'Volume Unit',
                    value: controller.volumeUnit.value,
                    options: const ['Litres', 'Gallons'],
                    onChanged: controller.setVolumeUnit,
                  ),
                ),
                _divider(context),
                Obx(
                  () => _DropdownTile(
                    icon: Icons.payments_rounded,
                    title: 'Currency',
                    value: controller.currencySymbol.value,
                    options: const ['£', '\$', '€', '₹'],
                    onChanged: controller.setCurrency,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _GroupTitle('Energy Prices'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Obx(
              () => _Tile(
                icon: Icons.bolt_rounded,
                title: 'Default Energy Prices',
                subtitle:
                    'Fuel ${Formatters.currency(controller.fuelPrice.value, controller.currencySymbol.value)}/${controller.volumeUnitShort} • '
                    'Electricity ${Formatters.currency(controller.electricityPrice.value, controller.currencySymbol.value)}/kWh',
                onTap: () => _editPrices(context),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _GroupTitle('Appearance'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Obx(
                  () => _SwitchTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    value: controller.isDarkMode,
                    onChanged: controller.toggleDarkMode,
                  ),
                ),
                _divider(context),
                Obx(
                  () => _SwitchTile(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.toggleNotifications,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _GroupTitle('Data Management'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Tile(
                  icon: Icons.file_download_rounded,
                  title: 'Export as JSON',
                  subtitle: 'Share a full backup file',
                  onTap: controller.exportJson,
                ),
                _divider(context),
                _Tile(
                  icon: Icons.table_view_rounded,
                  title: 'Export as CSV',
                  subtitle: 'Share entries as a spreadsheet',
                  onTap: controller.exportCsv,
                ),
                _divider(context),
                _Tile(
                  icon: Icons.file_upload_rounded,
                  title: 'Import Data',
                  subtitle: 'Paste a JSON backup to restore',
                  onTap: () => _importData(context),
                ),
                _divider(context),
                _Tile(
                  icon: Icons.backup_rounded,
                  title: 'Backup & Restore',
                  subtitle: 'Save a backup to this device',
                  onTap: controller.backup,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _GroupTitle('About'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Tile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Policy',
                  subtitle: 'Your data stays on your device',
                  onTap: () => _privacyDialog(context),
                ),
                _divider(context),
                _Tile(
                  icon: Icons.info_rounded,
                  title: 'About App',
                  subtitle: 'Version ${controller.appVersion}',
                  onTap: () => _aboutDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.negative.withValues(alpha: 0.12),
                foregroundColor: AppColors.negative,
              ),
              onPressed: () async {
                await controller.logout();
                Get.offAllNamed(AppRoutes.onboarding);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => _confirmReset(context),
              child: const Text(
                'Reset App Data',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Divider(height: 1, indent: 60, color: Theme.of(context).dividerColor);

  void _editProfile(BuildContext context) {
    final nameCtrl = TextEditingController(text: controller.userName.value);
    final emailCtrl = TextEditingController(text: controller.userEmail.value);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              controller.updateProfile(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      emailCtrl.dispose();
    });
  }

  void _editPrices(BuildContext context) {
    final fuelCtrl = TextEditingController(
      text: controller.fuelPrice.value == 0
          ? ''
          : controller.fuelPrice.value.toString(),
    );
    final elecCtrl = TextEditingController(
      text: controller.electricityPrice.value == 0
          ? ''
          : controller.electricityPrice.value.toString(),
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Energy Prices'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fuelCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText:
                    'Fuel price / ${controller.volumeUnitShort} (${controller.currencySymbol.value})',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: elecCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText:
                    'Electricity price / kWh (${controller.currencySymbol.value})',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              controller.setEnergyPrices(
                fuel: double.tryParse(fuelCtrl.text.trim()) ?? 0,
                electricity: double.tryParse(elecCtrl.text.trim()) ?? 0,
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(() {
      fuelCtrl.dispose();
      elecCtrl.dispose();
    });
  }

  void _importData(BuildContext context) {
    final textCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste a JSON backup below to restore your data.'),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '{ "vehicles": ... }',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final raw = textCtrl.text.trim();
              Navigator.of(dialogContext).pop();
              if (raw.isNotEmpty) controller.importFromText(raw);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    ).whenComplete(textCtrl.dispose);
  }

  void _privacyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Your data is stored locally on your device and securely synced to '
          'your private Firebase account so it is available across your '
          'devices. Only you can access it. Exported files are shared only when '
          'you explicitly choose to share them.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _aboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: controller.appName,
      applicationVersion: 'Version ${controller.appVersion}',
      applicationIcon: const AppLogo(size: 48),
      children: const [Text('Track real efficiency. See the real difference.')],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'This permanently deletes all vehicles, entries and settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.negative),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await controller.resetAll();
              Get.offAllNamed(AppRoutes.onboarding);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile.adaptive(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          borderRadius: BorderRadius.circular(14),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
