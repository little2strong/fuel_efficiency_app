import 'package:flutter/material.dart';

/// A soft, rounded surface container used as the base for most cards.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.border,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final BoxBorder? border;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(18);
    return Material(
      color: gradient != null
          ? Colors.transparent
          : (color ?? theme.cardTheme.color),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: gradient != null ? null : (color ?? theme.cardTheme.color),
            gradient: gradient,
            borderRadius: radius,
            border: border ?? Border.all(color: theme.dividerColor),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
