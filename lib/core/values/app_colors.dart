import 'package:flutter/material.dart';

/// Central color palette for the application. Mirrors the design system used in
/// the reference mock-ups (green primary, blue for charge, purple for hybrid).
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF12B886);
  static const Color primaryDark = Color(0xFF0CA678);
  static const Color primaryLight = Color(0xFF40C997);
  static const Color primarySurface = Color(0xFFE7F8F1);

  // Energy modes
  static const Color fuel = Color(0xFF12B886);
  static const Color fuelSurface = Color(0xFFE7F8F1);
  static const Color charge = Color(0xFF3B82F6);
  static const Color chargeSurface = Color(0xFFE7F0FE);
  static const Color hybrid = Color(0xFF8B5CF6);
  static const Color hybridSurface = Color(0xFFF1EBFD);

  // Semantic
  static const Color positive = Color(0xFF12B886);
  static const Color negative = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Light surfaces
  static const Color background = Color(0xFFF6F8FA);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color divider = Color(0xFFE7ECF1);

  // Dark surfaces
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF151E2E);
  static const Color darkSurfaceAlt = Color(0xFF1E2A3D);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkDivider = Color(0xFF24324A);
}
