import 'package:flutter/material.dart';

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Top line
    _drawDashedLine(canvas, const Offset(0, 0), Offset(size.width, 0), paint);
    // Right line
    _drawDashedLine(canvas, Offset(size.width, 0), Offset(size.width, size.height), paint);
    // Bottom line
    _drawDashedLine(canvas, Offset(size.width, size.height), Offset(0, size.height), paint);
    // Left line
    _drawDashedLine(canvas, Offset(0, size.height), const Offset(0, 0), paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final double distance = (end - start).distance;
    final int count = (distance / (gap * 2)).floor();
    
    final double dx = (end.dx - start.dx) / distance;
    final double dy = (end.dy - start.dy) / distance;
    
    for (int i = 0; i < count; i++) {
      final double startX = start.dx + dx * i * gap * 2;
      final double startY = start.dy + dy * i * gap * 2;
      final double endX = startX + dx * gap;
      final double endY = startY + dy * gap;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth || oldDelegate.gap != gap;
  }
}
