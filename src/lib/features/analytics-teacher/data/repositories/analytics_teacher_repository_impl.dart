import '../../domain/entities/teacher_analytics.dart';
import '../../domain/repositories/i_analytics_teacher_repository.dart';
import '../datasources/i_analytics_teacher_datasource.dart';

class AnalyticsTeacherRepositoryImpl implements IAnalyticsTeacherRepository {
  final IAnalyticsTeacherDatasource datasource;

  AnalyticsTeacherRepositoryImpl(this.datasource);

  @override
  Future<TeacherAnalytics?> getCourseAnalytics({
    required String courseId,
    required String courseName,
    required Map<String, String> evalIdToName,
  }) async {
    final model = await datasource.fetchCourseAnalytics(
      courseId: courseId,
      evalIdToName: evalIdToName,
    );
    return model?.toEntity(courseName: courseName);
  }
}
