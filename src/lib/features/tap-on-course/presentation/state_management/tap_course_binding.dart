import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:src/features/eval-form/presentation/state_management/eval_form_binding.dart';
import '../../data/datasources/tap_course_datasource.dart';
import '../../data/datasources/remote_tap_course_datasource.dart';
import '../../data/parsers/csv_group_parser.dart';
import '../../data/repositories/tap_course_repository_impl.dart';
import '../../domain/repositories/tap_course_repository.dart';
import '../../domain/usecases/get_course_evaluations.dart';
import '../../domain/usecases/get_course_groups.dart';
import '../../domain/usecases/import_groups_from_csv.dart';
import 'tap_course_controller.dart';

class TapCourseBinding extends Bindings {
  @override
  void dependencies() {
    EvalFormBinding().dependencies();

    Get.lazyPut(() => CsvGroupParser());

    Get.lazyPut<TapCourseDatasource>(
      () => RemoteTapCourseDatasource(
        Get.find<http.Client>(tag: 'apiClient'),
        Get.find(),
      ),
    );

    Get.lazyPut<TapCourseRepository>(
      () => TapCourseRepositoryImpl(
        datasource: Get.find(),
        csvParser: Get.find(),
      ),
    );

    Get.lazyPut(() => GetCourseEvaluations(Get.find()));
    Get.lazyPut(() => GetCourseGroups(Get.find()));
    Get.lazyPut(() => ImportGroupsFromCsv(Get.find()));

    Get.lazyPut(
      () => TapCourseController(
        getCourseEvaluations: Get.find(),
        getCourseGroups: Get.find(),
        importGroupsFromCsv: Get.find(),
        getSubmittedEvaluationIds: Get.find(),
      ),
    );
  }
}