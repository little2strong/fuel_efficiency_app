import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/app_card.dart';
import 'package:fuel_efficiency_app/core/widgets/delta_badge.dart';
import 'package:fuel_efficiency_app/core/widgets/empty_state.dart';
import 'package:fuel_efficiency_app/core/widgets/loading_view.dart';
import 'package:fuel_efficiency_app/core/widgets/section_header.dart';
import 'package:fuel_efficiency_app/core/widgets/stat_card.dart';
import 'package:fuel_efficiency_app/core/widgets/trend_line_chart.dart';
import 'package:fuel_efficiency_app/features/home/home_controller.dart';
import 'package:fuel_efficiency_app/features/main/main_controller.dart';
import 'package:fuel_efficiency_app/features/shared/widgets/entry_tile.dart';
import 'package:fuel_efficiency_app/features/shared/widgets/vehicle_selector.dart';

class DashboardTab extends GetView<HomeController> {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Obx(() {
        if (!controller.isHydrated.value) {
          return const LoadingView();
        }
        if (controller.vehicles.isEmpty) {
          return EmptyState(
            icon: Icons.directions_car_filled_rounded,
            title: 'No vehicle yet',
            message: 'Add a vehicle to start tracking real efficiency.',
            actionLabel: 'Add vehicle',
            onAction: controller.goToVehicleProfile,
          );
        }

        final unit = controller.distanceUnit.value;
        final currency = controller.currencySymbol.value;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => controller.refreshData(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard', style: theme.textTheme.headlineSmall),
                        Text(
                          'Hi ${controller.userName}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  VehicleSelector(
                    vehicles: controller.vehicles.toList(),
                    selectedId: controller.selectedVehicleId.value,
                    onSelected: controller.selectVehicle,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _HeadlineCard(controller: controller),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Cost / ${unit.toLowerCase()}',
                      value: Formatters.currency(
                        controller.monthlyCostPerDistance,
                        currency,
                      ),
                      icon: Icons.paid_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Month Miles',
                      value: Formatters.integer(controller.monthlyDistance),
                      icon: Icons.calendar_month_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Month Cost',
                      value: Formatters.currency(
                        controller.monthlyCost,
                        currency,
                      ),
                      icon: Icons.payments_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _TrendCard(controller: controller),
              const SizedBox(height: 22),
              SectionHeader(
                title: 'Recent Entries',
                trailing: TextButton(
                  onPressed: () => Get.find<MainController>().changeTab(1),
                  child: const Text('View all'),
                ),
              ),
              if (controller.recentEntries.isEmpty)
                const EmptyState(
                  compact: true,
                  icon: Icons.local_gas_station_rounded,
                  title: 'No entries yet',
                  message:
                      'Tap the + button to log your first fill-up or charge.',
                )
              else
                ...controller.recentEntries.map(
                  (entry) => EntryTile(
                    entry: entry,
                    currencySymbol: currency,
                    distanceUnit: unit,
                    volumeUnit: controller.volumeUnit.value,
                    onTap: () => controller.openEntry(entry),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isElectric = controller.isElectric;
    final isHybrid = controller.isHybrid;
    final realValue = isElectric
        ? Formatters.twoDecimal(controller.primaryEfficiency)
        : isHybrid
        ? Formatters.currency(
            controller.primaryEfficiency,
            controller.currencySymbol.value,
          )
        : Formatters.oneDecimal(controller.primaryEfficiency);
    final claimed = controller.claimedPrimary;

    return AppCard(
      padding: const EdgeInsets.all(18),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                controller.headlineLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              if (claimed != null && !isHybrid)
                DeltaBadge(value: controller.differencePercent),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                realValue,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: isHybrid ? 36 : 44,
                ),
              ),
              if (!isHybrid) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    controller.primaryUnit,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (isHybrid) ...[
            const SizedBox(height: 8),
            Text(
              '${Formatters.oneDecimal(controller.realMpg)} MPG fuel • '
              '${Formatters.twoDecimal(controller.realMilesPerKwh)} mi/kWh electric',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _claimText(controller, claimed),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _claimText(HomeController controller, double? claimed) {
    if (controller.isElectric && claimed != null) {
      return 'Claimed: ${Formatters.twoDecimal(claimed)} mi/kWh';
    }
    if (controller.isHybrid) {
      final parts = <String>[];
      if (controller.claimedMpg > 0) {
        parts.add('${Formatters.oneDecimal(controller.claimedMpg)} MPG fuel');
      }
      if (controller.claimedMiPerKwh > 0) {
        parts.add(
          '${Formatters.twoDecimal(controller.claimedMiPerKwh)} mi/kWh',
        );
      }
      if (parts.isEmpty) return 'Add manufacturer claims to compare';
      return 'Claimed: ${parts.join(' • ')}';
    }
    if (claimed != null) {
      return 'Claimed: ${Formatters.oneDecimal(claimed)} MPG';
    }
    return 'Add a manufacturer claim to compare';
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = controller.trendPoints;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.trendTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (points.length >= 2)
                DeltaBadge(value: controller.trendChangePercent),
            ],
          ),
          const SizedBox(height: 16),
          TrendLineChart(points: points, height: 180),
        ],
      ),
    );
  }
}
