// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:printer_app/utils/colors.dart';
import 'print_help_center_detail.dart';
import 'subscription_widget.dart';

class PrintHelpCenter extends StatelessWidget {
  final List<String> helpItems = [
    "Review the instruction before proceeding",
    "Info About Mobile Print",
    "How to use App for Printing?",
    "How Can I Connect with My Printer?",
    "Help",
    "Pro Support"
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // appbar
            Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 15.0, bottom: 10.0, top: 10.0),
              child: Row(
                children: [
                  // back button
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 40),
                      child: Text(
                        textAlign: TextAlign.center,
                        "Preview",
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            // fontWeight: FontWeight.w900,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: SvgPicture.asset("icons/diamond_icon.svg",
                          semanticsLabel: 'A red up arrow'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: helpItems.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal:
                            16.0), // optional padding around the ListTile
                    decoration: BoxDecoration(
                      color:
                          AppColor.menuColor, // Set the background color here
                      borderRadius:
                          BorderRadius.circular(10.0), // Rounded corners
                    ),
                    child: ListTile(
                      leading: SvgPicture.asset(
                        helpItems[index] == "Pro Support"
                            ? "icons/diamond_icon.svg"
                            : "icons/question_mark_icon.svg",
                        semanticsLabel: 'A red up arrow',
                        colorFilter:
                            ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ), // Left icon
                      title: Text(
                        helpItems[index],
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                        ),
                      ),
                      trailing: SvgPicture.asset("icons/next_arrow_icon.svg",
                          semanticsLabel: 'A red up arrow'), // Right arrow
                      onTap: () {
                        var pageToOpen = helpItems[index] == "Pro Support"
                            ? MaterialPageRoute(
                                builder: (context) => SubscriptionPage(),
                              )
                            : MaterialPageRoute(
                                builder: (context) =>
                                    HelpCenterDetail(title: helpItems[index]),
                              );

                        Navigator.push(
                            context,
                            // if 'Help' please open email app
                            // if 'Pro Support' open full screen dialog
                            pageToOpen);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
