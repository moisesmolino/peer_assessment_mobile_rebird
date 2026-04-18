import '../../domain/entities/evaluation.dart';

class EvaluationModel extends Evaluation {
  const EvaluationModel({
    required super.id,
    required super.courseCode,
    required super.title,
    required super.courseName,
    required super.status,
    required super.timeRemaining,
    required super.groupCategory,
    required super.deadline,
  });

  factory EvaluationModel.fromDbJson(
    Map<String, dynamic> evalJson,
    Map<String, dynamic> courseJson,
  ) {
    final deadline = DateTime.parse(evalJson['deadline'] as String);
    return EvaluationModel(
      id: evalJson['_id'].toString(),
      courseCode: courseJson['code'] as String? ?? '---',
      title: evalJson['name'] as String,
      courseName: courseJson['name'] as String? ?? '---',
      status: deadline.isAfter(DateTime.now())
          ? EvaluationStatus.open
          : EvaluationStatus.closed,
      timeRemaining: _computeTimeRemaining(deadline),
      groupCategory: evalJson['group_category'] as String,
      deadline: deadline,
    );
  }

  static String _computeTimeRemaining(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays >= 1) return '${diff.inDays}d left';
    if (diff.inHours >= 1) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }
}
