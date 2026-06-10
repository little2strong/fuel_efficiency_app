import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/app_card.dart';
import 'package:fuel_efficiency_app/core/widgets/app_text_field.dart';
import 'package:fuel_efficiency_app/core/widgets/empty_state.dart';
import 'package:fuel_efficiency_app/features/entry/entry_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class EntryFormView extends GetView<EntryController> {
  const EntryFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = controller.mode;
      final color = mode.color;
      final title = controller.isEditing
          ? 'Edit Entry'
          : switch (mode) {
              EnergyMode.fuel => 'Add Fuel Entry',
              EnergyMode.charge => 'Add Charge Entry',
              EnergyMode.hybrid => 'Add Hybrid Entry',
            };

      if (controller.vehicles.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Add Entry')),
          body: const EmptyState(
            icon: Icons.directions_car_filled_rounded,
            title: 'No vehicle',
            message: 'Add a vehicle before logging entries.',
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(mode.icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
        ),
        body: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (controller.vehicles.length > 1) ...[
                _VehicleDropdown(controller: controller),
                const SizedBox(height: 16),
              ],
              _DateField(controller: controller),
              const SizedBox(height: 16),
              AppTextField(
                controller: controller.odometerController,
                label:
                    'Odometer (${controller.distanceUnit.value.toLowerCase()})',
                hint: 'e.g. ${controller.baselineOdometer.toStringAsFixed(0)}',
                numeric: true,
                validator: controller.validateOdometer,
              ),
              const SizedBox(height: 16),
              if (mode.usesFuel) ...[
                _SectionLabel(
                  label: 'Fuel Used',
                  color: AppColors.fuel,
                  show: mode == EnergyMode.hybrid,
                ),
                AppTextField(
                  controller: controller.litersController,
                  label: controller.volumeLabel,
                  hint: '0.00',
                  numeric: true,
                  suffixText: controller.volumeSuffix,
                  validator: (v) =>
                      controller.validatePositive(v, required: true),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.fuelCostController,
                  label: 'Fuel Cost (${controller.currencySymbol.value})',
                  hint: '0.00',
                  numeric: true,
                  validator: (v) =>
                      controller.validatePositive(v, required: true),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.fuelGradeController,
                  label: 'Fuel Grade (Optional)',
                  hint: 'e.g. Shell V-Power',
                ),
                const SizedBox(height: 8),
                Obx(
                  () => SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.fuel,
                    title: const Text('Full tank'),
                    subtitle: const Text('Improves MPG accuracy'),
                    value: controller.fullTank.value,
                    onChanged: (v) => controller.fullTank.value = v,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (mode.usesCharge) ...[
                _SectionLabel(
                  label: 'Electric Used',
                  color: AppColors.charge,
                  show: mode == EnergyMode.hybrid,
                ),
                AppTextField(
                  controller: controller.kwhController,
                  label: 'kWh Added',
                  hint: '0.00',
                  numeric: true,
                  suffixText: 'kWh',
                  validator: (v) =>
                      controller.validatePositive(v, required: true),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.electricityCostController,
                  label: 'Charge Cost (${controller.currencySymbol.value})',
                  hint: '0.00',
                  numeric: true,
                  validator: (v) =>
                      controller.validatePositive(v, required: true),
                ),
                const SizedBox(height: 16),
              ],
              AppTextField(
                controller: controller.noteController,
                label: 'Note (Optional)',
                hint: 'Anything worth remembering',
                maxLines: 2,
              ),
              const SizedBox(height: 18),
              _PreviewCard(controller: controller),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: color),
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
                          controller.isEditing ? 'Update Entry' : 'Save Entry',
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.color,
    required this.show,
  });
  final String label;
  final Color color;
  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(height: 14, width: 4, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.controller});
  final EntryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => controller.pickDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Text(
                    Formatters.dayMonthYear(controller.date.value),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleDropdown extends StatelessWidget {
  const _VehicleDropdown({required this.controller});
  final EntryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: controller.selectedVehicleId.value,
          items: controller.vehicles
              .map(
                (v) => DropdownMenuItem(
                  value: v.id,
                  child: Text('${v.name} • ${v.makeModel}'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) controller.onVehicleChanged(value);
          },
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.controller});
  final EntryController controller;

  @override
  Widget build(BuildContext context) {
    final mode = controller.mode;
    final unit = controller.distanceUnit.value;
    final currency = controller.currencySymbol.value;

    return Obx(() {
      final distance = controller.distance;
      final efficiencyLabel = mode == EnergyMode.charge ? 'mi/kWh' : 'Real MPG';
      final efficiencyValue = mode == EnergyMode.charge
          ? Formatters.twoDecimal(controller.previewMilesPerKwh)
          : Formatters.oneDecimal(controller.previewMpg);

      return AppCard(
        color: mode.surface,
        border: Border.all(color: mode.color.withValues(alpha: 0.3)),
        child: Row(
          children: [
            _Preview(
              label: 'Distance',
              value: '${Formatters.integer(distance)} ${unit.toLowerCase()}',
              color: mode.color,
            ),
            _Divider(color: mode.color),
            _Preview(
              label: mode == EnergyMode.hybrid ? 'Total Cost' : efficiencyLabel,
              value: mode == EnergyMode.hybrid
                  ? Formatters.currency(controller.previewTotalCost, currency)
                  : efficiencyValue,
              color: mode.color,
            ),
            _Divider(color: mode.color),
            _Preview(
              label: 'Cost / ${unit.toLowerCase()}',
              value: Formatters.currency(
                controller.previewCostPerDistance,
                currency,
              ),
              color: mode.color,
            ),
          ],
        ),
      );
    });
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
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
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 1,
      color: color.withValues(alpha: 0.25),
    );
  }
}
