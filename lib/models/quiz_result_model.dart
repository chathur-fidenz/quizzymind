class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final String userId;
  final String date;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.userId,
    required this.date,
  });
}
