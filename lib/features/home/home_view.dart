import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/features/home/home_controller.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (!controller.isHydrated.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(controller: controller),
              const SizedBox(height: 16),
              _VehicleSelector(controller: controller),
              const SizedBox(height: 16),
              _PrimaryMetrics(controller: controller),
              const SizedBox(height: 14),
              _MiniStats(controller: controller),
              const SizedBox(height: 24),
              Text(
                'Efficiency Trend (last 6)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _TrendCard(controller: controller),
              const SizedBox(height: 24),
              Text(
                'Recent Entries',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (controller.recentEntries.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No fuel entries yet. Add your first entry.'),
                  ),
                )
              else
                ...controller.recentEntries.map(
                  (entry) => _EntryTile(
                    entry: entry,
                    currency: controller.currencySymbol.value,
                    distanceUnit: controller.distanceUnit.value,
                  ),
                ),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: controller.goToFuel,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Entry'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.goToVehicle,
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Vehicle'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: controller.goToSettings,
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hi ${controller.userName}, let\'s track real efficiency.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _VehicleSelector extends StatelessWidget {
  const _VehicleSelector({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final vehicles =
        controller.vehicles.cast<VehicleModel>().toList(growable: false);
    if (vehicles.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('No vehicle found. Add a vehicle to continue.'),
        ),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: controller.selectedVehicleId.value.isEmpty
          ? vehicles.first.id
          : controller.selectedVehicleId.value,
      decoration: const InputDecoration(labelText: 'Selected vehicle'),
      items: vehicles
          .map(
            (vehicle) => DropdownMenuItem<String>(
              value: vehicle.id,
              child: Text('${vehicle.name} • ${vehicle.makeModel}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          controller.selectVehicle(value);
        }
      },
    );
  }
}

class _PrimaryMetrics extends StatelessWidget {
  const _PrimaryMetrics({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: _MetricBlock(
                title: 'Real MPG',
                value: controller.realMpg.toStringAsFixed(1),
                icon: Icons.show_chart,
              ),
            ),
            Expanded(
              child: _MetricBlock(
                title: 'Claimed MPG',
                value: controller.claimedMpg <= 0
                    ? '--'
                    : controller.claimedMpg.toStringAsFixed(1),
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStats extends StatelessWidget {
  const _MiniStats({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final currency = controller.currencySymbol.value;
    final unit = controller.distanceUnit.value.toLowerCase();
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            title: 'Monthly Cost',
            value: '$currency${controller.monthlyFuelCost.toStringAsFixed(0)}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            title: 'Cost per $unit',
            value: '$currency${controller.avgCostPerDistance.toStringAsFixed(2)}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            title: 'Reality',
            value: '${controller.realityPercent.toStringAsFixed(1)}%',
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final trend = controller.recentEntries.cast<FuelEntryModel>().toList();
    final values = trend.take(6).map((e) => e.costPerDistance).toList().reversed.toList();
    final max = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          height: 80,
          child: values.isEmpty
              ? const Center(child: Text('Not enough data'))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: values
                      .map(
                        (value) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              height: (value / max) * 70,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.currency,
    required this.distanceUnit,
  });

  final FuelEntryModel entry;
  final String currency;
  final String distanceUnit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          entry.mode.name == 'charge'
              ? Icons.bolt
              : entry.mode.name == 'hybrid'
                  ? Icons.auto_awesome_motion_rounded
                  : Icons.local_gas_station,
        ),
        title: Text(
          '${entry.distance.toStringAsFixed(0)} $distanceUnit • $currency${entry.totalCost.toStringAsFixed(2)}',
        ),
        subtitle: Text(
          '${entry.date.day}/${entry.date.month}/${entry.date.year}  |  Odo ${entry.odometer.toStringAsFixed(0)}',
        ),
        trailing: Text(
          '$currency${entry.costPerDistance.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
