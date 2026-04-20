import 'package:flutter/material.dart';

class LifeOSLogoPainter extends CustomPainter {
  final Color strokeColor;
  final Color dotColor;

  LifeOSLogoPainter({required this.strokeColor, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    final circlePaint = Paint()
      ..color = strokeColor.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, size.width * 0.375, circlePaint);

    final pathPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.125)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.875, size.height * 0.5);
    canvas.drawPath(path, pathPaint);

    final dotPaint = Paint()..color = dotColor;
    canvas.drawCircle(center, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}