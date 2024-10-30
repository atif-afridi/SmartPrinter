import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TriviaService {
  final String baseUrl = 'https://opentdb.com/api.php';

  Future<List<dynamic>> fetchQuestions(int amount, int categoryId) async {
    final response = await http.get(Uri.parse(
        '$baseUrl?amount=$amount&category=$categoryId&type=multiple'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
/*
class PrintQuizzesWidget extends StatefulWidget {
  final int amount;
  final int categoryId;

  PrintQuizzesWidget({required this.amount, required this.categoryId});

  @override
  _PrintQuizzesWidgetState createState() => _PrintQuizzesWidgetState();
}

class _PrintQuizzesWidgetState extends State<PrintQuizzesWidget>
    with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> questions;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    questions =
        TriviaService().fetchQuestions(widget.amount, widget.categoryId);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trivia Quiz'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Questions & Answers'),
            Tab(text: 'Correct Answers'),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final questionsList = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: [
                // Questions and Answers Tab
                ListView.builder(
                  itemCount: questionsList.length,
                  itemBuilder: (context, index) {
                    final question = questionsList[index];
                    final allAnswers = [
                      ...question['incorrect_answers'],
                      question['correct_answer']
                    ];
                    allAnswers
                        .shuffle(); // Shuffle to randomize answer positions

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${index + 1}: ${question['question']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            ...allAnswers.asMap().entries.map((entry) {
                              int idx = entry.key;
                              String answer = entry.value;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                    '${String.fromCharCode(97 + idx)}) $answer'),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Correct Answers Tab
                ListView.builder(
                  itemCount: questionsList.length,
                  itemBuilder: (context, index) {
                    final question = questionsList[index];

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${index + 1}: ${question['question']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                                'Correct Answer: ${question['correct_answer']}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
*/

class PrintQuizzesWidget extends StatefulWidget {
  final int amount;
  final int categoryId;

  PrintQuizzesWidget({required this.amount, required this.categoryId});

  @override
  _PrintQuizzesWidgetState createState() => _PrintQuizzesWidgetState();
}

class _PrintQuizzesWidgetState extends State<PrintQuizzesWidget>
    with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> questions;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    questions =
        TriviaService().fetchQuestions(widget.amount, widget.categoryId);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _printQuiz(List<dynamic> questionsList) async {
    final pdf = pw.Document();
    const double questionHeight = 200; // Adjust this value based on your layout
    const double spacing = 20; // Space between questions
    const double margin = 20; // Margins on the page
    double pageHeight = PdfPageFormat.a4.height;
    double usableHeight =
        pageHeight - (2 * margin); // Usable height for questions
    const int minQuestionsPerPage = 2; // Minimum questions per page
    int maxQuestionsPerPage =
        ((usableHeight) / (questionHeight + spacing)).floor();
    maxQuestionsPerPage = maxQuestionsPerPage < minQuestionsPerPage
        ? minQuestionsPerPage
        : maxQuestionsPerPage;

    int totalQuestions = questionsList.length;
    int globalQuestionNumber = 1; // Start numbering from 1

    for (int currentQuestionIndex = 0;
        currentQuestionIndex < totalQuestions;
        currentQuestionIndex += maxQuestionsPerPage) {
      // Get the specific range of questions for the current page
      final pageQuestions = questionsList.sublist(
        currentQuestionIndex,
        (currentQuestionIndex + maxQuestionsPerPage) > totalQuestions
            ? totalQuestions
            : currentQuestionIndex + maxQuestionsPerPage,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: pw.EdgeInsets.all(margin),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  ...pageQuestions.map((question) {
                    List<String> allAnswers = [
                      ...question['incorrect_answers'],
                      question['correct_answer']
                    ];
                    allAnswers
                        .shuffle(); // Shuffle to randomize answer positions

                    final questionWidget = pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Question ${globalQuestionNumber++}: ${question['question']}', // Increment here
                          style: pw.TextStyle(fontSize: 24),
                        ),
                        pw.SizedBox(height: 10),
                        if (_tabController.index == 1) ...[
                          pw.Text(
                            'Correct Answer: ${question['correct_answer']}',
                            style: pw.TextStyle(
                                fontSize: 18, fontWeight: pw.FontWeight.bold),
                          ),
                        ] else ...[
                          pw.Text('Options:',
                              style: pw.TextStyle(fontSize: 18)),
                          ...allAnswers.asMap().entries.map((entry) {
                            int idx = entry.key;
                            String answer = entry.value;
                            return pw.Text(
                                '${String.fromCharCode(97 + idx)}) $answer');
                          }).toList(),
                        ],
                      ],
                    );

                    return pw.Padding(
                      padding: pw.EdgeInsets.only(bottom: spacing),
                      child: questionWidget,
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      );
    }

    // Print the PDF document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trivia Quiz'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Questions & Answers'),
            Tab(text: 'Correct Answers'),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final questionsList = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Questions and Answers Tab
                      ListView.builder(
                        itemCount: questionsList.length,
                        itemBuilder: (context, index) {
                          final question = questionsList[index];
                          List<String> allAnswers = [
                            ...question['incorrect_answers'],
                            question['correct_answer']
                          ];
                          allAnswers
                              .shuffle(); // Shuffle to randomize answer positions

                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question ${index + 1}: ${question['question']}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  ...allAnswers.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    String answer = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Text(
                                          '${String.fromCharCode(97 + idx)}) $answer'),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Correct Answers Tab
                      ListView.builder(
                        itemCount: questionsList.length,
                        itemBuilder: (context, index) {
                          final question = questionsList[index];

                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question ${index + 1}: ${question['question']}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                      'Correct Answer: ${question['correct_answer']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Centered Print Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final snapshot = await questions;
                      _printQuiz(snapshot);
                    },
                    child: Text('Print Quiz'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
