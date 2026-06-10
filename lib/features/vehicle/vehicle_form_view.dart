import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/widgets/app_text_field.dart';
import 'package:fuel_efficiency_app/core/widgets/energy_mode_selector.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_form_controller.dart';

class VehicleFormView extends GetView<VehicleFormController> {
  const VehicleFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AppTextField(
              controller: controller.nameController,
              label: 'Vehicle Nickname',
              hint: 'My Car',
              validator: (v) => controller.validateRequired(v, 'Nickname'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.makeModelController,
              label: 'Make / Model',
              hint: 'Toyota Prius',
              validator: (v) => controller.validateRequired(v, 'Make / Model'),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: controller.yearController,
                    label: 'Year',
                    hint: '2018',
                    numeric: true,
                    validator: controller.validateYear,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: controller.odometerController,
                    label: 'Odometer',
                    hint: '0',
                    numeric: true,
                    validator: controller.validateOdometer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Vehicle Type',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.vehicleType.value,
                items: VehicleFormController.vehicleTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) controller.vehicleType.value = value;
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Energy Mode',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => EnergyModeSelector(
                selected: controller.energyMode.value,
                onSelected: (mode) => controller.energyMode.value = mode,
              ),
            ),
            const SizedBox(height: 18),
            Obx(() {
              final mode = controller.energyMode.value;
              return Column(
                children: [
                  if (mode.usesFuel)
                    AppTextField(
                      controller: controller.claimedMpgController,
                      label: 'Claimed MPG (Optional)',
                      hint: '58.0',
                      numeric: true,
                    ),
                  if (mode.usesFuel) const SizedBox(height: 16),
                  if (mode.usesCharge)
                    AppTextField(
                      controller: controller.claimedMiPerKwhController,
                      label: 'Claimed mi/kWh (Optional)',
                      hint: '4.2',
                      numeric: true,
                    ),
                  if (mode.usesCharge) const SizedBox(height: 16),
                  if (mode.usesCharge)
                    AppTextField(
                      controller: controller.batteryController,
                      label: 'Battery Capacity kWh (Optional)',
                      hint: '40',
                      numeric: true,
                    ),
                ],
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => FilledButton(
                  onPressed: controller.isSaving.value ? null : controller.save,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          controller.isEditing
                              ? 'Save Changes'
                              : 'Save Vehicle',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
