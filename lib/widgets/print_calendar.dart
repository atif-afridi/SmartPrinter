import 'package:flutter/material.dart';

// import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintCalendar extends StatefulWidget {
  @override
  _PrintCalendarState createState() => _PrintCalendarState();
}

class _PrintCalendarState extends State<PrintCalendar> {
  final quill.QuillController _controller = quill.QuillController.basic();

  // Convert Quill document to PDF
  Future<void> _printNotes() async {
    final pdf = pw.Document();
    final docText = _controller.document.toPlainText();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Paragraph(
              text: docText,
              style: pw.TextStyle(fontSize: 12),
            ),
          ];
        },
      ),
    );

    // Print the PDF document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, right: 15.0, bottom: 10.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: const Text(
                      textAlign: TextAlign.center,
                      "Calendar",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: _printNotes, // Call print function
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Text(
                          "Print Notes",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: quill.QuillEditor(
                  controller: _controller,
                  focusNode: FocusNode(),
                  scrollController: ScrollController(),
                ),
              ),
            ),
            quill.QuillToolbar.simple(controller: _controller),
          ],
        ),
      ),
    );
  }
}
