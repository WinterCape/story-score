import 'dart:math';

import 'package:flutter/material.dart';

import 'package:story_score/domain/celebrations/celebration_models.dart';

/// Full-screen confetti overlay rendered via [CustomPainter].
///
/// Spawns 100-150 particles with theme-specific colors, shapes, and
/// movement patterns. Wraps in a [RepaintBoundary] for performance.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    required this.particleTheme,
    this.duration = const Duration(seconds: 3),
    this.onComplete,
  });

  /// Determines particle colors, shapes, and movement direction.
  final ParticleTheme particleTheme;

  /// How long the confetti animation plays.
  final Duration duration;

  /// Called when the animation finishes.
  final VoidCallback? onComplete;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _particles = _generateParticles();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  List<_Particle> _generateParticles() {
    final config = _ParticleConfig.fromTheme(widget.particleTheme);
    final count = 100 + _random.nextInt(51); // 100-150

    return List.generate(count, (_) {
      final color = config.colors[_random.nextInt(config.colors.length)];
      final shape = config.shapes[_random.nextInt(config.shapes.length)];

      return _Particle(
        // Start position: full width, start from top or bottom based on theme
        startX: _random.nextDouble(),
        startY: config.risesUp
            ? 1.0 + _random.nextDouble() * 0.2
            : -_random.nextDouble() * 0.2,
        // Velocity
        velocityX: (_random.nextDouble() - 0.5) * config.horizontalDrift,
        velocityY: config.risesUp
            ? -0.3 - _random.nextDouble() * 0.5
            : 0.2 + _random.nextDouble() * config.fallSpeed,
        // Visual
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 4.0,
        size:
            config.minSize +
            _random.nextDouble() * (config.maxSize - config.minSize),
        color: color,
        shape: shape,
        // Fade out in the last 30% of animation
        fadeStart: 0.7 + _random.nextDouble() * 0.2,
      );
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
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: MediaQuery.sizeOf(context),
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shape types for particles.
enum _ParticleShape { rect, circle, star, hexagon, leaf }

/// Configuration for each particle theme.
class _ParticleConfig {
  final List<Color> colors;
  final List<_ParticleShape> shapes;
  final bool risesUp;
  final double fallSpeed;
  final double horizontalDrift;
  final double minSize;
  final double maxSize;

  const _ParticleConfig({
    required this.colors,
    required this.shapes,
    this.risesUp = false,
    this.fallSpeed = 0.4,
    this.horizontalDrift = 0.3,
    this.minSize = 4.0,
    this.maxSize = 10.0,
  });

  factory _ParticleConfig.fromTheme(ParticleTheme theme) {
    return switch (theme) {
      ParticleTheme.celestialStars => const _ParticleConfig(
        colors: [
          Color(0xFFD4A742), // gold
          Color(0xFFE8C876), // light gold
          Color(0xFFFFFFFF), // white
          Color(0xFFFFF8DC), // cornsilk
        ],
        shapes: [_ParticleShape.star, _ParticleShape.circle],
        fallSpeed: 0.4,
        horizontalDrift: 0.2,
        minSize: 5.0,
        maxSize: 12.0,
      ),
      ParticleTheme.oceanBubbles => const _ParticleConfig(
        colors: [
          Color(0xFF3B82F6), // ocean blue
          Color(0xFF60A5FA), // light blue
          Color(0xFF93C5FD), // lighter blue
          Color(0xFFBFDBFE), // pale blue
        ],
        shapes: [_ParticleShape.circle],
        risesUp: true,
        fallSpeed: 0.3,
        horizontalDrift: 0.15,
        minSize: 4.0,
        maxSize: 14.0,
      ),
      ParticleTheme.emberSparks => const _ParticleConfig(
        colors: [
          Color(0xFFFB923C), // orange
          Color(0xFFEF4444), // red
          Color(0xFFF59E0B), // amber
          Color(0xFFFF6B6B), // coral
        ],
        shapes: [_ParticleShape.circle, _ParticleShape.rect],
        risesUp: true,
        fallSpeed: 0.35,
        horizontalDrift: 0.4,
        minSize: 2.0,
        maxSize: 6.0,
      ),
      ParticleTheme.frostSnowflakes => const _ParticleConfig(
        colors: [
          Color(0xFFFFFFFF), // white
          Color(0xFFE0F2FE), // ice blue
          Color(0xFFF0F9FF), // pale ice
          Color(0xFFBAE6FD), // sky blue
        ],
        shapes: [_ParticleShape.hexagon, _ParticleShape.circle],
        fallSpeed: 0.2,
        horizontalDrift: 0.25,
        minSize: 5.0,
        maxSize: 12.0,
      ),
      ParticleTheme.forestLeaves => const _ParticleConfig(
        colors: [
          Color(0xFF4ADE80), // green
          Color(0xFFF59E0B), // amber
          Color(0xFF86EFAC), // light green
          Color(0xFFD97706), // dark amber
        ],
        shapes: [_ParticleShape.leaf, _ParticleShape.rect],
        fallSpeed: 0.3,
        horizontalDrift: 0.35,
        minSize: 6.0,
        maxSize: 14.0,
      ),
    };
  }
}

/// Individual particle data.
class _Particle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;
  final _ParticleShape shape;
  final double fadeStart;

  const _Particle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.shape,
    required this.fadeStart,
  });

  /// Computes current position at the given animation progress (0..1).
  Offset position(double t, Size canvasSize) {
    final x = (startX + velocityX * t) * canvasSize.width;
    final y = (startY + velocityY * t) * canvasSize.height;
    return Offset(x, y);
  }

  /// Computes current rotation at the given animation progress.
  double currentRotation(double t) => rotation + rotationSpeed * t;

  /// Computes opacity (1.0 until fadeStart, then fades to 0).
  double opacity(double t) {
    if (t < fadeStart) return 1.0;
    return 1.0 - ((t - fadeStart) / (1.0 - fadeStart)).clamp(0.0, 1.0);
  }
}

/// Paints all particles at a given animation progress.
class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final pos = particle.position(progress, size);

      // Skip particles outside the visible area
      if (pos.dx < -20 ||
          pos.dx > size.width + 20 ||
          pos.dy < -20 ||
          pos.dy > size.height + 20) {
        continue;
      }

      final opacity = particle.opacity(progress);
      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(particle.currentRotation(progress));

      switch (particle.shape) {
        case _ParticleShape.rect:
          final half = particle.size / 2;
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: half * 2, height: half),
            paint,
          );
        case _ParticleShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
        case _ParticleShape.star:
          _drawStar(canvas, particle.size / 2, paint);
        case _ParticleShape.hexagon:
          _drawHexagon(canvas, particle.size / 2, paint);
        case _ParticleShape.leaf:
          _drawLeaf(canvas, particle.size / 2, paint);
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    final innerRadius = radius * 0.4;

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * pi / points) - (pi / 2);
      final x = r * cos(angle);
      final y = r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * pi / 3) - (pi / 6);
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLeaf(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    // Simple leaf shape using cubic bezier curves
    path.moveTo(0, -radius);
    path.cubicTo(
      radius * 0.8,
      -radius * 0.5,
      radius * 0.8,
      radius * 0.5,
      0,
      radius,
    );
    path.cubicTo(
      -radius * 0.8,
      radius * 0.5,
      -radius * 0.8,
      -radius * 0.5,
      0,
      -radius,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
