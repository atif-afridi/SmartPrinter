import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'print_quizzes.dart';

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

class QuizCreationWidget extends StatefulWidget {
  @override
  _QuizCreationWidgetState createState() => _QuizCreationWidgetState();
}

class _QuizCreationWidgetState extends State<QuizCreationWidget> {
  int questionCount = 10; // Default question count
  int selectedTopicIndex = -1; // Default: No topic selected

  final List<String> topics = [
    'General Knowledge',
    'Science',
    'History',
    'Geography',
    'Technology',
    'Literature',
    'Food & Drinks',
    'TV Shows',
    'Movies',
    'Music',
    'Sports',
    'Pop Culture',
    'Travel',
    'Mathematics',
    'Animals'
  ];

  void _createQuiz() {
    if (selectedTopicIndex != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintQuizzesWidget(
            amount: questionCount,
            categoryId:
                selectedTopicIndex + 9, // Adjust category id accordingly
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a topic')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chips for topics
            Wrap(
              spacing: 8.0,
              children: List<Widget>.generate(topics.length, (index) {
                return ChoiceChip(
                  label: Text(topics[index]),
                  selected: selectedTopicIndex == index,
                  onSelected: (selected) {
                    setState(() {
                      selectedTopicIndex = selected ? index : -1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 16.0),
            // Question Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (questionCount > 1) {
                      setState(() {
                        questionCount--;
                      });
                    }
                  },
                ),
                Text('Questions: $questionCount'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      questionCount++;
                    });
                  },
                ),
              ],
            ),
            Spacer(),
            // Create Quiz Button
            ElevatedButton(
              onPressed: _createQuiz,
              child: Text('Create Quiz'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full width
              ),
            ),
          ],
        ),
      ),
    );
  }
}
