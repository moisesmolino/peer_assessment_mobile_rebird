import '../entities/teacher_analytics.dart';
import '../repositories/i_analytics_teacher_repository.dart';

class GetTeacherAnalytics {
  final IAnalyticsTeacherRepository repository;

  GetTeacherAnalytics(this.repository);

  Future<TeacherAnalytics?> call({
    required String courseId,
    required String courseName,
    required Map<String, String> evalIdToName,
  }) =>
      repository.getCourseAnalytics(
        courseId: courseId,
        courseName: courseName,
        evalIdToName: evalIdToName,
      );
}
