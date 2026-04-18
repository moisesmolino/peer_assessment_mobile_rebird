import '../entities/student_analytics.dart';

abstract class IAnalyticsStudentRepository {
  Future<StudentAnalytics?> getStudentAnalytics({
    required String evaluationId,
    required String evaluationName,
    required String courseName,
    required bool isPublic,
    required String studentEmail,
  });
}
