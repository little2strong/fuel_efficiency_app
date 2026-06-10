import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/app/routes/app_routes.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/app_card.dart';
import 'package:fuel_efficiency_app/features/main/main_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = Get.find<AppDataController>();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('More', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Obx(
            () => AppCard(
              onTap: () => Get.toNamed(AppRoutes.settings),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.userName.value.isEmpty
                              ? 'Driver'
                              : data.userName.value,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          data.userEmail.value.isEmpty
                              ? 'Tap to manage profile & settings'
                              : data.userEmail.value,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _MenuGroup(
            title: 'Vehicle & Insights',
            items: [
              _MenuItem(
                icon: Icons.directions_car_rounded,
                color: AppColors.primary,
                title: 'Vehicle Profile',
                subtitle: 'Specs, lifetime stats and edit vehicles',
                onTap: () => Get.toNamed(AppRoutes.vehicleProfile),
              ),
              _MenuItem(
                icon: Icons.speed_rounded,
                color: AppColors.hybrid,
                title: 'Reality vs Estimate',
                subtitle: 'Compare claimed vs real efficiency',
                onTap: () => Get.toNamed(AppRoutes.reality),
              ),
              _MenuItem(
                icon: Icons.bar_chart_rounded,
                color: AppColors.charge,
                title: 'Analytics',
                subtitle: 'Trends, best and worst performance',
                onTap: () => Get.find<MainController>().changeTab(2),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MenuGroup(
            title: 'App',
            items: [
              _MenuItem(
                icon: Icons.settings_rounded,
                color: AppColors.textSecondary,
                title: 'Settings',
                subtitle: 'Units, currency, energy prices and data',
                onTap: () => Get.toNamed(AppRoutes.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.title, required this.items});
  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i != items.length - 1)
                  Divider(height: 1, color: theme.dividerColor, indent: 64),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 21),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
    );
  }
}
