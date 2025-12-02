import 'package:flutter/material.dart';

class SylfLogo extends StatelessWidget {
  final double size;
  final Color color;

  const SylfLogo({
    super.key,
    this.size = 80,
    this.color = const Color(0xFF4DB8A8),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 3, size),
      painter: SylfLogoPainter(color: color),
    );
  }
}

class SylfLogoPainter extends CustomPainter {
  final Color color;

  SylfLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Simple geometric logo: blocks representing "SYLF"
    final blockSize = size.height * 0.3;
    final spacing = size.width * 0.08;
    final startY = size.height * 0.35;

    // S - zigzag pattern
    _drawSBlock(canvas, paint, 0, startY, blockSize);

    // Y - two lines meeting at angle
    _drawYBlock(canvas, paint, blockSize + spacing, startY, blockSize);

    // L - simple L shape
    _drawLBlock(canvas, paint, (blockSize + spacing) * 2, startY, blockSize);

    // F - simple F shape
    _drawFBlock(
        canvas, paint, (blockSize + spacing) * 3, startY, blockSize);
  }

  void _drawSBlock(Canvas canvas, Paint paint, double x, double y,
      double size) {
    // Draw S as connected lines
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x + size * 0.3, y + size * 0.2),
          radius: size * 0.15),
      0,
      3.14,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x + size * 0.3, y + size * 0.6),
          radius: size * 0.15),
      3.14,
      3.14,
      false,
      paint,
    );
  }

  void _drawYBlock(Canvas canvas, Paint paint, double x, double y,
      double size) {
    // Draw Y as two lines meeting
    canvas.drawLine(
      Offset(x, y),
      Offset(x + size * 0.3, y + size * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(x + size * 0.6, y),
      Offset(x + size * 0.3, y + size * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(x + size * 0.3, y + size * 0.5),
      Offset(x + size * 0.3, y + size),
      paint,
    );
  }

  void _drawLBlock(Canvas canvas, Paint paint, double x, double y,
      double size) {
    // Draw L as simple L shape
    canvas.drawLine(
      Offset(x + size * 0.2, y),
      Offset(x + size * 0.2, y + size),
      paint,
    );
    canvas.drawLine(
      Offset(x + size * 0.2, y + size),
      Offset(x + size * 0.6, y + size),
      paint,
    );
  }

  void _drawFBlock(Canvas canvas, Paint paint, double x, double y,
      double size) {
    // Draw F as inverted L with extra line
    canvas.drawLine(
      Offset(x + size * 0.2, y),
      Offset(x + size * 0.2, y + size),
      paint,
    );
    canvas.drawLine(
      Offset(x + size * 0.2, y),
      Offset(x + size * 0.6, y),
      paint,
    );
    canvas.drawLine(
      Offset(x + size * 0.2, y + size * 0.5),
      Offset(x + size * 0.5, y + size * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(SylfLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
