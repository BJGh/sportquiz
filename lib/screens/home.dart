import 'package:flutter/material.dart';
import 'package:sportquiz/models/category.dart';
import 'package:sportquiz/screens/quiz_page.dart';
import 'package:sportquiz/models/question.dart';
import 'package:sportquiz/resources/api_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedQuestionCount = '5'; // Default value
  String selectedDifficulty = 'easy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Sports Quiz Game'),
            DropdownButton<String>(
              value: selectedQuestionCount,
              items: ['5', '10', '15', '20'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedQuestionCount = newValue ?? '5';
                });
              },
            ),
            DropdownButton<String>(
              value: selectedDifficulty,
              items: ['easy', 'medium', 'hard'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDifficulty = newValue ?? 'easy';
                });
              },
            ),
            TextButton(
              onPressed: () async {
                // Declare this function as async
                List<Question> questions = await getQuestions(
                    Category(21, 'Sports'), // category selected by the user
                    int.parse(
                        selectedQuestionCount), // total questions selected by the user
                    selectedDifficulty // difficulty
                    ); // Fetch the data using an async function // Generate the questions
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                        questions: questions, category: Category(21, 'Sports')),
                  ),
                );
              },
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }

  List<Question> generateQuestions(List<Map<String, dynamic>> data) {
    List<Question> questions = Question.fromData(data);
    return questions;
  }
}
