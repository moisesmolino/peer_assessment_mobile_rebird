import '../../domain/entities/student_analytics.dart';
import '../../domain/repositories/i_analytics_student_repository.dart';
import '../datasources/i_analytics_student_datasource.dart';

class AnalyticsStudentRepositoryImpl implements IAnalyticsStudentRepository {
  final IAnalyticsStudentDatasource datasource;

  AnalyticsStudentRepositoryImpl(this.datasource);

  @override
  Future<StudentAnalytics?> getStudentAnalytics({
    required String evaluationId,
    required String evaluationName,
    required String courseName,
    required bool isPublic,
    required String studentEmail,
  }) async {
    final model = await datasource.fetchResults(
      evaluationId: evaluationId,
      studentEmail: studentEmail,
    );

    return model?.toEntity(
      evaluationName: evaluationName,
      courseName: courseName,
      isPublic: isPublic,
    );
  }
}
