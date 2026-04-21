import '../../domain/entities/course_evaluation.dart';
import '../../domain/entities/group_category.dart';
import '../../domain/repositories/tap_course_repository.dart';
import '../datasources/local_tap_course_cache_source.dart';
import '../datasources/tap_course_datasource.dart';
import '../parsers/csv_group_parser.dart';

class TapCourseRepositoryImpl implements TapCourseRepository {
  final TapCourseDatasource datasource;
  final LocalTapCourseCacheSource cacheSource;
  final CsvGroupParser csvParser;

  TapCourseRepositoryImpl({
    required this.datasource,
    required this.cacheSource,
    required this.csvParser,
  });

  @override
  Future<List<CourseEvaluation>> getCourseEvaluations(String courseId) async {
    final isValid = await cacheSource.isCourseEvaluationsCacheValid(courseId);
    if (isValid) {
      final cached = await cacheSource.getCachedCourseEvaluations(courseId);
      if (cached != null) {
        return cached.map((model) => model.toEntity()).toList();
      }
    }

    final models = await datasource.getCourseEvaluations(courseId);
    await cacheSource.cacheCourseEvaluations(courseId, models);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<GroupCategory>> getCourseGroups(String courseId) async {
    final isValid = await cacheSource.isCourseGroupsCacheValid(courseId);
    if (isValid) {
      final cached = await cacheSource.getCachedCourseGroups(courseId);
      if (cached != null) {
        return cached.map((model) => model.toEntity()).toList();
      }
    }

    final models = await datasource.getCourseGroups(courseId);
    await cacheSource.cacheCourseGroups(courseId, models);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<GroupCategory>> importGroupsFromCsv(
    String csvContent,
    String courseId,
  ) async {
    final models = await datasource.importGroupsFromCsv(csvContent, courseId);
    return models.map((m) => m.toEntity()).toList();
  }
}
