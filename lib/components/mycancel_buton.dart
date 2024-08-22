import 'package:flutter/material.dart';
import 'package:teklif/base/dimension.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final Color textColor;

  CancelButton({
    required this.onPressed,
    required this.text,
    this.icon,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFCF1F1), // Açık kırmızı tonu
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shadowColor: Colors.red.shade600,
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.red,
              size: Dimension.getIconSize24(context),
            ),
            SizedBox(width: 8), // İkon ile yazı arasında boşluk
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: Dimension.getFont18(context),
            ),
          ),
        ],
      ),
    );
  }
}