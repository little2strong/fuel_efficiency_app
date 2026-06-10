import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/app_card.dart';
import 'package:fuel_efficiency_app/core/widgets/empty_state.dart';
import 'package:fuel_efficiency_app/features/entry/entry_detail_controller.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

class EntryDetailView extends GetView<EntryDetailController> {
  const EntryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final entry = controller.entry;
      if (entry == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Entry')),
          body: const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Entry not found',
            message: 'This entry may have been deleted.',
          ),
        );
      }

      final mode = entry.mode;
      final currency = controller.currencySymbol.value;
      final unit = controller.distanceUnit.value;

      return Scaffold(
        appBar: AppBar(
          title: Text('${mode.title} Entry'),
          actions: [
            IconButton(
              onPressed: controller.edit,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.negative,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AppCard(
              color: mode.surface,
              border: Border.all(color: mode.color.withValues(alpha: 0.3)),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: mode.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(mode.icon, color: mode.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mode.title, style: theme.textTheme.titleLarge),
                        Text(
                          Formatters.fullDate(entry.date),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailGroup(
              title: 'Trip',
              rows: [
                _DetailRow(
                  'Odometer (Start)',
                  '${Formatters.integer(entry.startOdometer)} ${unit.toLowerCase()}',
                ),
                _DetailRow(
                  'Odometer (End)',
                  '${Formatters.integer(entry.odometer)} ${unit.toLowerCase()}',
                ),
                _DetailRow(
                  'Distance Driven',
                  '${Formatters.integer(entry.distance)} ${unit.toLowerCase()}',
                ),
              ],
            ),
            if (mode.usesFuel) ...[
              const SizedBox(height: 14),
              _DetailGroup(
                title: 'Fuel',
                rows: [
                  _DetailRow(
                    'Litres Added',
                    '${Formatters.twoDecimal(entry.liters)} L',
                  ),
                  _DetailRow(
                    'Fuel Cost',
                    Formatters.currency(entry.fuelCost, currency),
                  ),
                  if (entry.costPerLiter > 0)
                    _DetailRow(
                      'Cost / Litre',
                      Formatters.currency(entry.costPerLiter, currency),
                    ),
                  if (entry.fuelGrade != null && entry.fuelGrade!.isNotEmpty)
                    _DetailRow('Fuel Grade', entry.fuelGrade!),
                  _DetailRow('Full Tank', entry.fullTank ? 'Yes' : 'No'),
                ],
              ),
            ],
            if (mode.usesCharge) ...[
              const SizedBox(height: 14),
              _DetailGroup(
                title: 'Charge',
                rows: [
                  _DetailRow(
                    'kWh Added',
                    '${Formatters.twoDecimal(entry.kwh)} kWh',
                  ),
                  _DetailRow(
                    'Charge Cost',
                    Formatters.currency(entry.electricityCost, currency),
                  ),
                  if (entry.costPerKwh > 0)
                    _DetailRow(
                      'Cost / kWh',
                      Formatters.currency(entry.costPerKwh, currency),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: mode == EnergyMode.charge ? 'mi/kWh' : 'Real MPG',
                      value: mode == EnergyMode.charge
                          ? Formatters.twoDecimal(controller.milesPerKwh)
                          : Formatters.oneDecimal(controller.mpg),
                      color: mode.color,
                    ),
                  ),
                  Container(height: 40, width: 1, color: theme.dividerColor),
                  Expanded(
                    child: _Metric(
                      label: 'Cost / ${unit.toLowerCase()}',
                      value: Formatters.currency(
                        entry.costPerDistance,
                        currency,
                      ),
                      color: mode.color,
                    ),
                  ),
                  Container(height: 40, width: 1, color: theme.dividerColor),
                  Expanded(
                    child: _Metric(
                      label: 'Total Cost',
                      value: Formatters.currency(entry.totalCost, currency),
                      color: mode.color,
                    ),
                  ),
                ],
              ),
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _DetailGroup(title: 'Note', rows: [_DetailRow('', entry.note!)]),
            ],
          ],
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.negative),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.delete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.title, required this.rows});
  final String title;
  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Expanded(
            child: Text(
              value,
              textAlign: label.isEmpty ? TextAlign.left : TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
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
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(color: color)),
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
