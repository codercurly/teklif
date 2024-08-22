import 'package:flutter/material.dart';
import 'package:teklif/base/dimension.dart';

class RightSlantClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 0); // Top left point
    path.lineTo(size.width, 0); // Top right point
    path.lineTo(size.width - 20, size.height); // Bottom right point with slant
    path.lineTo(0, size.height); // Bottom left point
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color> colors;

  const GradientContainer({
    Key? key,
    required this.child,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipPath(
        clipper: RightSlantClipper(),
        child: Container(
          width: Dimension.getWidth10(context) * 14,
          height: Dimension.getHeight10(context) * 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.9), // Daha yoğun siyah gölge
                spreadRadius: 8, // Gölgenin yayılma genişliği
                blurRadius: 10, // Gölgenin bulanıklığı
                offset: Offset(4, 6), // Gölgenin konumu
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
