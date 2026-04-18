import '../../domain/entities/course_evaluation.dart';
import '../../domain/entities/group_category.dart';
import '../../domain/repositories/tap_course_repository.dart';
import '../datasources/tap_course_datasource.dart';
import '../parsers/csv_group_parser.dart';

class TapCourseRepositoryImpl implements TapCourseRepository {
  final TapCourseDatasource datasource;
  final CsvGroupParser csvParser;

  TapCourseRepositoryImpl({required this.datasource, required this.csvParser});

  @override
  Future<List<CourseEvaluation>> getCourseEvaluations(String courseId) async {
    final models = await datasource.getCourseEvaluations(courseId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<GroupCategory>> getCourseGroups(String courseId) async {
    final models = await datasource.getCourseGroups(courseId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<GroupCategory>> importGroupsFromCsv(String csvContent, String courseId) async {
    final models = await datasource.importGroupsFromCsv(csvContent, courseId);
    return models.map((m) => m.toEntity()).toList();
  }

}
