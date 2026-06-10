import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/app_card.dart';
import 'package:fuel_efficiency_app/core/widgets/empty_state.dart';
import 'package:fuel_efficiency_app/core/widgets/loading_view.dart';
import 'package:fuel_efficiency_app/core/widgets/section_header.dart';
import 'package:fuel_efficiency_app/core/widgets/stat_card.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_controller.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class VehicleView extends GetView<VehicleController> {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Profile'),
        actions: [
          IconButton(
            onPressed: controller.addVehicle,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add vehicle',
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isHydrated.value) return const LoadingView();
        final vehicle = controller.vehicle;
        if (vehicle == null) {
          return EmptyState(
            icon: Icons.directions_car_filled_rounded,
            title: 'No vehicle',
            message: 'Add your first vehicle to get started.',
            actionLabel: 'Add vehicle',
            onAction: controller.addVehicle,
          );
        }

        final currency = controller.currencySymbol.value;
        final unit = controller.distanceUnit.value;
        final isElectric = !vehicle.energyMode.usesFuel;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HeroCard(vehicle: vehicle),
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      label: isElectric ? 'mi/kWh' : 'MPG',
                      value: isElectric
                          ? Formatters.twoDecimal(controller.avgMilesPerKwh)
                          : Formatters.oneDecimal(controller.avgMpg),
                    ),
                  ),
                  _vDivider(context),
                  Expanded(
                    child: _HeroMetric(
                      label: 'Cost / ${unit.toLowerCase()}',
                      value: Formatters.currency(
                        controller.avgCostPerDistance,
                        currency,
                      ),
                    ),
                  ),
                  _vDivider(context),
                  Expanded(
                    child: _HeroMetric(
                      label: 'Entries',
                      value: controller.entryCount.toString(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total $unit',
                    value: Formatters.integer(controller.totalDistance),
                    icon: Icons.route_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Total Cost',
                    value: Formatters.currency(controller.totalCost, currency),
                    icon: Icons.payments_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Days Tracked',
                    value: controller.daysTracked.toString(),
                    icon: Icons.event_available_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.editVehicle,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit Vehicle'),
              ),
            ),
            const SizedBox(height: 22),
            if (controller.vehicles.length > 1) ...[
              const SectionHeader(title: 'Your Vehicles'),
              ...controller.vehicles.map(
                (v) => _VehicleRow(
                  vehicle: v,
                  selected: v.id == controller.selectedVehicleId.value,
                  onTap: () => controller.selectVehicle(v.id),
                  onDelete: () => _confirmDelete(context, v),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(context, vehicle),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.negative,
                  ),
                  label: const Text(
                    'Delete Vehicle',
                    style: TextStyle(color: AppColors.negative),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _vDivider(BuildContext context) =>
      Container(height: 40, width: 1, color: Theme.of(context).dividerColor);

  void _confirmDelete(BuildContext context, VehicleModel vehicle) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${vehicle.name}?'),
        content: const Text(
          'All entries for this vehicle will also be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.negative),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.deleteVehicle(vehicle.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.vehicle});
  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  vehicle.energyMode.color.withValues(alpha: 0.18),
                  vehicle.energyMode.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 64,
              color: vehicle.energyMode.color,
            ),
          ),
          const SizedBox(height: 16),
          Text(vehicle.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(
            '${vehicle.makeModel} • ${vehicle.year}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: vehicle.energyMode.surface,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  vehicle.energyMode.icon,
                  size: 16,
                  color: vehicle.energyMode.color,
                ),
                const SizedBox(width: 8),
                Text(
                  '${vehicle.energyMode.title} • ${vehicle.energyMode.subtitle}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: vehicle.energyMode.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const _VehicleRow({
    required this.vehicle,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });
  final VehicleModel vehicle;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        color: selected ? vehicle.energyMode.surface : null,
        border: selected
            ? Border.all(color: vehicle.energyMode.color.withValues(alpha: 0.4))
            : null,
        child: Row(
          children: [
            Icon(vehicle.energyMode.icon, color: vehicle.energyMode.color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.name, style: theme.textTheme.titleMedium),
                  Text(
                    '${vehicle.makeModel} • ${vehicle.year}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary)
            else
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
