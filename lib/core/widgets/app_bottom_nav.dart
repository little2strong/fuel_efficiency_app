import 'package:flutter/material.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';

class BottomNavItem {
  const BottomNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Custom bottom navigation with a raised center "Add" action button, matching
/// the reference design (Home · Add · History · Analytics · More).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  /// Index over the 4 real tabs (Home, History, Analytics, More).
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  static const _left = [
    BottomNavItem(icon: Icons.home_rounded, label: 'Home'),
    BottomNavItem(icon: Icons.receipt_long_rounded, label: 'History'),
  ];
  static const _right = [
    BottomNavItem(icon: Icons.bar_chart_rounded, label: 'Analytics'),
    BottomNavItem(icon: Icons.grid_view_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navButton(theme, _left[0], 0),
              _navButton(theme, _left[1], 1),
              _addButton(),
              _navButton(theme, _right[0], 2),
              _navButton(theme, _right[1], 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(ThemeData theme, BottomNavItem item, int index) {
    final selected = currentIndex == index;
    final color = selected ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: InkResponse(
        onTap: () => onTabSelected(index),
        radius: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onAddPressed,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
