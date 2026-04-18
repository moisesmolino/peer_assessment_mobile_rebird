import '../entities/course.dart';
import '../repositories/home_student_repository.dart';

class GetEnrolledCourses {
  final HomeStudentRepository repository;

  GetEnrolledCourses(this.repository);

  Future<List<Course>> call(String studentId) {
    return repository.getEnrolledCourses(studentId);
  }
}
