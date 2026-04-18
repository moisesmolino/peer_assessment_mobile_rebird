import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/course_evaluation.dart';
import '../../domain/entities/group_category.dart';
import '../../domain/usecases/get_course_evaluations.dart';
import '../../domain/usecases/get_course_groups.dart';
import 'package:src/features/eval-form/domain/usecases/get_submitted_evaluation_ids.dart';
import '../../domain/usecases/import_groups_from_csv.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import 'package:src/features/analytics-student/presentation/pages/analytics_student_page.dart';
import 'package:src/features/analytics-student/presentation/state_management/analytics_student_binding.dart';
import 'package:src/features/analytics-teacher/presentation/pages/analytics_teacher_page.dart';
import 'package:src/features/analytics-teacher/presentation/state_management/analytics_teacher_binding.dart';
import 'package:src/features/create-eval/presentation/pages/create_evaluation_page.dart';
import 'package:src/features/create-eval/presentation/state_management/create_evaluation_binding.dart';
import 'package:src/features/eval-form/presentation/pages/eval_form_page.dart';
import 'package:src/features/eval-form/presentation/state_management/eval_form_binding.dart';
import '../models/course_ui.dart';

class TapCourseController extends GetxController {
  final GetCourseEvaluations getCourseEvaluations;
  final GetCourseGroups getCourseGroups;
  final ImportGroupsFromCsv importGroupsFromCsv;
  final GetSubmittedEvaluationIds getSubmittedEvaluationIds;

  TapCourseController({
    required this.getCourseEvaluations,
    required this.getCourseGroups,
    required this.importGroupsFromCsv,
    required this.getSubmittedEvaluationIds,
  });

  late final CourseUI course;
  late final bool isProfessor;

  final RxInt selectedTab = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isImporting = false.obs;

  final RxList<CourseEvaluation> evaluations = <CourseEvaluation>[].obs;
  final RxList<GroupCategory> groupCategories = <GroupCategory>[].obs;
  final Set<String> _submittedIds = {};

  bool isSubmitted(String evaluationId) => _submittedIds.contains(evaluationId);

  // Enrollment code derived from course data (mocked)
  String get enrollmentCode => 'DS-${course.period.split('-')[0]}-xka';

  int get groupCategoriesCount => groupCategories.length;

  @override
  void onInit() {
    super.onInit();
    isProfessor = !Get.find<UserController>().isStudent.value;
    course = Get.arguments as CourseUI;
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    final evals = await getCourseEvaluations(course.id);
    final groups = await getCourseGroups(course.id);
    evaluations.assignAll(evals);
    groupCategories.assignAll(groups);
    if (!isProfessor) {
      final studentEmail =
          Get.find<UserController>().loggedUser?.email ?? '';
      final ids = await getSubmittedEvaluationIds(studentEmail);
      _submittedIds.addAll(ids);
    }
    isLoading.value = false;
  }

  void selectTab(int index) => selectedTab.value = index;

  /// Called when the professor taps "+Add groups".
  /// Opens the system file picker so the user can select a CSV export.
  Future<void> onAddGroupsTapped() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    isImporting.value = true;

    final csvContent = String.fromCharCodes(result.files.single.bytes!);

  final imported = await importGroupsFromCsv(csvContent, course.id); 

    // Avoid duplicating a category that was already imported
    for (final newCat in imported) {
      final alreadyExists = groupCategories.any((c) => c.name == newCat.name);
      if (!alreadyExists) {
        groupCategories.add(newCat);
      }
    }

    isImporting.value = false;

    Get.snackbar(
      'Groups imported',
      '${imported.length} group ${imported.length == 1 ? 'category' : 'categories'} added from Brightspace.',
      backgroundColor: const Color(0xFF3A2016),
      colorText: const Color(0xFFFF8C60),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  void onEvaluateTapped(CourseEvaluation evaluation) {
    EvalFormBinding().dependencies();
    Get.to(
      () => const EvalFormPage(),
      arguments: {
        'evaluation': evaluation,
        'courseName': course.name,
      },
    );
  }

  void onViewResultsTapped(CourseEvaluation evaluation) {
    AnalyticsStudentBinding().dependencies();
    Get.to(
      () => const AnalyticsStudentPage(),
      arguments: {
        'evaluationId': evaluation.id,
        'evaluationName': evaluation.name,
        'courseName': course.name,
        'isPublic': evaluation.visibility == 'public',
      },
    );
  }

  void onViewEvaluationResultsTapped(CourseEvaluation evaluation) {
    AnalyticsTeacherBinding().dependencies();
    Get.to(
      () => const AnalyticsTeacherPage(),
      arguments: {
        'courseId': course.id,
        'courseName': course.name,
        'evalIdToName': {evaluation.id: evaluation.name},
      },
    );
  }

  void onViewTeacherAnalyticsTapped() {
    AnalyticsTeacherBinding().dependencies();
    Get.to(
      () => const AnalyticsTeacherPage(),
      arguments: {
        'courseId': course.id,
        'courseName': course.name,
        'evalIdToName': Map.fromEntries(
          evaluations.map((e) => MapEntry(e.id, e.name)),
        ),
      },
    );
  }

  Future<void> onCreateEvaluationTapped() async {
    CreateEvaluationBinding().dependencies();
    final created = await Get.to(
      () => const CreateEvaluationPage(),
      arguments: {
        'course': course,
        'groupCategories': groupCategories.toList(),
      },
    );
    if (created == true) {
      final evals = await getCourseEvaluations(course.id);
      evaluations.assignAll(evals);
    }
  }
}
