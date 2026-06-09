import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_controller.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class FuelView extends GetView<FuelController> {
  const FuelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Entry & History')),
      body: Obx(() {
        if (!controller.isHydrated.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final vehicles = controller.vehicles;
        if (vehicles.isEmpty) {
          return const Center(child: Text('No vehicle found. Add vehicle first.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: controller.selectedVehicleId.value,
              decoration: const InputDecoration(labelText: 'Vehicle'),
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
                  controller.onVehicleChanged(value);
                }
              },
            ),
            const SizedBox(height: 12),
            _ModeHeader(mode: controller.selectedMode.value),
            const SizedBox(height: 12),
            TextField(
              controller: controller.odometerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    'Odometer (${controller.distanceUnit.value.toLowerCase()})',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    'Distance since last fill (${controller.distanceUnit.value.toLowerCase()})',
              ),
            ),
            const SizedBox(height: 10),
            if (controller.selectedMode.value == EnergyMode.fuel ||
                controller.selectedMode.value == EnergyMode.hybrid) ...[
              TextField(
                controller: controller.litersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fuel used (liters)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.fuelCostController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Fuel cost (${controller.currencySymbol.value})',
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (controller.selectedMode.value == EnergyMode.charge ||
                controller.selectedMode.value == EnergyMode.hybrid) ...[
              TextField(
                controller: controller.kwhController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'kWh used'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.electricityCostController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'Electricity cost (${controller.currencySymbol.value})',
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: controller.saveEntry,
                child: const Text('Save Entry'),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            if (controller.selectedEntries.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No entries yet for selected vehicle'),
                ),
              )
            else
              ...controller.selectedEntries.map(
                (entry) => _HistoryTile(
                  entry: entry,
                  currency: controller.currencySymbol.value,
                  distanceUnit: controller.distanceUnit.value,
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _ModeHeader extends StatelessWidget {
  const _ModeHeader({required this.mode});
  final EnergyMode mode;

  @override
  Widget build(BuildContext context) {
    final color = mode == EnergyMode.fuel
        ? AppColors.primary
        : mode == EnergyMode.charge
            ? AppColors.secondary
            : AppColors.accentPurple;
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              mode == EnergyMode.fuel
                  ? Icons.local_gas_station
                  : mode == EnergyMode.charge
                      ? Icons.bolt
                      : Icons.auto_awesome_motion_rounded,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Entry mode: ${mode.title} (${mode.subtitle})',
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          entry.mode == EnergyMode.charge
              ? Icons.bolt
              : entry.mode == EnergyMode.hybrid
                  ? Icons.auto_awesome_motion_rounded
                  : Icons.local_gas_station,
        ),
        title: Text(
          '${entry.distance.toStringAsFixed(0)} $distanceUnit • $currency${entry.totalCost.toStringAsFixed(2)}',
        ),
        subtitle: Text(
          '${entry.date.day}/${entry.date.month}/${entry.date.year} • Odometer ${entry.odometer.toStringAsFixed(0)}',
        ),
        trailing: Text(
          '$currency${entry.costPerDistance.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
