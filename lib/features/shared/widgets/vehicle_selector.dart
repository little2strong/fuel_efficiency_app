import 'package:flutter/material.dart';

import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

/// Compact pill that opens a bottom sheet to switch the active vehicle.
class VehicleSelector extends StatelessWidget {
  const VehicleSelector({
    super.key,
    required this.vehicles,
    required this.selectedId,
    required this.onSelected,
  });

  final List<VehicleModel> vehicles;
  final String selectedId;
  final ValueChanged<String> onSelected;

  VehicleModel? get _selected {
    for (final v in vehicles) {
      if (v.id == selectedId) return v;
    }
    return vehicles.isNotEmpty ? vehicles.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;
    if (selected == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: vehicles.length <= 1 ? null : () => _openSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected.energyMode.icon,
              size: 16,
              color: selected.energyMode.color,
            ),
            const SizedBox(width: 8),
            Text(
              selected.name,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
            ),
            if (vehicles.length > 1) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: 44,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('Switch vehicle', style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              ...vehicles.map(
                (v) => ListTile(
                  leading: Icon(v.energyMode.icon, color: v.energyMode.color),
                  title: Text(v.name, style: theme.textTheme.titleMedium),
                  subtitle: Text('${v.makeModel} • ${v.year}'),
                  trailing: v.id == selectedId
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    onSelected(v.id);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
