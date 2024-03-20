import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizzymind/models/quiz_result_model.dart';
import 'package:quizzymind/widgets/result_item.dart';
import 'package:intl/intl.dart';

class QuizResults extends StatefulWidget {
  const QuizResults({super.key});

  @override
  State<QuizResults> createState() => _QuizResultsState();
}

class _QuizResultsState extends State<QuizResults> {
  List<QuizResult> quizResultList = [];

  Future<void> fetchQuizResultsByUserId() async {
    try {
      final authenticatedUser = FirebaseAuth.instance.currentUser!;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('quiz_results')
          .where('user_id', isEqualTo: authenticatedUser.uid)
          .orderBy(
            'created_at',
            descending: true,
          )
          .get();
      quizResultList = querySnapshot.docs.map((doc) {
        return QuizResult(
          totalQuestions: doc['total_questions'],
          correctAnswers: doc['correct_answers'],
          incorrectAnswers: doc['incorrect_answers'],
          userId: doc['user_id'],
          date: DateFormat('MMM dd, yyyy hh:mm a')
              .format(doc['created_at'].toDate()),
        );
      }).toList();
    } catch (error) {
      print('Failed to fetch quiz results: $error');
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchQuizResultsByUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Scores'),
        backgroundColor: const Color.fromARGB(255, 63, 17, 177),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color.fromARGB(255, 63, 17, 177),
      body: FutureBuilder<void>(
        future: fetchQuizResultsByUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return ListView.builder(
              itemCount: quizResultList.length,
              itemBuilder: (ctx, index) =>
                  ResultItem(quizResult: quizResultList[index]),
            );
          }
        },
      ),
    );
  }
}
