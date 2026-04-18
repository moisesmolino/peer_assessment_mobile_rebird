import '../../domain/entities/create_evaluation_params.dart';

class CreateEvaluationModel {
  final String name;
  final String courseId;
  final String groupCategoryName;
  final DateTime deadline;
  final String visibility;

  const CreateEvaluationModel({
    required this.name,
    required this.courseId,
    required this.groupCategoryName,
    required this.deadline,
    required this.visibility,
  });

  factory CreateEvaluationModel.fromEntity(CreateEvaluationParams entity) =>
      CreateEvaluationModel(
        name: entity.name,
        courseId: entity.courseId,
        groupCategoryName: entity.groupCategoryName,
        deadline: entity.deadline,
        visibility: entity.visibility,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'course_id': courseId,
        'group_category': groupCategoryName,
        'deadline': deadline.toIso8601String(),
        'visibility': visibility,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      };
}
