import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PrintClipboardPreviewWidget extends StatelessWidget {
  final Map<String, String> clipboardNote;

  const PrintClipboardPreviewWidget({Key? key, required this.clipboardNote})
      : super(key: key);

  Future<void> _printDocument() async {
    // Load a font from assets (e.g., Open Sans)
    final ByteData fontData =
        await rootBundle.load('fonts/opensans-medium.ttf');
    final pw.Font ttf = pw.Font.ttf(fontData);

    // Create a PDF document
    final pdf = pw.Document();

    // Ensure the content is not empty
    final content = clipboardNote['text'];
    if (content == null || content.isEmpty) {
      print('No content available to print.');
      return; // Exit if there's no content to print
    }

    // Add a page to the PDF with only the content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(16.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Use Noto Sans for content to ensure better Unicode support
              pw.Text(
                content, // Use the retrieved content
                style: pw.TextStyle(
                  fontSize: 14,
                  font: ttf,
                ),
                maxLines: null, // Allow multiple lines for text
              ),
            ],
          ),
        ),
      ),
    );

    // Print the PDF document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Clipboard Note'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the text content in the preview
                  Text(
                    clipboardNote['text']!,
                    style: TextStyle(fontSize: 16), // Use default font here
                  ),
                ],
              ),
            ),
          ),
          // Fixed button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _printDocument,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full width button
              ),
              child: Text('Print'),
            ),
          ),
        ],
      ),
    );
  }
}
