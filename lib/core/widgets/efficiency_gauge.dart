import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fuel_efficiency_app/core/utils/formatters.dart';
import 'package:fuel_efficiency_app/core/values/app_colors.dart';

/// Animated circular gauge showing the percentage of claimed efficiency the
/// driver actually achieves.
class EfficiencyGauge extends StatelessWidget {
  const EfficiencyGauge({
    super.key,
    required this.percent,
    this.size = 220,
    this.caption = 'of claimed efficiency',
  });

  /// Percentage value (0-150ish). 100 == matching the manufacturer claim.
  final double percent;
  final double size;
  final String caption;

  Color get _color {
    if (percent >= 98) return AppColors.positive;
    if (percent >= 85) return AppColors.warning;
    return AppColors.negative;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = (percent / 100).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: clamped),
      builder: (context, animated, _) {
        return SizedBox(
          height: size,
          width: size,
          child: CustomPaint(
            painter: _GaugePainter(
              progress: animated,
              color: _color,
              trackColor: theme.dividerColor,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("You're getting", style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.percent(percent),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: _color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      caption,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  // 3/4 circle gauge (270 degrees) starting from bottom-left.
  static const double _startAngle = math.pi * 0.75;
  static const double _sweepAngle = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.09;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.width - strokeWidth) / 2,
    );

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + _sweepAngle,
        colors: [color.withValues(alpha: 0.6), color],
      ).createShader(rect);

    canvas.drawArc(rect, _startAngle, _sweepAngle, false, trackPaint);
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
