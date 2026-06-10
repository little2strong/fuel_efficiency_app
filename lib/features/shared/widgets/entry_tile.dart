import 'package:flutter/material.dart';

import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/widgets/app_card.dart';
import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/shared/app_enums.dart';
import 'package:fuel_efficiency_app/features/shared/efficiency_service.dart';

/// List row representing a single fuel/charge/hybrid entry.
class EntryTile extends StatelessWidget {
  const EntryTile({
    super.key,
    required this.entry,
    required this.currencySymbol,
    required this.distanceUnit,
    this.volumeUnit = 'Litres',
    this.efficiency = const EfficiencyService(),
    this.onTap,
  });

  final FuelEntryModel entry;
  final String currencySymbol;
  final String distanceUnit;
  final String volumeUnit;
  final EfficiencyService efficiency;
  final VoidCallback? onTap;

  String get _primaryValue {
    switch (entry.mode) {
      case EnergyMode.charge:
        final v = efficiency.milesPerKwh(
          distance: entry.distance,
          kwh: entry.kwh,
          distanceUnit: distanceUnit,
        );
        return '${Formatters.twoDecimal(v)} mi/kWh';
      case EnergyMode.hybrid:
        final cost = efficiency.costPerDistance(
          totalCost: entry.totalCost,
          distance: entry.distance,
        );
        return Formatters.currency(cost, currencySymbol);
      case EnergyMode.fuel:
        final v = efficiency.mpg(
          distance: entry.distance,
          litres: entry.liters,
          distanceUnit: distanceUnit,
          volumeUnit: volumeUnit,
        );
        return '${Formatters.oneDecimal(v)} MPG';
    }
  }

  String? get _secondaryValue {
    if (entry.mode != EnergyMode.hybrid) return null;
    final mpg = efficiency.mpg(
      distance: entry.distance,
      litres: entry.liters,
      distanceUnit: distanceUnit,
      volumeUnit: volumeUnit,
    );
    final miKwh = efficiency.milesPerKwh(
      distance: entry.distance,
      kwh: entry.kwh,
      distanceUnit: distanceUnit,
    );
    return '${Formatters.oneDecimal(mpg)} MPG • ${Formatters.twoDecimal(miKwh)} mi/kWh';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = _secondaryValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: entry.mode.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(entry.mode.icon, color: entry.mode.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.mode.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.integer(entry.distance)} '
                    '${distanceUnit.toLowerCase()} • ${Formatters.dayMonthYear(entry.date)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (secondary != null) ...[
                    const SizedBox(height: 2),
                    Text(secondary, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _primaryValue,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: entry.mode.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.mode == EnergyMode.hybrid
                      ? Formatters.currency(entry.totalCost, currencySymbol)
                      : Formatters.currency(entry.totalCost, currencySymbol),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
