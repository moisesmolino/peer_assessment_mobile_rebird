import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/create_evaluation_params.dart';
import '../../domain/usecases/create_evaluation.dart';
import 'package:src/features/tap-on-course/domain/entities/group_category.dart';
import 'package:src/features/tap-on-course/presentation/models/course_ui.dart';

class CreateEvaluationController extends GetxController {
  final CreateEvaluation createEvaluationUseCase;

  CreateEvaluationController({required this.createEvaluationUseCase});

  late final CourseUI course;
  late final List<String> groupCategoryNames;

  final nameController = TextEditingController();
  final RxnString selectedGroup = RxnString();
  final Rx<DateTime> deadline =
      DateTime.now().add(const Duration(days: 7)).obs;
  final RxString visibility = 'public'.obs;
  final RxBool isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    course = args['course'] as CourseUI;
    final categories = args['groupCategories'] as List<GroupCategory>;
    groupCategoryNames = categories.map((c) => c.name).toList();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void selectGroup(String? name) => selectedGroup.value = name;
  void selectVisibility(String value) => visibility.value = value;
  void setDeadline(DateTime dt) => deadline.value = dt;

  bool get isFormValid =>
      nameController.text.trim().isNotEmpty && selectedGroup.value != null;

  Future<void> onCreateTapped() async {
    if (!isCreating.value && isFormValid) {
      isCreating.value = true;
      final params = CreateEvaluationParams(
        name: nameController.text.trim(),
        courseId: course.id,
        groupCategoryName: selectedGroup.value!,
        deadline: deadline.value,
        visibility: visibility.value,
      );
      await createEvaluationUseCase(params);
      isCreating.value = false;
      Get.back(result: true);
    }
  }
}
