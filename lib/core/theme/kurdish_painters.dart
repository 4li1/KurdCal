import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Draws a 21-ray Kurdish Sun (Roj) symbol.
/// Used as logo on login page, watermark, and nav icon.
class KurdishSunPainter extends CustomPainter {
  final Color color;
  final Color? glowColor;
  final double glowRadius;

  KurdishSunPainter({
    this.color = const Color(0xFFFFD700),
    this.glowColor,
    this.glowRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Outer glow
    if (glowColor != null && glowRadius > 0) {
      final glowPaint = Paint()
        ..color = glowColor!
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);
      canvas.drawCircle(center, radius * 0.45, glowPaint);
    }

    // Central circle
    final centerRadius = radius * 0.28;
    final centerPaint = Paint()..color = color;
    canvas.drawCircle(center, centerRadius, centerPaint);

    // 21 rays
    const rayCount = 21;
    final rayPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi / rayCount) * i - math.pi / 2;
      final nextAngle = angle + (2 * math.pi / rayCount);
      final midAngle = (angle + nextAngle) / 2;

      // Ray tip (outer point)
      final tipX = center.dx + radius * 0.92 * math.cos(midAngle);
      final tipY = center.dy + radius * 0.92 * math.sin(midAngle);

      // Ray base points (on the circle edge)
      final baseSpread = (2 * math.pi / rayCount) * 0.28;
      final base1X = center.dx + centerRadius * 1.15 * math.cos(midAngle - baseSpread);
      final base1Y = center.dy + centerRadius * 1.15 * math.sin(midAngle - baseSpread);
      final base2X = center.dx + centerRadius * 1.15 * math.cos(midAngle + baseSpread);
      final base2Y = center.dy + centerRadius * 1.15 * math.sin(midAngle + baseSpread);

      final path = Path()
        ..moveTo(base1X, base1Y)
        ..lineTo(tipX, tipY)
        ..lineTo(base2X, base2Y)
        ..close();

      canvas.drawPath(path, rayPaint);
    }

    // Inner ring for depth
    final innerRingPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03;
    canvas.drawCircle(center, centerRadius * 0.65, innerRingPaint);
  }

  @override
  bool shouldRepaint(covariant KurdishSunPainter old) =>
      old.color != color || old.glowColor != glowColor || old.glowRadius != glowRadius;
}

/// A widget that renders the 21-ray Kurdish sun at a given size.
class KurdishSunWidget extends StatelessWidget {
  final double size;
  final Color color;
  final Color? glowColor;
  final double glowRadius;

  const KurdishSunWidget({
    super.key,
    this.size = 100,
    this.color = const Color(0xFFFFD700),
    this.glowColor,
    this.glowRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: KurdishSunPainter(
        color: color,
        glowColor: glowColor,
        glowRadius: glowRadius,
      ),
    );
  }
}

/// Draws a geometric Kurdish Kilim border pattern.
/// Renders repeating diamond/chevron motifs as a horizontal strip.
class KilimBorderPainter extends CustomPainter {
  final Color color;
  final double patternHeight;
  final bool flipVertical;

  KilimBorderPainter({
    this.color = const Color(0xFFFFD700),
    this.patternHeight = 40,
    this.flipVertical = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (flipVertical) {
      canvas.save();
      canvas.translate(0, size.height);
      canvas.scale(1, -1);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final diamondSize = patternHeight * 0.6;
    final spacing = diamondSize * 1.4;
    final count = (size.width / spacing).ceil() + 1;
    final yCenter = patternHeight / 2;

    // Row of diamonds
    for (int i = 0; i < count; i++) {
      final cx = i * spacing + spacing / 2;
      final diamond = Path()
        ..moveTo(cx, yCenter - diamondSize / 2)
        ..lineTo(cx + diamondSize / 2, yCenter)
        ..lineTo(cx, yCenter + diamondSize / 2)
        ..lineTo(cx - diamondSize / 2, yCenter)
        ..close();
      canvas.drawPath(diamond, fillPaint);
      canvas.drawPath(diamond, paint);

      // Inner diamond
      final innerSize = diamondSize * 0.4;
      final inner = Path()
        ..moveTo(cx, yCenter - innerSize / 2)
        ..lineTo(cx + innerSize / 2, yCenter)
        ..lineTo(cx, yCenter + innerSize / 2)
        ..lineTo(cx - innerSize / 2, yCenter)
        ..close();
      canvas.drawPath(inner, paint);
    }

    // Top & bottom border lines
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, 2), Offset(size.width, 2), linePaint);
    canvas.drawLine(
      Offset(0, patternHeight - 2),
      Offset(size.width, patternHeight - 2),
      linePaint,
    );

    // Chevron accents between diamonds
    final chevronPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (int i = 0; i < count; i++) {
      final cx = i * spacing;
      final chevSize = diamondSize * 0.2;
      // Small V shapes
      canvas.drawLine(
        Offset(cx - chevSize, yCenter - chevSize),
        Offset(cx, yCenter),
        chevronPaint,
      );
      canvas.drawLine(
        Offset(cx + chevSize, yCenter - chevSize),
        Offset(cx, yCenter),
        chevronPaint,
      );
    }

    if (flipVertical) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant KilimBorderPainter old) =>
      old.color != color || old.patternHeight != patternHeight;
}

/// A widget that renders Kilim border at full width.
class KilimBorderWidget extends StatelessWidget {
  final double height;
  final Color color;
  final double opacity;
  final bool flipVertical;

  const KilimBorderWidget({
    super.key,
    this.height = 40,
    this.color = const Color(0xFFFFD700),
    this.opacity = 0.06,
    this.flipVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(
          painter: KilimBorderPainter(
            color: color,
            patternHeight: height,
            flipVertical: flipVertical,
          ),
        ),
      ),
    );
  }
}

/// Draws a small Kurdish flag color strip (Red, White, Green, Gold) vertically.
class FlagStripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripHeight = size.height / 4;
    final colors = AppColors.flagStripColors;

    for (int i = 0; i < 4; i++) {
      final rect = Rect.fromLTWH(0, i * stripHeight, size.width, stripHeight);
      canvas.drawRect(rect, Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A widget that renders the Kurdish flag vertical strip.
class FlagStripWidget extends StatelessWidget {
  final double width;

  const FlagStripWidget({super.key, this.width = 5});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: FlagStripPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}
