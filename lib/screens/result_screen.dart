import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzymind/models/question_model.dart';
import 'package:quizzymind/widgets/question_summary.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.chosenAnswers,
    required this.onRestart,
    required this.questions,
  });

  final void Function() onRestart;
  final List<String> chosenAnswers;
  final List<Question> questions;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isYetToSave = true;

  List<Map<String, Object>> getSummaryData() {
    final List<Map<String, Object>> summary = [];

    for (var i = 0; i < widget.chosenAnswers.length; i++) {
      summary.add(
        {
          'question_index': i,
          'question': widget.questions[i].question,
          'correct_answer': widget.questions[i].correctAnswer,
          'user_answer': widget.chosenAnswers[i]
        },
      );
    }

    return summary;
  }

  void saveResult() async {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    final summaryData = getSummaryData();
    final totalQuestions = widget.questions.length;
    final correctAnswers = summaryData.where((data) {
      return data['user_answer'] == data['correct_answer'];
    }).length;

    FirebaseFirestore.instance.collection('quiz_results').add({
      'user_id': authenticatedUser.uid,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'incorrect_answers': totalQuestions - correctAnswers,
      'created_at': Timestamp.now(),
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isYetToSave = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Result saved.'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryData = getSummaryData();
    final numTotalQuestions = widget.questions.length;
    final numCorrectQuestions = summaryData.where((data) {
      return data['user_answer'] == data['correct_answer'];
    }).length;

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You answered $numCorrectQuestions out of $numTotalQuestions questions correctly!',
              style: GoogleFonts.lato(
                color: const Color.fromARGB(255, 230, 200, 253),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            QuestionSummary(summaryData),
            const SizedBox(
              height: 30,
            ),
            TextButton.icon(
              onPressed: widget.onRestart,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Restart Quiz!'),
            ),
            if (_isYetToSave)
              TextButton.icon(
                onPressed: saveResult,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.save),
                label: const Text('Save result'),
              )
          ],
        ),
      ),
    );
  }
}
