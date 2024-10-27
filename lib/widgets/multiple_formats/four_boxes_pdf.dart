import 'package:flutter/material.dart';

class FourBoxesWidget extends StatelessWidget {
  final double scaleFactor;

  FourBoxesWidget({this.scaleFactor = 1.0});

  var widthPercentage = 0.45;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBox(screenWidth * widthPercentage), // 20% of the screen width
            SizedBox(
                width: screenWidth * 0.05), // 5% of the screen width as spacing
            _buildBox(screenWidth * widthPercentage),
          ],
        ),
        SizedBox(height: 10 * scaleFactor),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBox(screenWidth * widthPercentage),
            SizedBox(width: screenWidth * 0.05),
            _buildBox(screenWidth * widthPercentage),
          ],
        ),
      ],
    );
  }

  Widget _buildBox(double width) {
    return Container(
      width: width,
      height: 30 * scaleFactor,
      color: Colors.blue,
      child: Center(child: Text("Box", style: TextStyle(color: Colors.white))),
    );
  }
}
