import '../models/student_analytics_model.dart';

abstract class IAnalyticsStudentDatasource {
  Future<StudentAnalyticsModel?> fetchResults({
    required String evaluationId,
    required String studentEmail,
  });
}
