// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'print_help_center_detail.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(child: Text('Help Center')),
        actions: [Icon(Icons.star_border)], // Premium Icon
      ),
      body: ListView.builder(
        itemCount: helpItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.help_outline), // Left icon
            title: Center(child: Text(helpItems[index])), // Centered title
            trailing: Icon(Icons.arrow_forward), // Right arrow
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HelpCenterDetail(title: helpItems[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
