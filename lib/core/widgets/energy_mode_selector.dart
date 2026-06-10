import 'package:flutter/material.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';

/// Selectable list of the three energy modes (Fuel / Charge / Hybrid), used in
/// onboarding and vehicle creation.
class EnergyModeSelector extends StatelessWidget {
  const EnergyModeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final EnergyMode selected;
  final ValueChanged<EnergyMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final mode in EnergyMode.values) ...[
          _EnergyModeTile(
            mode: mode,
            selected: selected == mode,
            onTap: () => onSelected(mode),
          ),
          if (mode != EnergyMode.values.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _EnergyModeTile extends StatelessWidget {
  const _EnergyModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final EnergyMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? mode.surface : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? mode.color : theme.dividerColor,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: mode.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(mode.icon, color: mode.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mode.title, style: theme.textTheme.titleMedium),
                      Text(mode.subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? mode.color : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
