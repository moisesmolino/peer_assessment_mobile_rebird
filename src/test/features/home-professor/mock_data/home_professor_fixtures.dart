import 'package:src/features/home-professor/domain/entities/course.dart';

Course buildProfessorCourse({
  String id = 'p-course-1',
  String code = 'DS402',
  String name = 'Distributed Systems',
  String period = '2026-1',
  int studentsCount = 28,
  int activeEvaluations = 3,
  int totalEvaluations = 5,
}) {
  return Course(
    id: id,
    code: code,
    name: name,
    period: period,
    studentsCount: studentsCount,
    activeEvaluations: activeEvaluations,
    totalEvaluations: totalEvaluations,
  );
}
