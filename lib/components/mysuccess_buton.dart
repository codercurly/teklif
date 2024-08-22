import 'package:flutter/material.dart';
import 'package:teklif/base/colors.dart';
import 'package:teklif/base/dimension.dart';

// MySuccessButton sınıfı
class MySuccessButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color textColor;

  MySuccessButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.textColor = Colors.white, // Varsayılan renk beyaz
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(
          vertical: Dimension.getHeight10(context),
          horizontal: Dimension.getWidth15(context),
        )),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimension.getRadius15(context)),
        )),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.greentree,
              AppColors.greentwo,
              AppColors.greenone,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Dimension.getRadius15(context)),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            vertical: Dimension.getHeight10(context),
            horizontal: Dimension.getWidth15(context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: Dimension.getFont18(context),
                ),
              ),
              SizedBox(width: 8), // Icon ile metin arasında biraz boşluk bırakmak için
              Icon(
                icon,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );



  }
}
