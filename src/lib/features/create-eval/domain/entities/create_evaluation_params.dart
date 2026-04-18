class CreateEvaluationParams {
  final String name;
  final String courseId;
  final String groupCategoryName;
  final DateTime deadline;
  final String visibility; // 'public' or 'private'

  const CreateEvaluationParams({
    required this.name,
    required this.courseId,
    required this.groupCategoryName,
    required this.deadline,
    required this.visibility,
  });
}
