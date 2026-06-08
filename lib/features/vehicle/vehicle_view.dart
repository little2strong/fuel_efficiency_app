import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_controller.dart';

class VehicleView extends GetView<VehicleController> {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.vehicles.isEmpty) {
          return const Center(
            child: Text('No vehicles yet. Add your first vehicle.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.vehicles.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final vehicle = controller.vehicles[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text(vehicle.name),
                subtitle: Text(
                  '${vehicle.fuelType} • ${vehicle.odometer.toStringAsFixed(0)} km',
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddVehicleSheet(BuildContext context) {
    final nameController = TextEditingController();
    final odometerController = TextEditingController();
    var fuelType = 'Petrol';

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
                  'Add Vehicle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Vehicle name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: fuelType,
                  decoration: const InputDecoration(labelText: 'Fuel type'),
                  items: const [
                    DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                    DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                    DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => fuelType = value);
                    }
                  },
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
                    final name = nameController.text.trim();
                    final odometer = double.tryParse(odometerController.text);

                    if (name.isEmpty || odometer == null) {
                      Get.snackbar('Invalid input', 'Enter valid details.');
                      return;
                    }

                    controller.addVehicle(
                      name: name,
                      fuelType: fuelType,
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
