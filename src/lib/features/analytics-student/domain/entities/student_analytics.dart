class EvaluatorComment {
  final String evaluatorEmail;
  final String text;

  const EvaluatorComment({required this.evaluatorEmail, required this.text});
}

class StudentAnalytics {
  final String evaluationName;
  final String courseName;
  final bool isPublic;
  final double punctuality;
  final double contributions;
  final double commitment;
  final double attitude;
  final List<EvaluatorComment> comments;

  const StudentAnalytics({
    required this.evaluationName,
    required this.courseName,
    required this.isPublic,
    required this.punctuality,
    required this.contributions,
    required this.commitment,
    required this.attitude,
    required this.comments,
  });

  double get avgScore =>
      (punctuality + contributions + commitment + attitude) / 4;

  String get scoreLabel {
    if (avgScore >= 3.5) return 'Good';
    if (avgScore >= 2.5) return 'Average';
    return 'Needs improvement';
  }
}
