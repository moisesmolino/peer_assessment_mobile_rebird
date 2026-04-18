import '../models/teacher_analytics_model.dart';

abstract class IAnalyticsTeacherDatasource {
  Future<TeacherAnalyticsModel?> fetchCourseAnalytics({
    required String courseId,
    required Map<String, String> evalIdToName,
  });
}
