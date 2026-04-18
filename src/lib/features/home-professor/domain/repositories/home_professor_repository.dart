import '../entities/course.dart';

abstract class HomeProfessorRepository {
  Future<List<Course>> getAssignedCourses(String professorId);
}
