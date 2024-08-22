import 'package:flutter/material.dart';
import 'package:teklif/base/dimension.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final Color textColor;

  SaveButton({
    required this.onPressed,
    required this.text,
    this.icon,
    this.textColor = Colors.white, // Beyaz renk varsayılan olarak
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:Color(0xFFE3F6DA), // Açık yeşil tonu
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shadowColor: Colors.green.shade600,
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.green,
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
