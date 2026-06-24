import 'package:flutter/material.dart';

/// Branded app logo used on splash, onboarding, and about screens.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 64,
    this.borderRadius,
    this.elevation,
  });

  static const assetPath = 'assets/images/app_icon.png';

  final double size;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? elevation;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.22);
    final image = ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );

    if (elevation == null) return image;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevation,
      ),
      child: image,
    );
  }
}
