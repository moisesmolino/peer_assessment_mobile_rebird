import '../entities/group_category.dart';
import '../repositories/tap_course_repository.dart';

class GetCourseGroups {
  final TapCourseRepository repository;

  GetCourseGroups(this.repository);

  Future<List<GroupCategory>> call(String courseId) {
    return repository.getCourseGroups(courseId);
  }
}
