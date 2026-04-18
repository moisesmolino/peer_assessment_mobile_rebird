class CourseEvaluation {
  final String id;
  final String name;
  final String status;         // 'active' | 'closed'
  final String visibility;     // 'public' | 'private'
  final String groupCategory;
  final DateTime deadline;

  const CourseEvaluation({
    required this.id,
    required this.name,
    required this.status,
    required this.visibility,
    required this.groupCategory,
    required this.deadline,
  });
}
