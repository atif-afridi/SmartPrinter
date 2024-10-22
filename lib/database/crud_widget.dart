import 'package:flutter/material.dart';

import 'app_database.dart';
import 'printer_model.dart';

class TestDataBaseWidget extends StatefulWidget {
  const TestDataBaseWidget({super.key});

  @override
  State<TestDataBaseWidget> createState() => _TestDataBaseWidgetState();
}

class _TestDataBaseWidgetState extends State<TestDataBaseWidget> {
  ///
  AppDatabase noteDatabase = AppDatabase.instance;

  List<PrintModel> notes = [];

  @override
  void initState() {
    // noteDatabase.open();
    // refreshNotes();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    //close the database
    // noteDatabase.close();
  }

  ///Gets all the notes from the database and updates the state
  refreshNotes() {
    noteDatabase.readAll().then((value) {
      setState(() {
        notes = value;
      });
    });
  }

  ///Creates a new note if the isNewNote is true else it updates the existing note
  createNote() {
    // setState(() {
    //   isLoading = true;
    // });
    final model = PrintModel(
      title: "printer : hp laser jet",
      // number: 1,
      // content: contentController.text,
      // isFavorite: isFavorite,
      isConnected: true,
      createdTime: DateTime.now(),
    );
    // if (isNewNote) {
    noteDatabase.create(model);
    // } else {
    //   model.id = note.id;
    //   noteDatabase.update(model);
    // }
    // setState(() {
    //   isLoading = false;
    // });

    refreshNotes();
  }

  ///Deletes the note from the database and navigates back to the previous screen
  deleteNote() async {
    await noteDatabase.deleteAll();
    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    createNote();
                  },
                  child: Text(
                    'Insert',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    deleteNote();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {},
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    refreshNotes();
                  },
                  child: Text(
                    'Read All',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {},
                  child: Text(
                    'Read One',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                ///
                SizedBox(
                  height: 200.0,
                  child: Center(
                    child: notes.isEmpty
                        ? const Text(
                            'No Printer yet',
                            style: TextStyle(color: Colors.black),
                          )
                        : ListView.builder(
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return GestureDetector(
                                // onTap: () => goToNoteDetailsView(id: note.id),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            note.createdTime
                                                .toString()
                                                .split(' ')[0],
                                          ),
                                          Text(
                                            note.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
