import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:printer_app/utils/colors.dart';
import 'package:printer_app/utils/strings.dart';

import 'database/app_database.dart';
import 'database/printer_model.dart';
import 'widgets/print_dashboard.dart';
import 'widgets/scan_document.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, required this.title});

  final String title;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  AppDatabase noteDatabase = AppDatabase.instance;

  late Future<List<PrintModel>> connectedPrinterList;
  int _selectedTab = 0;

  void onItemTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
    print("tapping BottomNavigationBar : $index");
  }

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return PrintDashboardWidget(title: "Smart Printer & Scanner");
      case 1:
        return ScanDocumentWidget(title: "Smart Printer & Scanner");
      default:
        return Placeholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: getPage(_selectedTab),
        // body: FutureBuilder(
        //     // future: refreshNotes(),
        //     future: connectedPrinterList,
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState != ConnectionState.done) {
        //         return const Center(child: CircularProgressIndicator());
        //       }
        //       if (snapshot.hasData) {
        //         return getPage(_selectedTab, snapshot.data);
        //       }
        //       return Placeholder();
        //       // return (snapshot.hasData)
        //       //     ? getPage(_selectedTab, snapshot.data)
        //       //     : const Center(child: CircularProgressIndicator());
        //     }),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: AppColor.lightGreyColor,
                spreadRadius: 0,
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: BottomNavigationBar(
              selectedIconTheme: const IconThemeData(color: AppColor.menuColor),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColor.menuColor,
              unselectedItemColor: AppColor.lightGreyColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 25,
                    width: 25,
                    child: Image.asset(
                      'icons/icon_print_outline.png',
                      color: _selectedTab == 0
                          ? AppColor.menuColor
                          : AppColor.lightGreyColor,
                    ),
                  ),
                  label: 'Print',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 25,
                    width: 25,
                    child: Image.asset(
                      'icons/icon_menu_scan.png',
                      color: _selectedTab == 1
                          ? AppColor.menuColor
                          : AppColor.lightGreyColor,
                    ),
                  ),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 25,
                    width: 25,
                    child: Image.asset(
                      'icons/icon_menu_settings.png',
                      color: _selectedTab == 2
                          ? AppColor.menuColor
                          : AppColor.lightGreyColor,
                    ),
                  ),
                  label: 'Setting',
                ),
              ],
              currentIndex: _selectedTab,
              onTap: onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
