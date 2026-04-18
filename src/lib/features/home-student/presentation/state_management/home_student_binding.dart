import 'package:get/get.dart';
import 'package:src/features/eval-form/presentation/state_management/eval_form_binding.dart';
import '../../domain/usecases/get_active_evaluations.dart';
import '../../domain/usecases/get_enrolled_courses.dart';
import 'home_student_controller.dart';

class HomeStudentBinding extends Bindings {
  @override
  void dependencies() {
    EvalFormBinding().dependencies();

    Get.lazyPut(() => GetActiveEvaluations(Get.find()));
    Get.lazyPut(() => GetEnrolledCourses(Get.find()));
    Get.lazyPut(
      () => HomeStudentController(
        getActiveEvaluations: Get.find(),
        getEnrolledCourses: Get.find(),
        getSubmittedEvaluationIds: Get.find(),
      ),
    );
  }
}
