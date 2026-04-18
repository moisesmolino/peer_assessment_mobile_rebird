import 'package:src/features/home-professor/domain/entities/course.dart';


abstract class HomeProfessorDataSource {
  Future<List<Course>> getAssignedCourses(String professorId);
}
