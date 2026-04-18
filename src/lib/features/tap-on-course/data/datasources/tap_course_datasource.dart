import '../models/course_evaluation_model.dart';
import '../models/group_category_model.dart';

abstract class TapCourseDatasource {
  Future<List<CourseEvaluationModel>> getCourseEvaluations(String courseId);
  Future<List<GroupCategoryModel>> getCourseGroups(String courseId);
  Future<List<GroupCategoryModel>> importGroupsFromCsv(String csvContent, String courseId);
}