import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuel_efficiency_app/features/home/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: controller.goToSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => controller.loadDashboard(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _QuickActions(controller: controller),
              const SizedBox(height: 24),
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Vehicles',
                value: controller.vehicles.length.toString(),
                icon: Icons.directions_car,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Fuel Entries',
                value: controller.recentEntries.length.toString(),
                icon: Icons.local_gas_station,
              ),
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
                  (entry) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_gas_station),
                      title: Text('${entry.liters.toStringAsFixed(2)} L'),
                      subtitle: Text(
                        '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                      ),
                      trailing: Text('\$${entry.cost.toStringAsFixed(2)}'),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToFuel,
        icon: const Icon(Icons.add),
        label: const Text('Add Fuel'),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Fuel',
            icon: Icons.local_gas_station,
            onTap: controller.goToFuel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Vehicles',
            icon: Icons.directions_car,
            onTap: controller.goToVehicle,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
