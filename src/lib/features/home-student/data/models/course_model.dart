import '../../domain/entities/course.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.code,
    required super.name,
    required super.period,
    required super.activeEvaluations,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id'],
      code: json['code'] ?? '---',
      name: json['name'] ?? '---',
      period: json['period'] ?? '---',
      activeEvaluations: json['activeEvaluations'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'period': period,
    'activeEvaluations': activeEvaluations,
  };
}
