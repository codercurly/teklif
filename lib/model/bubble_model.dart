import 'package:flutter/animation.dart';

class Bubble {
  double x;
  double y;
  double radius;
  Color color;
  double growthRate; // Yeni eklenen büyüme hızı

  Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.growthRate,
  });
}
