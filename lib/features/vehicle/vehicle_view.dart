import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_controller.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

class VehicleView extends GetView<VehicleController> {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Profile')),
      body: Obx(() {
        if (!controller.isHydrated.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.vehicles.isNotEmpty) ...[
              Text(
                'Existing Vehicles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ...controller.vehicles.map(
                (vehicle) => _VehicleCard(
                  vehicle: vehicle,
                  selected: controller.selectedVehicleId.value == vehicle.id,
                  onTap: () => controller.selectVehicle(vehicle.id),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Add Vehicle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Vehicle nickname'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.makeModelController,
              decoration: const InputDecoration(labelText: 'Make / Model'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Year'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.odometerController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Odometer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.vehicleType.value,
                decoration: const InputDecoration(labelText: 'Vehicle type'),
                items: const [
                  DropdownMenuItem(value: 'Car', child: Text('Car')),
                  DropdownMenuItem(value: 'Motorbike', child: Text('Motorbike')),
                  DropdownMenuItem(value: 'Truck', child: Text('Truck')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.vehicleType.value = value;
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => DropdownButtonFormField<EnergyMode>(
                initialValue: controller.energyMode.value,
                decoration: const InputDecoration(labelText: 'Energy mode'),
                items: EnergyMode.values
                    .map(
                      (mode) => DropdownMenuItem<EnergyMode>(
                        value: mode,
                        child: Text(mode.title),
                      ),
                    )
                    .toList(),
                onChanged: (mode) {
                  if (mode != null) {
                    controller.energyMode.value = mode;
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Column(
                children: [
                  if (controller.energyMode.value == EnergyMode.fuel ||
                      controller.energyMode.value == EnergyMode.hybrid)
                    TextField(
                      controller: controller.claimedMpgController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Claimed MPG (optional)',
                      ),
                    ),
                  if (controller.energyMode.value == EnergyMode.fuel ||
                      controller.energyMode.value == EnergyMode.hybrid)
                    const SizedBox(height: 10),
                  if (controller.energyMode.value == EnergyMode.charge ||
                      controller.energyMode.value == EnergyMode.hybrid)
                    TextField(
                      controller: controller.batteryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Battery kWh capacity (optional)',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => controller.addVehicle(context: context),
                child: const Text('Save Vehicle'),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  final VehicleModel vehicle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: selected ? AppColors.primary.withValues(alpha: 0.1) : null,
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.directions_car),
        title: Text('${vehicle.name} • ${vehicle.makeModel}'),
        subtitle: Text(
          '${vehicle.year} • ${vehicle.energyMode.title} • ${vehicle.odometer.toStringAsFixed(0)}',
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : null,
      ),
    );
  }
}
