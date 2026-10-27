import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConcentricRings extends StatelessWidget {
  final double habitProgress;
  final double big3Progress;
  final double taskProgress;
  final double size;

  const ConcentricRings({
    super.key,
    required this.habitProgress,
    required this.big3Progress,
    required this.taskProgress,
    this.size = 145,
  });

  @override
  Widget build(BuildContext context) {
    final overallAvg = (habitProgress + big3Progress + taskProgress) / 3.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, anim, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _RingsPainter(
                  habitProgress: habitProgress * anim,
                  big3Progress: big3Progress * anim,
                  taskProgress: taskProgress * anim,
                ),
              );
            },
          ),
          // Center Activity Emblem
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                overallAvg >= 1.0 ? '⭐' : '🔥',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 2),
              Text(
                '${(overallAvg * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFAFAFA),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double habitProgress;
  final double big3Progress;
  final double taskProgress;

  _RingsPainter({
    required this.habitProgress,
    required this.big3Progress,
    required this.taskProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.088;

    final rings = [
      _RingData(
        radius: size.width * 0.43,
        progress: habitProgress.clamp(0.0, 1.0),
        color: const Color(0xFF14B8A6),
        gradientEnd: const Color(0xFF10B981),
      ),
      _RingData(
        radius: size.width * 0.31,
        progress: big3Progress.clamp(0.0, 1.0),
        color: const Color(0xFFEF4444),
        gradientEnd: const Color(0xFFEF4444),
      ),
      _RingData(
        radius: size.width * 0.19,
        progress: taskProgress.clamp(0.0, 1.0),
        color: const Color(0xFFFB923C),
        gradientEnd: const Color(0xFFFB923C),
      ),
    ];

    for (final ring in rings) {
      // 1. Background Track
      final trackPaint = Paint()
        ..color = ring.color.withOpacity(0.13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(center, ring.radius, trackPaint);

      // 2. Glowing Active Progress Arc with rounded caps
      if (ring.progress > 0) {
        final activePaint = Paint()
          ..color = ring.color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

        // Subtle ambient neon blur glow under the ring
        final glowPaint = Paint()
          ..color = ring.color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth + 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

        final sweepAngle = 2 * math.pi * ring.progress;
        final rect = Rect.fromCircle(center: center, radius: ring.radius);

        canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);
        canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) {
    return oldDelegate.habitProgress != habitProgress ||
        oldDelegate.big3Progress != big3Progress ||
        oldDelegate.taskProgress != taskProgress;
  }
}

class _RingData {
  final double radius;
  final double progress;
  final Color color;
  final Color gradientEnd;

  _RingData({
    required this.radius,
    required this.progress,
    required this.color,
    required this.gradientEnd,
  });
}

