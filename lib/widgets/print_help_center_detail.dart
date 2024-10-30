// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'print_help_center_printer_detail.dart';

class HelpCenterDetail extends StatelessWidget {
  final String title;

  HelpCenterDetail({required this.title});

  @override
  Widget build(BuildContext context) {
    Widget _buildPrinterOption(BuildContext context, String printerName) {
      return ListTile(
        title: Text(printerName),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrinterDetails(printerName: printerName),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _buildHelpContent(context, _buildPrinterOption),
    );
  }

  Widget _buildHelpContent(BuildContext context,
      Widget Function(BuildContext, String) buildPrinterOption) {
    switch (title) {
      case "How Can I Connect with My Printer?":
        return ListView(
          children: [
            buildPrinterOption(context, "HP Printers"),
            buildPrinterOption(context, "Epson"),
            buildPrinterOption(context, "Xerox"),
          ],
        );
      // other cases
      default:
        return Center(child: Text("No additional details available."));
    }
  }
}
