import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printer_app/alphabets_list.dart';
import 'package:printer_app/discover_printer.dart';

import '../utils/strings.dart';

class PrintPreviewUi extends StatefulWidget {
  const PrintPreviewUi({super.key});

  @override
  State<PrintPreviewUi> createState() => _PrintPreviewUi();
}

class _PrintPreviewUi extends State<PrintPreviewUi> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.transparent,
          title: const Text(
            Strings.selectPrinterBrand,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Auto Search Printer
            Container(
              margin: const EdgeInsets.only(
                top: 15,
                left: 85,
                right: 85,
              ),
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 8,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF17BDD3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                child: InkWell(
                  onTap: () {
                    _openDiscoverPrinter(context);
                  },
                  child: Text(
                    Strings.autoSearchPrinter,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            // Or select your printer brand
            Container(
              padding: const EdgeInsets.only(
                top: 15,
                bottom: 5,
              ),
              child: const Text(
                Strings.orSelectYourPrinter,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: AlphabetsList(
                list: printerList,
                onPrinterSelection: (index) {
                  _openDiscoverPrinter(context);
                },
                selectedIndex: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDiscoverPrinter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DiscoverUi(),
      ),
    );
  }
}
