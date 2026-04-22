import '../entities/student_analytics.dart';
import '../repositories/i_analytics_student_repository.dart';

class GetStudentAnalytics {
  final IAnalyticsStudentRepository repository;

  GetStudentAnalytics(this.repository);

  Future<StudentAnalytics?> call({
    required String evaluationId,
    required String evaluationName,
    required String courseName,
    required bool isPublic,
    required String studentEmail,
  }) =>
      repository.getStudentAnalytics(
        evaluationId: evaluationId,
        evaluationName: evaluationName,
        courseName: courseName,
        isPublic: isPublic,
        studentEmail: studentEmail,
      );
}
