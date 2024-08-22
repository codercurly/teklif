import 'package:flutter/material.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/components/label_container.dart';
import 'package:teklif/components/mysuccess_buton.dart';

class NavBarItems extends StatelessWidget {
  final String label;
  final String buttonText;
  final VoidCallback onButtonTap;

  const NavBarItems({
    Key? key,
    required this.label,
    required this.buttonText,
    required this.onButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimension.getHeight10(context)*7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GradientContainer(
            colors: [
              Colors.grey.shade400,
              Colors.grey.shade300,
              Colors.grey.shade200,
              Colors.grey.shade100
            ],
            child: Center(
              child: CustomText(
                text: label,
                fontSize: Dimension.getFont20(context),
              ),
            ),
          ),
          MySuccessButton(text: buttonText,icon: Icons.add_box,onPressed: onButtonTap)
        ],
      ),
    );
  }
}
