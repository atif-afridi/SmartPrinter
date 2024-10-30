// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PrinterDetails extends StatelessWidget {
  final String printerName;

  PrinterDetails({required this.printerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(printerName),
      ),
      body: printerName == "HP Printers"
          ? _buildHPTabs()
          : _buildGenericPrinterInfo(),
    );
  }

  Widget _buildHPTabs() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Touch screen printer"),
              Tab(text: "Button printer"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                ListTile(
                    title:
                        Text("Step 1: Select settings on the touch screen.")),
                ListTile(title: Text("Step 2: Choose 'Connect to Wi-Fi'."))
              ],
            ),
            ListView(
              children: [
                ListTile(
                    title: Text(
                        "Step 1: Press the Wi-Fi button until it blinks.")),
                ListTile(
                    title: Text("Step 2: Connect through the app settings."))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericPrinterInfo() {
    return ListView(
      children: [
        ListTile(
            title:
                Text("1- Follow the manufacturer's connection instructions.")),
        ListTile(
            title: Text(
                "2- Ensure the printer is on the same network as your device.")),
      ],
    );
  }
}
