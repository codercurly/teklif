import 'package:flutter/material.dart';


class Dimension {
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getPageView(BuildContext context) =>
      getScreenHeight(context) / 2.64;

  static double getPageViewContainer(BuildContext context) =>
      getScreenHeight(context) / 3.90;

  static double getPageViewTextContainer(BuildContext context) =>
      getScreenHeight(context) / 6.2;

  static double getforTablet(BuildContext context) =>
      getScreenHeight(context) / 5;

  static double getSuggestionImg(BuildContext context) =>
      getScreenHeight(context) / 4.4;

  static double getHeight10(BuildContext context) =>
      getScreenHeight(context) / 84.4;

  static double getHeight110(BuildContext context) =>
      getScreenHeight(context) / 640;

  static double getHeight20(BuildContext context) =>
      getScreenHeight(context) / 42.2;

  static double getHeight15(BuildContext context) =>
      getScreenHeight(context) / 56.27;

  static double getHeight30(BuildContext context) =>
      getScreenHeight(context) / 28.13;

  static double getHeight35(BuildContext context) =>
      getScreenHeight(context) / 24.13;

  static double getHeight45(BuildContext context) =>
      getScreenHeight(context) / 18.76;

  static double getHeight100(BuildContext context) =>
      getScreenHeight(context) / 9;

// Genişlikler için de aynı şekilde devam edebilirsiniz.
  static double getWidth10(BuildContext context) =>
      getScreenHeight(context) / 84.4;

  static double getWidth20(BuildContext context) =>
      getScreenHeight(context) / 42.2;

  static double getWidth15(BuildContext context) =>
      getScreenHeight(context) / 56.27;

  static double getWidth30(BuildContext context) =>
      getScreenHeight(context) / 28.13;

  static double getWidth50(BuildContext context) =>
      getScreenWidth(context) / 3.13;

  static double getFont17(BuildContext context) =>
      getScreenHeight(context) / 50.2;

  static double getFont20(BuildContext context) =>
      getScreenHeight(context) / 45.2;

  static double getFont23(BuildContext context) =>
      getScreenHeight(context) / 38.2;


  static double getFont26(BuildContext context) =>
      getScreenHeight(context) / 30.46;

  static double getFont18(BuildContext context) =>
      getScreenHeight(context) / 51.6;
  static double getFont15(BuildContext context) =>
      getScreenHeight(context) / 55.6;


  static double getFont12(BuildContext context) =>
      getScreenHeight(context) / 60;

  static double getRadius20(BuildContext context) =>
      getScreenHeight(context) / 42.2;

  static double getRadius30(BuildContext context) =>
      getScreenHeight(context) / 28.13;
  static double getRadius32(BuildContext context) =>
      getScreenHeight(context) / 25.13;

  static double getRadius15(BuildContext context) =>
      getScreenHeight(context) / 56.27;

  static double getRadius50(BuildContext context) =>
      getScreenHeight(context) / 20.27;

  static double getIconSize24(BuildContext context) =>
      getScreenHeight(context) / 35.17;

  static double getIconSize31(BuildContext context) =>
      getScreenHeight(context) / 22.57;

  static double getIconSize16(BuildContext context) =>
      getScreenHeight(context) / 40.15;

  static double getLstViewImgSize(BuildContext context) =>
      getScreenWidth(context) / 3.25;

  static double getLstViewTxtSize(BuildContext context) =>
      getScreenWidth(context) / 3.9;

  static double getPopularFoodDetailImg(BuildContext context) =>
      getScreenHeight(context) / 2.90;

  static double getBottomNavHeight(BuildContext context) =>
      getScreenHeight(context) / 6.80;
}