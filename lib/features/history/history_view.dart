import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/core/values/app_colors.dart';
import 'package:fuel_efficiency_app/core/widgets/empty_state.dart';
import 'package:fuel_efficiency_app/core/widgets/loading_view.dart';
import 'package:fuel_efficiency_app/features/history/history_controller.dart';
import 'package:fuel_efficiency_app/features/shared/widgets/entry_tile.dart';

class HistoryTab extends GetView<HistoryController> {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Obx(() {
        if (!controller.isHydrated.value) return const LoadingView();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'History',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  _FilterDropdown(controller: controller),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${controller.entryCount} entries',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: controller.groups.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'No entries found',
                      message:
                          'Log a fuel, charge or hybrid entry to see it here.',
                      actionLabel: controller.hasVehicle ? 'Add entry' : null,
                      onAction: controller.hasVehicle
                          ? controller.addEntry
                          : null,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        for (final group in controller.groups) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              group.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          ...group.entries.map(
                            (entry) => EntryTile(
                              entry: entry,
                              currencySymbol: controller.currencySymbol.value,
                              distanceUnit: controller.distanceUnit.value,
                              volumeUnit: controller.volumeUnit.value,
                              onTap: () => controller.openEntry(entry),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({required this.controller});
  final HistoryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: controller.filterIndex.value,
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: theme.textTheme.bodyMedium,
          items: [
            for (var i = 0; i < HistoryController.filters.length; i++)
              DropdownMenuItem(
                value: i,
                child: Text(HistoryController.filters[i].label),
              ),
          ],
          onChanged: (value) {
            if (value != null) controller.setFilter(value);
          },
        ),
      ),
    );
  }
}
