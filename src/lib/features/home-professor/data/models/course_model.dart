import '../../domain/entities/course.dart';

class CourseModel extends Course {

  CourseModel({
    required super.id,
    required super.code,
    required super.name,
    required super.period,
    required super.studentsCount,
    required super.activeEvaluations,
  });

}