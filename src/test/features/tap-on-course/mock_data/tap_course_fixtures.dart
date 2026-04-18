import 'package:src/features/tap-on-course/domain/entities/course_evaluation.dart';
import 'package:src/features/tap-on-course/domain/entities/course_group.dart';
import 'package:src/features/tap-on-course/domain/entities/group_category.dart';
import 'package:src/features/tap-on-course/domain/entities/group_member.dart';

CourseEvaluation buildCourseEvaluation({
  String id = 'ce-1',
  String name = 'Iteration 1 Evaluation',
  String status = 'active',
  String visibility = 'public',
  String groupCategory = 'Section A',
  DateTime? deadline,
}) {
  return CourseEvaluation(
    id: id,
    name: name,
    status: status,
    visibility: visibility,
    groupCategory: groupCategory,
    deadline: deadline ?? DateTime(2026, 5, 12, 9, 30),
  );
}

GroupMember buildMember({
  String firstName = 'Ana',
  String lastName = 'Ruiz',
  String email = 'ana@example.com',
}) {
  return GroupMember(firstName: firstName, lastName: lastName, email: email);
}

CourseGroup buildCourseGroup({
  String name = 'Team Rocket',
  String code = 'TR-1',
  List<GroupMember>? members,
}) {
  return CourseGroup(
    name: name,
    code: code,
    members:
        members ??
        [
          buildMember(),
          buildMember(
            firstName: 'Luis',
            lastName: 'Gomez',
            email: 'luis@example.com',
          ),
        ],
  );
}

GroupCategory buildGroupCategory({
  String name = 'Lab Group',
  String source = 'CSV',
  List<CourseGroup>? groups,
}) {
  return GroupCategory(
    name: name,
    source: source,
    groups: groups ?? [buildCourseGroup()],
  );
}
