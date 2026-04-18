import '../../domain/entities/course_evaluation.dart';

class CourseEvaluationModel {
  final String id;
  final String name;
  final String status;
  final String visibility;
  final String groupCategory;
  final DateTime deadline;

  const CourseEvaluationModel({
    required this.id,
    required this.name,
    required this.status,
    required this.visibility,
    required this.groupCategory,
    required this.deadline,
  });

  factory CourseEvaluationModel.fromJson(Map<String, dynamic> json) =>
      CourseEvaluationModel(
        id: json['_id'].toString(),
        name: json['name'] as String,
        status: json['status'] as String,
        visibility: json['visibility'] as String,
        groupCategory: json['group_category'] as String,
        deadline: DateTime.parse(json['deadline'] as String),
      );

  CourseEvaluation toEntity() => CourseEvaluation(
        id: id,
        name: name,
        status: status,
        visibility: visibility,
        groupCategory: groupCategory,
        deadline: deadline,
      );
}
