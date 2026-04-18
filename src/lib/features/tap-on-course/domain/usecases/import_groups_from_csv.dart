import '../entities/group_category.dart';
import '../repositories/tap_course_repository.dart';

class ImportGroupsFromCsv {
  final TapCourseRepository repository;
  ImportGroupsFromCsv(this.repository);

  Future<List<GroupCategory>> call(String csvContent, String courseId) { 
    return repository.importGroupsFromCsv(csvContent, courseId);
  }
}
