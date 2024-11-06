// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:printer_app/utils/colors.dart';
import 'print_help_center_detail.dart';
import 'subscription_widget.dart';

class SettingsWidget extends StatelessWidget {
  final List<String> helpItems = [
    "Printer Compatible List",
    "Change Language",
    "Manage Subscription",
    "How To Connect",
    "General",
    "Report an issue",
    "Pro Support",
    "Send Love",
    "Terms of Use",
    "Privacy Policy",
    "Share App",
    "More Apps",
  ];

  SettingsWidget({super.key});

  // Helper function to get the icon based on the item text
  String getIconForItem(String item) {
    switch (item) {
      case "Printer Compatible List":
        return "icons/settings_printer.svg";
      case "Change Language":
        return "icons/settings_language.svg";
      case "Manage Subscription":
        return "icons/settings_subscription.svg";
      case "How To Connect":
        return "icons/settings_how_to.svg";
      case "Report an issue":
        return "icons/settings_report.svg";
      case "Pro Support":
        return "icons/settings_pro_support.svg";
      case "Send Love":
        return "icons/settings_send_a_love.svg";
      case "Terms of Use":
        return "icons/settings_terms_of.svg";
      case "Privacy Policy":
        return "icons/settings_privacy_policy.svg";
      case "Share App":
        return "icons/settings_share.svg";
      case "More Apps":
        return "icons/settings_more_apps.svg";
      default:
        return "icons/question_mark_icon.svg";
    }
  }

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
                  // InkWell(
                  //   onTap: () {
                  //     // open the 'Print Dashboard'
                  //     // Navigator.pop(context);
                  //   },
                  //   child: Padding(
                  //     padding: EdgeInsets.all(5),
                  //     child: const Icon(
                  //       Icons.arrow_back,
                  //       color: Colors.black,
                  //       size: 20,
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 40),
                      child: Text(
                        textAlign: TextAlign.center,
                        "Setting",
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
                      // Navigator.pop(context);
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
            // content view
            Expanded(
              child: ListView.builder(
                itemCount: helpItems.length,
                itemBuilder: (context, index) {
                  if (index == 4) {
                    return Text(
                      textAlign: TextAlign.center,
                      helpItems[index],
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          // fontWeight: FontWeight.w900,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16),
                    );
                  }
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
                        getIconForItem(helpItems[index]),
                        semanticsLabel: helpItems[index],
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
                        /*
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
                        */
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
