import 'dart:math';
import 'package:flutter/material.dart';
import 'package:teklif/animation/animation_bubble.dart';
import 'package:teklif/animation/wave.dart';
import 'package:teklif/base/colors.dart';

import 'package:teklif/model/bubble_model.dart';
import 'package:teklif/pages/forbusiness/manager_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late List<Bubble> _bubbles;
  final Random _random = Random();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _bubbles = _generateBubbles();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(() {
      setState(() {
        _updateBubbles();
      });
    });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Bubble> _generateBubbles() {
    final List<Color> colors = [
      Colors.pink,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.blue,
    ];

    final bubbles = <Bubble>[];
    for (var i = 0; i < 8; i++) {
      final color = colors[_random.nextInt(colors.length)];
      double x = _random.nextDouble();
      double y = _random.nextDouble();

      // Metin alanının kapladığı dikdörtgenin dışına baloncukları yerleştirin
      if (x > 0.3 && x < 0.7 && y > 0.3 && y < 0.7) {
        y = y < 0.5 ? 0.3 : 0.7;
      }

      bubbles.add(Bubble(
        x: x,
        y: y,
        radius: 20.0 + _random.nextInt(40),
        color: color.withOpacity(0.5),
        growthRate: (_random.nextDouble() * 2) - 1,
      ));
    }
    return bubbles;
  }

  void _updateBubbles() {
    for (var bubble in _bubbles) {
      bubble.radius += bubble.growthRate;
      if (bubble.radius <= 10 || bubble.radius >= 60) {
        bubble.growthRate *= -1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateBubbles();

    return Stack(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.orangetree, AppColors.orangetwo, AppColors.orangeone],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hoşgeldiniz',
                style: TextStyle(
                  fontSize: 27,
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Text(
                'Teklif formunuzu hazırlayın ve çıktı alın',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,

              ),
              SizedBox(height: 30),
          GestureDetector(
              onTap: () {

                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    ManagerPage()));

              },
              child: Text("Giriş")),
        ],
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: BubblePainter(bubbles: _bubbles),
          ),
        ),
      ],
    );
  }
}
