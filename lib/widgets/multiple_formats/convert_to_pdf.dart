import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'dynamic_grid_widget.dart';
import 'four_boxes_pdf.dart';

class ConvertToPdfPage extends StatefulWidget {
  @override
  _ConvertToPdfPageState createState() => _ConvertToPdfPageState();
}

class _ConvertToPdfPageState extends State<ConvertToPdfPage> {
  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Widget to PDF"),
      ),
      body: Center(child: DynamicGridWidget()
          // child: Column(
          //   children: [
          //     RepaintBoundary(
          //       key: _globalKey,
          //       child:
          //           FourBoxesWidget(scaleFactor: 5.0), // Adjust the scale factor
          //     ),
          //     SizedBox(height: 20),
          //     ElevatedButton(
          //       onPressed: _captureAndPrintPdf,
          //       child: Text("Generate PDF"),
          //     ),
          //   ],
          // ),
          ),
    );
  }

  Future<void> _captureAndPrintPdf() async {
    try {
      // Capture the widget as an image
      RenderRepaintBoundary boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Create PDF document
      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(pngBytes);

      // A4 size is 595 x 842 points
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pdfImage, width: 595, height: 842),
            );
          },
        ),
      );

      // Print or save the PDF
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      print(e);
    }
  }
}
