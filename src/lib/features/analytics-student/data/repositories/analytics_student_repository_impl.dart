import '../../domain/entities/student_analytics.dart';
import '../../domain/repositories/i_analytics_student_repository.dart';
import '../datasources/i_analytics_student_datasource.dart';
import '../datasources/local_analytics_student_cache_source.dart';

class AnalyticsStudentRepositoryImpl implements IAnalyticsStudentRepository {
  final IAnalyticsStudentDatasource datasource;
  final LocalAnalyticsStudentCacheSource cacheSource;

  AnalyticsStudentRepositoryImpl(this.datasource, this.cacheSource);

  @override
  Future<StudentAnalytics?> getStudentAnalytics({
    required String evaluationId,
    required String evaluationName,
    required String courseName,
    required bool isPublic,
    required String studentEmail,
  }) async {
    // Check if cache is valid
    final isCacheValid = await cacheSource.isCacheValid(
      evaluationId,
      studentEmail,
    );
    if (isCacheValid) {
      final cachedModel = await cacheSource.getCachedAnalyticsData(
        evaluationId,
        studentEmail,
      );
      if (cachedModel != null) {
        return cachedModel.toEntity(
          evaluationName: evaluationName,
          courseName: courseName,
          isPublic: isPublic,
        );
      }
    }

    // Fetch from remote if cache miss or expired
    final model = await datasource.fetchResults(
      evaluationId: evaluationId,
      studentEmail: studentEmail,
    );

    if (model != null) {
      // Cache the model data
      await cacheSource.cacheAnalyticsData(evaluationId, studentEmail, model);
    }

    return model?.toEntity(
      evaluationName: evaluationName,
      courseName: courseName,
      isPublic: isPublic,
    );
  }
}
