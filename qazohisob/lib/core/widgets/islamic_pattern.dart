import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Subtle tiled eight-point star (khatam) pattern used as a background
/// ornament on hero cards.
class IslamicPattern extends StatelessWidget {
  const IslamicPattern({
    super.key,
    this.color,
    this.tile = 44,
    this.opacity = 0.09,
  });

  final Color? color;
  final double tile;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _StarPatternPainter(
          color: (color ?? Colors.white).withValues(alpha: opacity),
          tile: tile,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _StarPatternPainter extends CustomPainter {
  _StarPatternPainter({required this.color, required this.tile});

  final Color color;
  final double tile;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final r = tile * 0.36;
    for (double y = 0; y < size.height + tile; y += tile) {
      for (double x = 0; x < size.width + tile; x += tile) {
        final c = Offset(x, y);
        canvas.drawPath(_star(c, r), paint);
        canvas.drawCircle(c, r * 0.32, paint);
      }
    }
  }

  /// Two overlapping squares form the eight-point star.
  Path _star(Offset c, double r) {
    final path = Path();
    for (var s = 0; s < 2; s++) {
      final start = s * math.pi / 4;
      for (var i = 0; i < 4; i++) {
        final a = start + i * math.pi / 2;
        final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
    }
    return path;
  }

  @override
  bool shouldRepaint(_StarPatternPainter old) =>
      old.color != color || old.tile != tile;
}

/// App mark: crescent inside a gold ring.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A6B53), Color(0xFF103D32)],
        ),
        border: Border.all(color: const Color(0xFFC8A45D), width: size * 0.035),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF075B46).withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Icon(
        Icons.nightlight_round,
        color: const Color(0xFFC8A45D),
        size: size * 0.48,
      ),
    );
  }
}
