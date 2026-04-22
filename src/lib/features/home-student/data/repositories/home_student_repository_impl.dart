import '../models/evaluation_model.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/home_student_repository.dart';
import '../datasources/home_student_datasource.dart';
import '../datasources/local_home_student_cache_source.dart';

class HomeStudentRepositoryImpl implements HomeStudentRepository {
  final HomeStudentDataSource dataSource;
  final LocalHomeStudentCacheSource cacheSource;

  HomeStudentRepositoryImpl(this.dataSource, this.cacheSource);

  @override
  Future<List<EvaluationModel>> getActiveEvaluations(
    String studentId,
    Set<String> submittedIds,
  ) async {
    final isValid = await cacheSource.isActiveEvaluationsCacheValid(studentId);
    if (isValid) {
      final cached = await cacheSource.getCachedActiveEvaluations(studentId);
      if (cached != null) {
        return cached
            .where((evaluation) => !submittedIds.contains(evaluation.id))
            .toList();
      }
    }

    final remote = await dataSource.getActiveEvaluations(studentId, {});
    if (remote.isNotEmpty) {
      await cacheSource.cacheActiveEvaluations(studentId, remote);
    }

    return remote
        .where((evaluation) => !submittedIds.contains(evaluation.id))
        .toList();
  }

  @override
  Future<List<Course>> getEnrolledCourses(String studentId) async {
    final isValid = await cacheSource.isEnrolledCoursesCacheValid(studentId);
    if (isValid) {
      final cached = await cacheSource.getCachedEnrolledCourses(studentId);
      if (cached != null) return cached;
    }

    final remote = await dataSource.getEnrolledCourses(studentId);
    if (remote.isNotEmpty) {
      await cacheSource.cacheEnrolledCourses(studentId, remote);
    }
    return remote;
  }
}
