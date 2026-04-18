import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/i_analytics_student_datasource.dart';
import '../../data/datasources/remote_analytics_student_datasource.dart';
import '../../data/repositories/analytics_student_repository_impl.dart';
import '../../domain/repositories/i_analytics_student_repository.dart';
import '../../domain/usecases/get_student_analytics.dart';
import 'analytics_student_controller.dart';

class AnalyticsStudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IAnalyticsStudentDatasource>(
      () => RemoteAnalyticsStudentDatasource(
        Get.find<http.Client>(tag: 'apiClient'),
      ),
    );

    Get.lazyPut<IAnalyticsStudentRepository>(
      () => AnalyticsStudentRepositoryImpl(Get.find()),
    );

    Get.lazyPut(() => GetStudentAnalytics(Get.find()));

    Get.lazyPut(
      () => AnalyticsStudentController(getStudentAnalytics: Get.find()),
    );
  }
}
