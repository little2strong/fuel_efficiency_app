import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/app_card.dart';
import 'package:fuel_efficiency_app/core/widgets/delta_badge.dart';
import 'package:fuel_efficiency_app/core/widgets/efficiency_gauge.dart';
import 'package:fuel_efficiency_app/core/widgets/empty_state.dart';
import 'package:fuel_efficiency_app/features/reality/reality_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class RealityView extends GetView<RealityController> {
  const RealityView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reality vs Estimate')),
      body: Obx(() {
        if (controller.vehicle == null) {
          return const EmptyState(
            icon: Icons.speed_rounded,
            title: 'No vehicle',
            message: 'Add a vehicle to compare claimed vs real efficiency.',
          );
        }
        if (!controller.hasClaim) {
          return const EmptyState(
            icon: Icons.fact_check_rounded,
            title: 'No manufacturer claim',
            message:
                'Add claimed efficiency values to your vehicle profile to unlock this comparison.',
          );
        }
        if (!controller.hasData) {
          return const EmptyState(
            icon: Icons.insights_rounded,
            title: 'Not enough data',
            message: 'Log a few entries to compare against the claim.',
          );
        }

        final mode = controller.mode!;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Center(child: EfficiencyGauge(percent: controller.realityPercent)),
            const SizedBox(height: 8),
            Center(
              child: Text(
                controller.gaugeCaption,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                controller.verdict,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 20),
            if (mode == EnergyMode.hybrid) ...[
              _HybridComparisonCard(controller: controller),
            ] else ...[
              _SingleComparisonCard(controller: controller, mode: mode),
            ],
            const SizedBox(height: 14),
            AppCard(
              color: controller.savings <= 0
                  ? AppColors.primarySurface
                  : AppColors.negative.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Icon(
                    controller.savings <= 0
                        ? Icons.savings_rounded
                        : Icons.trending_up_rounded,
                    color: controller.savings <= 0
                        ? AppColors.primary
                        : AppColors.negative,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.savings <= 0
                              ? 'Estimated saving vs claim'
                              : 'Extra spend vs claim',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          Formatters.currency(
                            controller.savings.abs(),
                            controller.currencySymbol.value,
                          ),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: controller.savings <= 0
                                ? AppColors.primary
                                : AppColors.negative,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SingleComparisonCard extends StatelessWidget {
  const _SingleComparisonCard({required this.controller, required this.mode});
  final RealityController controller;
  final EnergyMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isElectric = mode == EnergyMode.charge;
    final unit = isElectric ? 'mi/kWh' : 'MPG';
    final claimed = isElectric
        ? controller.claimedMiPerKwh
        : controller.claimedMpg;
    final real = isElectric ? controller.realMilesPerKwh : controller.realMpg;
    final format = isElectric ? Formatters.twoDecimal : Formatters.oneDecimal;

    return AppCard(
      child: Column(
        children: [
          _ComparisonRow(
            label: 'Claimed (Manufacturer)',
            value: '${format(claimed)} $unit',
            color: AppColors.textSecondary,
          ),
          Divider(color: theme.dividerColor, height: 24),
          _ComparisonRow(
            label: 'Your Real Average',
            value: '${format(real)} $unit',
            color: AppColors.primary,
          ),
          Divider(color: theme.dividerColor, height: 24),
          Row(
            children: [
              Expanded(
                child: Text('Difference', style: theme.textTheme.bodyLarge),
              ),
              DeltaBadge(value: controller.differencePercent),
            ],
          ),
        ],
      ),
    );
  }
}

class _HybridComparisonCard extends StatelessWidget {
  const _HybridComparisonCard({required this.controller});
  final RealityController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.claimedMpg > 0) ...[
            Text('Fuel (MPG)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            _ComparisonRow(
              label: 'Claimed',
              value: '${Formatters.oneDecimal(controller.claimedMpg)} MPG',
              color: AppColors.fuel,
            ),
            const SizedBox(height: 8),
            _ComparisonRow(
              label: 'Your Average',
              value: '${Formatters.oneDecimal(controller.realMpg)} MPG',
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('Difference')),
                DeltaBadge(value: controller.fuelDifferencePercent),
              ],
            ),
          ],
          if (controller.claimedMpg > 0 && controller.claimedMiPerKwh > 0)
            Divider(color: theme.dividerColor, height: 28),
          if (controller.claimedMiPerKwh > 0) ...[
            Text('Electric (mi/kWh)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            _ComparisonRow(
              label: 'Claimed',
              value:
                  '${Formatters.twoDecimal(controller.claimedMiPerKwh)} mi/kWh',
              color: AppColors.charge,
            ),
            const SizedBox(height: 8),
            _ComparisonRow(
              label: 'Your Average',
              value:
                  '${Formatters.twoDecimal(controller.realMilesPerKwh)} mi/kWh',
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('Difference')),
                DeltaBadge(value: controller.electricDifferencePercent),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(color: color)),
      ],
    );
  }
}
