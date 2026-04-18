import 'group_member.dart';

class CourseGroup {
  final String name;
  final String code;
  final List<GroupMember> members;

  const CourseGroup({
    required this.name,
    required this.code,
    required this.members,
  });
}
