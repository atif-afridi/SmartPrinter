import 'dart:ui';

class PrintItem {
  String title;
  Color startColor;
  Color endColor;
  String iconName;

  PrintItem(
      {required this.title,
      required this.startColor,
      required this.endColor,
      required this.iconName});

  // factory MenuItem.fromJson(Map<String, dynamic> json) {
  //   return MenuItem(
  //     title: json['title'],
  //     age: json['age'],
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'title': title,
  //     'age': age,
  //   };
  // }
}
