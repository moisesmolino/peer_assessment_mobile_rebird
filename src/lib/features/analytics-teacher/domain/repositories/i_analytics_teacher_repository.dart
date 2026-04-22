import '../entities/teacher_analytics.dart';

abstract class IAnalyticsTeacherRepository {
  Future<TeacherAnalytics?> getCourseAnalytics({
    required String courseId,
    required String courseName,
    required Map<String, String> evalIdToName,
  });
}
