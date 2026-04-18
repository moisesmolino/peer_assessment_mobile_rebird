import 'package:src/features/home-professor/domain/entities/course.dart';
import '../../domain/repositories/home_professor_repository.dart';
import '../datasources/home_professor_datasource.dart';

class HomeProfessorRepositoryImpl implements HomeProfessorRepository {
  final HomeProfessorDataSource datasource;

  HomeProfessorRepositoryImpl(this.datasource);

  @override
  Future<List<Course>> getAssignedCourses(String professorId) {
    return datasource.getAssignedCourses(professorId);
  }
}
