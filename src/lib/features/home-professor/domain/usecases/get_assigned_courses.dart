import '../entities/course.dart';
import '../repositories/home_professor_repository.dart';

class GetAssignedCourses {

  final HomeProfessorRepository repository;

  GetAssignedCourses(this.repository);

  Future<List<Course>> call(String professorId) {
    return repository.getAssignedCourses(professorId);
  }

}