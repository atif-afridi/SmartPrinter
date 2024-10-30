import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:printer_app/widgets/print_clipboard_preview.dart';

class PrintClipboardWidget extends StatefulWidget {
  @override
  _PrintClipboardWidgetState createState() => _PrintClipboardWidgetState();
}

class _PrintClipboardWidgetState extends State<PrintClipboardWidget> {
  List<Map<String, String>> clipboardNotes = [];
  String errorMessage = '';

  Future<void> pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData == null || clipboardData.text!.isEmpty) {
        setState(() {
          errorMessage = 'No saved clipboard';
        });
      } else {
        // Check if the clipboard text already exists in the list
        bool alreadyExists =
            clipboardNotes.any((note) => note['text'] == clipboardData.text);

        if (alreadyExists) {
          // Show toast if the clipboard text already exists
          Fluttertoast.showToast(
            msg: 'Already exists in the list',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        } else {
          // Clear any previous error message
          setState(() {
            errorMessage = ''; // Clear error if we get valid clipboard text
            final dateAdded = DateFormat('dd/MM/yyyy').format(DateTime.now());
            clipboardNotes.add({
              'title': 'clipboard_${clipboardNotes.length + 1}',
              'date': dateAdded,
              'text': clipboardData.text!,
            });
          });
        }
      }
    } catch (e) {
      // Handle exceptions, if any
      setState(() {
        errorMessage = 'Failed to retrieve clipboard data';
      });
    }
  }

  void editNote(int index) {
    // Assuming clipboardNotes[index] has a 'title' key for the title
    TextEditingController editController =
        TextEditingController(text: clipboardNotes[index]['title']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Note Title'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Enter new title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  // Update the title instead of the text
                  clipboardNotes[index]['title'] = editController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void deleteNote(int index) {
    setState(() {
      clipboardNotes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: clipboardNotes.isEmpty
                  ? Center(
                      child: Text(
                        'No data',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: clipboardNotes.length,
                      itemBuilder: (context, index) {
                        final note = clipboardNotes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PrintClipboardPreviewWidget(
                                        clipboardNote: note),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      note['text']!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note['title']!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(note['date']!),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'Edit') {
                                        editNote(index);
                                      } else if (value == 'Delete') {
                                        deleteNote(index);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'Edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'Delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    child: Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity, // Make the button full width
              child: ElevatedButton(
                onPressed: pasteFromClipboard,
                child: Text('Paste from Clipboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
