import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/app_card.dart';
import 'package:fuel_efficiency_app/core/widgets/delta_badge.dart';
import 'package:fuel_efficiency_app/core/widgets/empty_state.dart';
import 'package:fuel_efficiency_app/core/widgets/loading_view.dart';
import 'package:fuel_efficiency_app/core/widgets/segmented_tabs.dart';
import 'package:fuel_efficiency_app/core/widgets/stat_card.dart';
import 'package:fuel_efficiency_app/core/widgets/trend_line_chart.dart';
import 'package:fuel_efficiency_app/features/analytics/analytics_controller.dart';
import 'package:fuel_efficiency_app/features/shared/efficiency_service.dart';

class AnalyticsTab extends GetView<AnalyticsController> {
  const AnalyticsTab({super.key});

  String _fmt(double value) {
    if (controller.isCostMetric) {
      return Formatters.currency(value, controller.currencySymbol.value);
    }
    return Formatters.oneDecimal(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Obx(() {
        if (!controller.isHydrated.value) return const LoadingView();
        if (!controller.hasVehicle) {
          return const EmptyState(
            icon: Icons.bar_chart_rounded,
            title: 'No analytics yet',
            message: 'Add a vehicle and log entries to unlock insights.',
          );
        }

        final stats = controller.stats;
        final currency = controller.currencySymbol.value;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text('Efficiency Analytics', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            SegmentedTabs(
              labels: const ['MPG', 'mi/kWh', 'Cost'],
              selectedIndex: controller.metricIndex.value,
              onChanged: controller.setMetric,
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.metricTitle,
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _fmt(stats.average),
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  controller.metricUnit,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (stats.hasData)
                        DeltaBadge(
                          value: controller.changePercent,
                          invertColors: controller.isCostMetric,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TrendLineChart(
                    points: controller.trendPoints,
                    height: 200,
                    color: controller.isCostMetric
                        ? AppColors.charge
                        : AppColors.primary,
                    currencySymbol: controller.isCostMetric ? currency : '',
                  ),
                  const SizedBox(height: 12),
                  SegmentedTabs(
                    dense: true,
                    labels: [for (final r in AnalyticsRange.values) r.label],
                    selectedIndex: controller.rangeIndex.value,
                    onChanged: controller.setRange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!stats.hasData)
              const EmptyState(
                compact: true,
                icon: Icons.insights_rounded,
                title: 'Not enough data',
                message: 'Log more entries in this period to see analytics.',
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Best',
                      value: '${_fmt(stats.best)} ${controller.metricUnit}',
                      icon: Icons.trending_up_rounded,
                      valueColor: AppColors.positive,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Worst',
                      value: '${_fmt(stats.worst)} ${controller.metricUnit}',
                      icon: Icons.trending_down_rounded,
                      valueColor: AppColors.negative,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total ${controller.distanceUnit.value}',
                      value: Formatters.integer(stats.totalDistance),
                      icon: Icons.route_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Total Cost',
                      value: Formatters.currency(stats.totalCost, currency),
                      icon: Icons.payments_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Avg Cost / ${controller.distanceUnit.value}',
                      value: Formatters.currency(
                        stats.avgCostPerDistance,
                        currency,
                      ),
                      icon: Icons.attach_money_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: controller.savings >= 0
                          ? 'Over Claim'
                          : 'Saved vs Claim',
                      value: Formatters.currency(
                        controller.savings.abs(),
                        currency,
                      ),
                      icon: Icons.savings_rounded,
                      valueColor: controller.savings <= 0
                          ? AppColors.positive
                          : AppColors.negative,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      }),
    );
  }
}
