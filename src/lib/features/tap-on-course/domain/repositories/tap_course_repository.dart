import '../entities/course_evaluation.dart';
import '../entities/group_category.dart';

abstract class TapCourseRepository {
  Future<List<CourseEvaluation>> getCourseEvaluations(String courseId);
  Future<List<GroupCategory>> getCourseGroups(String courseId);
  Future<List<GroupCategory>> importGroupsFromCsv(String csvContent, String courseId);
}
