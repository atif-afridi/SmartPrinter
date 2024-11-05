import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printer_app/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterDetail extends StatelessWidget {
  final String title;
  final List<String> items = [
    "HP",
    "Epson",
    "Xerox",
    "Canon",
    "Toshiba",
    "Ricoh",
    "Brother",
    "Dell",
    "Kyocera",
  ];
  final List<Color> textColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.lime,
  ];

  HelpCenterDetail({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    Widget buildPrinterOption(BuildContext context, String printerName) {
      return Container(
        margin: EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0), // optional padding around the ListTile
        decoration: BoxDecoration(
          color: AppColor.menuColor, // Set the background color here
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        child: ListTile(
          title: Text(
            printerName,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white,
            ),
          ),
          trailing: SvgPicture.asset("icons/next_arrow_icon.svg",
              semanticsLabel: 'A red up arrow'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrinterDetails(printerName: printerName),
              ),
            );
          },
        ),
      );
    }

    Widget buildPrinterDefaults(BuildContext context, String text) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(10.0),
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
                      margin: EdgeInsets.only(left: 20),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHelpContent(
                        context, buildPrinterOption, buildPrinterDefaults),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.8,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey[300]!, width: 1.0),
            ),
            alignment: Alignment.center,
            child: Text(
              items[index],
              style: TextStyle(
                color: textColors[index % textColors.length],
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHelpContent(
      BuildContext context,
      Widget Function(BuildContext, String) buildPrinterOption,
      Widget Function(BuildContext, String) buildPrinterDefaults) {
    switch (title) {
      case "How Can I Connect with My Printer?":
        return Column(
          children: [
            buildPrinterOption(context, "HP Printers"),
            buildPrinterOption(context, "Brother"),
            buildPrinterOption(context, "Epson"),
            buildPrinterOption(context, "Canon"),
            buildPrinterOption(context, "Fuji Xerox"),
            buildPrinterOption(context, "Lexmark"),
          ],
        );
      case "Review the instruction before proceeding":
        return Column(
          children: [
            buildPrinterDefaults(context,
                "1- Make sure your device is connected to the same WiFi network as the printer."),
            buildPrinterDefaults(context,
                "2- Open the Smart Printer Application on your device."),
            buildPrinterDefaults(context,
                "3- Select and connect your device with the printer by clicking on the Tap to 'Connect' button"),
            buildPrinterDefaults(
                context, "4- Select the document or photo you want to print."),
            buildPrinterDefaults(
                context, "5- Tap the 'Print' button to start print."),
            buildPrinterDefaults(context,
                "6- Adjust the print settings as needed (e.g. paper size, color, number of copies)."),
            buildPrinterDefaults(context,
                "7- Ensure the printer is turned on and loaded with paper and ink/toner."),
            _buildGridContent(context),
          ],
        );
      case "Info About Mobile Print":
        return Column(
          children: [
            buildInfoAbout(context, 0, "",
                "The Smart Printer application lets you use your Printer with your Android device at home, work or on the go."),
            buildInfoAbout(context, 1, "Simple Printing",
                "You do not have to worry about not being able to access important documents on time. As long as you have access to ou Smart Printer Application and the internet, you can easily connect to a printer with mobile printing capabilities."),
            buildInfoAbout(context, 2, "Preview and Control",
                "Share your images (JPG or PNG) and PDFs to the print service plugin when additional print options are needed, like layout or quality."),
            buildInfoAbout(context, 3, "Get More Get Smart",
                "With our Smart Printer app, printing and scanning documents is now easier then ever. if you have any questions or need assistance, feel free to contact put support team."),
          ],
        );
      case "How to use App for Printing?":
        return Column(
          children: [
            buildIconWithTitleAndDetails(
                context,
                "icons/open_the_app.svg",
                "Open the App:",
                "Once installed, open The Smart Printer App on your device"),
            buildIconWithTitleAndDetails(
                context,
                "icons/connecting_printer.svg",
                "Connecting to the printer:",
                "1. Ensure your printer is turned on and connected to the same Wi-Fi network as your device.\n2. In the app, tap on the option to add a new printer.\n3. Select your printer from the list of available devices or follow the on-screen instructions to connect."),
            buildIconWithTitleAndDetails(
                context,
                "icons/print_a_document.svg",
                "Print a Document:",
                "1. Select the document you want to print from your device.\n2. Tap the Print option within the document.\n3. Select your printer from the of connected devices.\n4. Adjust print settings such as paper size, color and number of copies.\n5. Tap the print button to start printing."),
            buildIconWithTitleAndDetails(
                context,
                "icons/scan_a_document.svg",
                "Scan a Document:",
                "1. In the app, select the option to scan a document.\n2. Adjust settings such as color mode and resolution if needed.\n3. Tap the scan button to start scanning.\n4. Review and edit the scanned document if necessary.\n5. Save or share the scanned document as needed."),
            buildIconWithTitleAndDetails(
                context,
                "icons/print_photos.svg",
                "Print Photos:",
                "1. Select the photos you want to print from your device's gallery.\n2. In the app, select the option to print photos.\n3. Choose your printer and adjust settings such as paper size and layout.\n4. Tap the print button to start printing."),
          ],
        );
      case "Help":
        return Column(
          children: [Text("open default email app")],
        );

      default:
        return Center(child: Text("No additional details available."));
    }
  }

  Widget buildIconWithTitleAndDetails(
      BuildContext context, String icon, String title, String details) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon on the left
              SvgPicture.asset(
                icon,
                width: 24.0,
                height: 24.0,
                // Uncomment to apply color filter to icon
                // colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                semanticsLabel: 'Icon for $title',
              ),
              SizedBox(width: 16.0), // Space between icon and title
              // Title next to the icon
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0), // Space between title row and description
          // Details text below icon and title
          Text(
            details,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoAbout(
      BuildContext context, int index, String title, String description) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index == 0)
            Text(
              description,
              style: TextStyle(
                fontSize: 14.0,
              ),
            )
          else ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0), // Spacing between title and description
            Text(
              description,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black87,
              ),
            ),
          ],
          if (index == 3)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Happy Printing',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  // color: Colors.blueAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildHowToUseAppForPrinting(
      BuildContext context, int index, String title, String description) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index == 0)
            Text(
              description,
              style: TextStyle(
                fontSize: 14.0,
              ),
            )
          else ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0), // Spacing between title and description
            Text(
              description,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black87,
              ),
            ),
          ],
          if (index == 3)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Happy Printing',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  // color: Colors.blueAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PrinterDetails extends StatelessWidget {
  final String printerName;

  const PrinterDetails({super.key, required this.printerName});

  @override
  Widget build(BuildContext context) {
    return printerName == 'HP Printers' || printerName == 'Epson'
        ? DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text(printerName),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48.0),
                  child: Theme(
                    data: ThemeData(
                      dividerColor: Colors.grey, // Remove grey line
                    ),
                    child: TabBar(
                      labelColor: AppColor.menuColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColor.menuColor,
                      tabs: [
                        Tab(text: 'Touch Screen Printers'),
                        Tab(text: 'Button Printers'),
                      ],
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  _buildPrinterSteps(context, isTouchScreen: true),
                  _buildPrinterSteps(context, isTouchScreen: false),
                ],
              ),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 15),
                    decoration: BoxDecoration(
                      color: AppColor.menuColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Print button action here
                        openPlayStoreApp(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text(
                          "Set Up Print Services",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : printerName == 'Brother' ||
                printerName == 'Canon' ||
                printerName == 'Fuji Xerox' ||
                printerName == 'Lexmark'
            ? Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  title: Text(printerName),
                ),
                body: _buildPrinterSteps(context, isTouchScreen: false),
                bottomNavigationBar: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15, bottom: 15),
                      decoration: BoxDecoration(
                        color: AppColor.menuColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Print button action here
                          openPlayStoreApp(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Text(
                            "Set Up Print Services",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : throw Exception("Unknown printer name: $printerName");
  }

  void openPlayStoreApp(BuildContext context) async {
    var whichApp;
    var appId = "com.hp.android.printservice";
    switch (printerName) {
      case "HP Printers":
        appId = Platform.isAndroid
            ? 'com.hp.android.printservice'
            : 'YOUR_IOS_APP_ID';
        whichApp = "";
        break;
      case "Epson":
        appId = Platform.isAndroid ? 'epson.print' : 'YOUR_IOS_APP_ID';
        whichApp = "";
        break;
      case "Brother":
        appId = Platform.isAndroid
            ? 'com.brother.mfc.mobileconnect'
            : 'YOUR_IOS_APP_ID';
        whichApp = "";
        break;
      case "Canon":
        appId = Platform.isAndroid
            ? 'jp.co.canon.bsd.ad.pixmaprint'
            : 'YOUR_IOS_APP_ID';
        whichApp = "";
        break;
      case "Fuji Xerox":
        appId =
            Platform.isAndroid ? 'com.xerox.printservice' : 'YOUR_IOS_APP_ID';
        whichApp = "";
        break;
      case "Lexmark":
        appId = Platform.isAndroid
            ? 'com.lexmark.mobile.lxkprint'
            : 'YOUR_IOS_APP_ID';
        whichApp = "";
        break;
    }
    // open the play store app
    whichApp = 'whatsapp://send?phone=255634523';
    if (Platform.isAndroid || Platform.isIOS) {
      final url = Uri.parse(
        Platform.isAndroid
            // ? "market://details?id=$appId"
            ? "https://play.google.com/store/apps/details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Widget _buildPrinterSteps(BuildContext context,
      {required bool isTouchScreen}) {
    List<Map<String, String>> steps = [];

    if (printerName == 'HP Printers') {
      if (isTouchScreen) {
        steps = [
          {
            "title": "Step 1",
            "description": "Place the printer near the Wi-Fi router."
          },
          {
            "title": "Step 2",
            "description":
                "Make sure paper is loaded in the main tray, and then turn on the printer."
          },
          {
            "title": "Step 3",
            "description":
                "Touch the Wi-Fi icon to display the Wi-Fi status and then touch the Settings button to turn on Wi-Fi."
          },
          {
            "title": "Step 4",
            "description":
                "Install the HP Smart app from the Play Store and follow the guided installation to continue setup."
          },
          {
            "title": "Step 5",
            "description":
                "Go to your Wi-Fi settings on this mobile device and select HP-Setup-..from the Wi-Fi network list."
          },
          {
            "title": "Step 6",
            "description":
                "Reopen the HP Smart app to check the printer status."
          },
          {
            "title": "Step 7",
            "description":
                "Enter the Wi-Fi network password to connect. It can take up to a few minutes for the printer to connect to a Wi-Fi network."
          },
          {
            "title": "Step 8",
            "description":
                "If the blue light on your printer is blinking, your printer is not connected. If the blue light is solid, your printer is on the network."
          },
          {
            "title": "Step 9",
            "description":
                "Tap the button below to install the Printer Service app."
          },
        ];
      } else {
        steps = [
          {
            "title": "Step 1",
            "description": "Place the printer near the Wi-Fi router."
          },
          {
            "title": "Step 2",
            "description":
                "Make sure paper is loaded in the main tray, and then turn on the printer."
          },
          {
            "title": "Step 3",
            "description":
                "Press and hold the Wireless button for at least 5 seconds or until the light starts blinking. You might need to press the button twice if the printer is asleep."
          },
          {
            "title": "Step 4",
            "description":
                "Make sure paper is loaded in the main tray, and then turn on the printer."
          },
          {
            "title": "Step 5",
            "description":
                "Go to your Wi-Fi settings on this mobile device and select HP-Setup...from the Wi-Fi network list."
          },
          {
            "title": "Step 6",
            "description":
                "Reopen the HP Smart app to check the printer status."
          },
          {
            "title": "Step 7",
            "description":
                "Enter the Wi-Fi network password to connect. It can take up to a few minutes for the printer to connect to a Wi-Fi network."
          },
          {
            "title": "Step 8",
            "description":
                "If the blue light on your printer is blinking, your printer is not connected. If the blue light is solid, your printer is on the network."
          },
          {
            "title": "Step 9",
            "description":
                "Tap the button below to install the Print Service app."
          },
        ];
      }
    } else if (printerName == 'Brother' ||
        printerName == 'Canon' ||
        printerName == 'Fuji Xerox' ||
        printerName == 'Lexmark') {
      steps = [
        {
          "title": "Step 1",
          "description":
              "Place the printer near the Wi-Fi router. Turn your printer on."
        },
        {
          "title": "Step 2",
          "description":
              "On your printer, go to Settings > Network Settings > Wi-Fi Setup and select the Wi-Fi Direct setting."
        },
        {
          "title": "Step 3",
          "description":
              "Follow the instructions on the printer's screen and setup."
        },
        {
          "title": "Step 4",
          "description": "Follow the setup guide in the user manual"
        },
        {
          "title": "Step 5",
          "description":
              "Select the SSID shown on the printer's screen and enter the password."
        },
        {
          "title": "Step 6",
          "description":
              "Wait until the process ends. Tap the button below to install the Print Service app."
        },
      ];
    } else if (printerName == 'Epson') {
      if (isTouchScreen) {
        steps = [
          {
            "title": "Step 1",
            "description":
                "Place the printer near the Wi-Fi router. Turn your printer on."
          },
          {
            "title": "Step 2",
            "description":
                "On your printer, go to Settings > Network Settings > Wi-Fi Setup and select the Wi-Fi Direct setting."
          },
          {
            "title": "Step 3",
            "description":
                "Follow the instructions on the printer's screen and setup."
          },
          {
            "title": "Step 4",
            "description":
                "On your phone, open the Wi-Fi settings from the Settings menu."
          },
          {
            "title": "Step 5",
            "description":
                "Select the SSID shown on the printer's screen and enter the password."
          },
        ];
      } else {
        steps = [
          {
            "title": "Step 1",
            "description":
                "Place the printer near the Wi-Fi router. Turn your printer on."
          },
          {
            "title": "Step 2",
            "description":
                "Make sure paper is loaded in the main tray, and then turn on the printer."
          },
          {
            "title": "Step 3",
            "description":
                "Press the Wi-Fi button and the Network Status button simultaneously until the two lights flash alternately."
          },
          {"title": "Step 4", "description": "Load paper."},
          {
            "title": "Step 5",
            "description":
                "Hold down the Network Status button on the printer's control panel for at least 7 seconds. The network status sheet is printed."
          },
          {
            "title": "Step 6",
            "description":
                "Check the SSID and password printed on the network status sheet."
          },
          {
            "title": "Step 7",
            "description":
                "Enter the Wi-Fi network password to connect. It can take up to a few minutes for the printer to connect to a Wi-Fi network.In the Wi-Fi settings on your phone, select the SSID printed on the network status sheet and enter the password."
          },
          {
            "title": "Step 8",
            "description":
                "Wait until the process ends. Tap the button below to install the Print Service app."
          },
        ];
      }
    } else {
      throw Exception("Unknown printer name: $printerName");
    }

    return ListView.builder(
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        return ListTile(
          title: Text(step["title"]!),
          subtitle: Text(step["description"]!),
        );
      },
    );
  }
}
