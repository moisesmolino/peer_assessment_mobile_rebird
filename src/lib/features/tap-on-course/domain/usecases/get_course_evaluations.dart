import '../entities/course_evaluation.dart';
import '../repositories/tap_course_repository.dart';

class GetCourseEvaluations {
  final TapCourseRepository repository;

  GetCourseEvaluations(this.repository);

  Future<List<CourseEvaluation>> call(String courseId) {
    return repository.getCourseEvaluations(courseId);
  }
}
