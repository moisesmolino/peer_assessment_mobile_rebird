import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:src/core/i_local_preferences.dart';
import '../../domain/entities/course.dart';
import '../../domain/usecases/get_assigned_courses.dart';
import 'package:src/features/tap-on-course/presentation/pages/tap_course_page.dart';
import 'package:src/features/tap-on-course/presentation/state_management/tap_course_binding.dart';
import 'package:src/features/tap-on-course/presentation/models/course_ui.dart';

class HomeProfessorController extends GetxController {
  final GetAssignedCourses getAssignedCourses;

  HomeProfessorController({required this.getAssignedCourses});

  final RxString professorName = "default user".obs;
  final RxList<Course> courses = <Course>[].obs;
  final RxInt coursesCount = 0.obs;
  final RxInt studentsCount = 0.obs;
  final RxInt activeEvaluations = 0.obs;
  final ILocalPreferences sharedPreferences = Get.find();

  String get professorInitials {
    final parts = professorName.value.split(" ");
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return professorName.value[0].toUpperCase();
  }

  @override
  void onInit() {
    super.onInit();
    loadCourses();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userName = await sharedPreferences.getString('userName');

    if (userName != null) {
      professorName.value = userName;
    }
  }

  Future<void> loadCourses() async {
    final userId = await sharedPreferences.getString('userId');
    if (userId == null) {
      logError("userId is null");
      return;
    }
    final result = await getAssignedCourses(userId);

    courses.assignAll(result);
    coursesCount.value = courses.length;
    studentsCount.value = courses.fold(0, (sum, c) => sum + c.studentsCount);
    activeEvaluations.value = courses.fold(
      0,
      (sum, c) => sum + c.activeEvaluations,
    );
  }

  void navigateToCourse(Course course) {
    TapCourseBinding().dependencies();
    Get.to(
      () => const TapCoursePage(),
      arguments: CourseUI(
        id: course.id,
        code: course.code,
        name: course.name,
        period: course.period,
        studentsCount: course.studentsCount,
        activeEvaluations: course.activeEvaluations,
      ),
    );
  }
}
