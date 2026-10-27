import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ConfettiOverlay {
  static void trigger(
    BuildContext context, {
    Offset? origin,
    String? toastMessage,
    int particleCount = 36,
  }) {
    HapticFeedback.lightImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ConfettiBurstWidget(
        origin: origin ?? Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height * 0.35,
        ),
        toastMessage: toastMessage,
        particleCount: particleCount,
        onFinished: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _ConfettiBurstWidget extends StatefulWidget {
  final Offset origin;
  final String? toastMessage;
  final int particleCount;
  final VoidCallback onFinished;

  const _ConfettiBurstWidget({
    required this.origin,
    this.toastMessage,
    required this.particleCount,
    required this.onFinished,
  });

  @override
  State<_ConfettiBurstWidget> createState() => _ConfettiBurstWidgetState();
}

class _ConfettiBurstWidgetState extends State<_ConfettiBurstWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random();

  final List<Color> _colors = const [
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
    Color(0xFFFB923C),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFFFB923C),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _particles = List.generate(widget.particleCount, (index) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 120 + _random.nextDouble() * 240;
      final size = 7.0 + _random.nextDouble() * 7.0;
      final color = _colors[index % _colors.length];
      final rotation = _random.nextDouble() * math.pi;
      final rotationSpeed = (_random.nextDouble() - 0.5) * 8;

      return _Particle(
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: color,
        size: size,
        rotation: rotation,
        rotationSpeed: rotationSpeed,
      );
    });

    _controller.forward().then((_) {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  origin: widget.origin,
                  progress: _controller.value,
                  particles: _particles,
                ),
              );
            },
          ),
          if (widget.toastMessage != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.textPrimary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.toastMessage!,
                          style: const TextStyle(
                            color: Color(0xFF09090B),
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Particle {
  final Offset velocity;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;

  _Particle({
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final Offset origin;
  final double progress;
  final List<_Particle> particles;

  _ConfettiPainter({
    required this.origin,
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Gravity simulation
    final gravity = 280.0 * progress * progress;

    for (final p in particles) {
      final dx = origin.dx + p.velocity.dx * progress;
      final dy = origin.dy + (p.velocity.dy * progress) + gravity;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.rotation + p.rotationSpeed * progress);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

