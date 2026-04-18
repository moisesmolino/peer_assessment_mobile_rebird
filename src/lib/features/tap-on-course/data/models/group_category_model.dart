import '../../domain/entities/course_group.dart';
import '../../domain/entities/group_category.dart';
import '../../domain/entities/group_member.dart';

class GroupMemberModel {
  final String firstName;
  final String lastName;
  final String email;

  const GroupMemberModel({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  GroupMember toEntity() => GroupMember(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
}

class CourseGroupModel {
  final String name;
  final String code;
  final List<GroupMemberModel> members;

  const CourseGroupModel({
    required this.name,
    required this.code,
    required this.members,
  });

  CourseGroup toEntity() => CourseGroup(
        name: name,
        code: code,
        members: members.map((m) => m.toEntity()).toList(),
      );
}

class GroupCategoryModel {
  final String name;
  final String source;
  final List<CourseGroupModel> groups;

  const GroupCategoryModel({
    required this.name,
    required this.source,
    required this.groups,
  });

  GroupCategory toEntity() => GroupCategory(
        name: name,
        source: source,
        groups: groups.map((g) => g.toEntity()).toList(),
      );
}
