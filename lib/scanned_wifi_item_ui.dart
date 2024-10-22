import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'database/printer_model.dart';

class ScannedWifiItemUi extends StatelessWidget {
  final PrintModel printModel;
  // final VoidCallback onPressed;

  final void Function(PrintModel item) onConnectPressed;
  // This is the type of service we're looking for :
  // final String type = '_wonderful-service._tcp';

  const ScannedWifiItemUi(
      {super.key, required this.printModel, required this.onConnectPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Color(0xFF17BDD3),
        ),
        padding: const EdgeInsets.only(
          top: 5,
          bottom: 5,
        ),
        margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
        child: Container(
          margin: const EdgeInsets.only(left: 10),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                printModel.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                margin: const EdgeInsets.only(top: 7, bottom: 7, right: 10),
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    late PrintModel localPrintModel;
                    localPrintModel = printModel.isConnected
                        ? PrintModel(
                            title: printModel.title, isConnected: false)
                        : PrintModel(
                            title: printModel.title, isConnected: true);

                    onConnectPressed(localPrintModel);
                  },
                  child: Text(
                    printModel.isConnected ? "Connected" : "Connect",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Color(0xFF17BDD3),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
