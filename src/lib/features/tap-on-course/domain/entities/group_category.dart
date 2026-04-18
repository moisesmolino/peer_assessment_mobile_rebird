import 'course_group.dart';

class GroupCategory {
  final String name;
  final String source;
  final List<CourseGroup> groups;

  const GroupCategory({
    required this.name,
    required this.source,
    required this.groups,
  });
}
