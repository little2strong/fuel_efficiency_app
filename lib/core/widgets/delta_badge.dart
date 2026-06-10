import 'package:flutter/material.dart';
import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';

/// Small pill showing a signed percentage change with an up/down arrow.
class DeltaBadge extends StatelessWidget {
  const DeltaBadge({super.key, required this.value, this.invertColors = false});

  /// The percentage value (already computed, e.g. +6.3 or -9.7).
  final double value;

  /// When true, a negative value is "good" (e.g. lower cost). Defaults to
  /// treating positive as good.
  final bool invertColors;

  @override
  Widget build(BuildContext context) {
    final isGood = invertColors ? value <= 0 : value >= 0;
    final color = isGood ? AppColors.positive : AppColors.negative;
    final isUp = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            Formatters.signedPercent(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
