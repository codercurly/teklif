import 'package:flutter/material.dart';
import 'package:teklif/model/bubble_model.dart';

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var bubble in bubbles) {
      paint.color = bubble.color.withOpacity(0.3); // Renklerin saydamlığını artırın
      canvas.drawCircle(
          Offset(bubble.x * size.width, bubble.y * size.height),
          bubble.radius,
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
