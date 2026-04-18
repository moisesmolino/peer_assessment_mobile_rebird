import '../entities/evaluation.dart';
import '../entities/course.dart';

abstract class HomeStudentRepository {
  Future<List<Evaluation>> getActiveEvaluations(String studentId, Set<String> submittedIds);
  Future<List<Course>> getEnrolledCourses(String studentId);
}
