import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// Staggered Entrance animation that smoothly slides and fades in content
class StaggeredEntrance extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delayStep;
  final Duration duration;
  final double offsetDistance;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.delayStep = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 480),
    this.offsetDistance = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDelay = delayStep * math.min(index, 12);

    return TweenAnimationBuilder<double>(
      duration: duration + effectiveDelay,
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, progress, child) {
        // Calculate delayed progress
        final totalMs = (duration + effectiveDelay).inMilliseconds;
        final delayMs = effectiveDelay.inMilliseconds;
        final activeFraction = totalMs == 0 ? 1.0 : delayMs / totalMs;

        double localProgress = 0.0;
        if (progress > activeFraction) {
          localProgress = ((progress - activeFraction) / (1.0 - activeFraction)).clamp(0.0, 1.0);
        }

        final curvedProgress = Curves.easeOutCubic.transform(localProgress);
        final translateY = offsetDistance * (1.0 - curvedProgress);

        return Opacity(
          opacity: curvedProgress,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Smooth progress bar that animates value changes with custom gradient & glow
class SmoothProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final bool glow;

  const SmoothProgressBar({
    super.key,
    required this.value,
    this.height = 7.0,
    this.gradientColors,
    this.backgroundColor,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final colors = gradientColors ?? const [AppTheme.primaryBlue, AppTheme.primaryPurple];
    final effectiveBg = backgroundColor ?? AppTheme.surfaceLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: effectiveBg,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.0, end: clamped),
            builder: (context, animVal, _) {
              return FractionallySizedBox(
                widthFactor: animVal.clamp(0.01, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    boxShadow: glow
                        ? [
                            BoxShadow(
                              color: colors.first.withOpacity(0.55),
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            )
                          ]
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Animated Breathing / Gentle Wiggle icon for Flame & Crown
class AnimatedPulseIcon extends StatefulWidget {
  final Widget child;
  final bool isWiggle;

  const AnimatedPulseIcon({
    super.key,
    required this.child,
    this.isWiggle = false,
  });

  @override
  State<AnimatedPulseIcon> createState() => _AnimatedPulseIconState();
}

class _AnimatedPulseIconState extends State<AnimatedPulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isWiggle ? 2600 : 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (widget.isWiggle) {
          // Gentle crown tilt
          final angle = math.sin(_controller.value * 2 * math.pi) * 0.12;
          return Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: 1.0 + (_controller.value * 0.08),
              child: child,
            ),
          );
        } else {
          // Flame pulse
          final scale = 1.0 + (_controller.value * 0.15);
          final angle = math.sin(_controller.value * math.pi) * 0.08;
          return Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: angle,
              child: child,
            ),
          );
        }
      },
      child: widget.child,
    );
  }
}

/// Animated Number Counter for XP, Streaks, and Balances
class AnimatedNumberText extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final TextStyle style;
  final bool isCurrency;

  const AnimatedNumberText({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    required this.style,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: value),
      builder: (context, animVal, _) {
        String formatted;
        if (isCurrency) {
          final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
          formatted = format.format(animVal);
        } else {
          formatted = '$prefix${animVal.round()}$suffix';
        }
        return Text(formatted, style: style);
      },
    );
  }
}

