import '../models/evaluation_model.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/home_student_repository.dart';
import '../datasources/home_student_datasource.dart';

class HomeStudentRepositoryImpl implements HomeStudentRepository {
  final HomeStudentDataSource dataSource;

  HomeStudentRepositoryImpl(this.dataSource);

  @override
  Future<List<EvaluationModel>> getActiveEvaluations(String studentId, Set<String> submittedIds) {
    return dataSource.getActiveEvaluations(studentId, submittedIds);
  }

  @override
  Future<List<Course>> getEnrolledCourses(String studentId) {
    return dataSource.getEnrolledCourses(studentId);
  }
}
