import '../../domain/entities/teacher_analytics.dart';
import '../../domain/repositories/i_analytics_teacher_repository.dart';
import '../datasources/i_analytics_teacher_datasource.dart';
import '../datasources/local_analytics_teacher_cache_source.dart';

class AnalyticsTeacherRepositoryImpl implements IAnalyticsTeacherRepository {
  final IAnalyticsTeacherDatasource datasource;
  final LocalAnalyticsTeacherCacheSource cacheSource;

  AnalyticsTeacherRepositoryImpl(this.datasource, this.cacheSource);

  @override
  Future<TeacherAnalytics?> getCourseAnalytics({
    required String courseId,
    required String courseName,
    required Map<String, String> evalIdToName,
  }) async {
    final isCacheValid = await cacheSource.isCacheValid(courseId, evalIdToName);
    if (isCacheValid) {
      final cachedModel = await cacheSource.getCachedCourseAnalyticsData(
        courseId,
        evalIdToName,
      );
      if (cachedModel != null) {
        return cachedModel.toEntity(courseName: courseName);
      }
    }

    final model = await datasource.fetchCourseAnalytics(
      courseId: courseId,
      evalIdToName: evalIdToName,
    );

    if (model != null) {
      await cacheSource.cacheCourseAnalyticsData(courseId, evalIdToName, model);
    }

    return model?.toEntity(courseName: courseName);
  }
}
