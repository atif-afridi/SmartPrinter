import 'package:flutter/widgets.dart';

class AppColor {
  AppColor._();
  static const Color blueColor = Color(0xFF2F39C5);
  static const Color lightRedColor = Color(0xFFdc616f);
  static const Color lightBlueColor = Color(0xFF18bdd3);
  static const Color lightGreyColor = Color(0xFF7c8080);
  static const Color skyBlue = Color.fromRGBO(134, 240, 255, 1);
  static const Color skyBlueText = Color(0xFF16bed3);
  static const Color menuColor = Color(0xFF17BDD3);
  static const Color adColor = Color(0xFF17BDD3);
  static const Color borderColor = Color(0xFFD9D9D9);
  static const Color lightBlueBg = Color(0xFFf9ffff);
  // static const Color subscriptionBG = Color(0xFFf9ffff);

  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [
      Color(0xffff9a9e),
      Color(0xfffad0c4),
      Color(0xfffad0c4),
    ],
  );
}
