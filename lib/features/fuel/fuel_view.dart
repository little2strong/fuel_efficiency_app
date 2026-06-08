import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_controller.dart';

class FuelView extends GetView<FuelController> {
  const FuelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuel Entries')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.entries.isEmpty) {
          return const Center(
            child: Text('No fuel entries yet.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = controller.entries[index];
            return Card(
              child: ListTile(
                title: Text('${entry.liters.toStringAsFixed(2)} L'),
                subtitle: Text(
                  'Odometer: ${entry.odometer.toStringAsFixed(0)} km',
                ),
                trailing: Text('\$${entry.cost.toStringAsFixed(2)}'),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntrySheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context) {
    if (controller.vehicles.isEmpty) {
      Get.snackbar(
        'No vehicle',
        'Add a vehicle before creating a fuel entry.',
      );
      return;
    }

    final litersController = TextEditingController();
    final costController = TextEditingController();
    final odometerController = TextEditingController();
    var selectedVehicleId = controller.vehicles.first.id;

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Fuel Entry',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedVehicleId,
                  decoration: const InputDecoration(labelText: 'Vehicle'),
                  items: controller.vehicles
                      .map(
                        (vehicle) => DropdownMenuItem(
                          value: vehicle.id,
                          child: Text(vehicle.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedVehicleId = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: litersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Liters'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cost'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: odometerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Odometer (km)'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final liters = double.tryParse(litersController.text);
                    final cost = double.tryParse(costController.text);
                    final odometer = double.tryParse(odometerController.text);

                    if (liters == null || cost == null || odometer == null) {
                      Get.snackbar('Invalid input', 'Enter valid numbers.');
                      return;
                    }

                    controller.addEntry(
                      vehicleId: selectedVehicleId,
                      liters: liters,
                      cost: cost,
                      odometer: odometer,
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
