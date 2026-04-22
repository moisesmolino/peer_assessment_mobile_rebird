import '../../domain/entities/student_analytics.dart';

class EvaluatorCommentModel {
  final String evaluatorEmail;
  final String text;

  const EvaluatorCommentModel({required this.evaluatorEmail, required this.text});

  factory EvaluatorCommentModel.fromJson(Map<String, dynamic> json) =>
      EvaluatorCommentModel(
        evaluatorEmail: json['evaluator_email'] as String,
        text: json['comment'] as String,
      );

  EvaluatorComment toEntity() =>
      EvaluatorComment(evaluatorEmail: evaluatorEmail, text: text);
}

class StudentAnalyticsModel {
  final double punctuality;
  final double contributions;
  final double commitment;
  final double attitude;
  final List<EvaluatorCommentModel> comments;

  const StudentAnalyticsModel({
    required this.punctuality,
    required this.contributions,
    required this.commitment,
    required this.attitude,
    required this.comments,
  });

  factory StudentAnalyticsModel.fromRows(List<Map<String, dynamic>> rows) {
    double avg(String key) =>
        rows.map((r) => (r[key] as num).toDouble()).reduce((a, b) => a + b) /
        rows.length;

    final comments = rows
        .where((r) => (r['comment'] as String? ?? '').isNotEmpty)
        .map((r) => EvaluatorCommentModel.fromJson(r))
        .toList();

    return StudentAnalyticsModel(
      punctuality: avg('punctuality'),
      contributions: avg('contributions'),
      commitment: avg('commitment'),
      attitude: avg('attitude'),
      comments: comments,
    );
  }

  StudentAnalytics toEntity({
    required String evaluationName,
    required String courseName,
    required bool isPublic,
  }) =>
      StudentAnalytics(
        evaluationName: evaluationName,
        courseName: courseName,
        isPublic: isPublic,
        punctuality: punctuality,
        contributions: contributions,
        commitment: commitment,
        attitude: attitude,
        comments: comments.map((c) => c.toEntity()).toList(),
      );
}
