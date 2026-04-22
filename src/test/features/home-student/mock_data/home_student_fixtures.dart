import 'package:src/features/home-student/domain/entities/course.dart';
import 'package:src/features/home-student/domain/entities/evaluation.dart';

Course buildHomeStudentCourse({
  String id = 'course-1',
  String code = 'CS101',
  String name = 'Software Design',
  String period = '2026-1',
  int activeEvaluations = 2,
}) {
  return Course(
    id: id,
    code: code,
    name: name,
    period: period,
    activeEvaluations: activeEvaluations,
  );
}

Evaluation buildEvaluation({
  String id = 'eval-1',
  String courseCode = 'CS101',
  String title = 'Sprint 3 Peer Review',
  String courseName = 'Software Design',
  EvaluationStatus status = EvaluationStatus.open,
  String timeRemaining = '2 days left',
  String groupCategory = 'Team A',
  DateTime? deadline,
}) {
  return Evaluation(
    id: id,
    courseCode: courseCode,
    title: title,
    courseName: courseName,
    status: status,
    timeRemaining: timeRemaining,
    groupCategory: groupCategory,
    deadline: deadline ?? DateTime(2026, 4, 30),
  );
}
