import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/i_analytics_teacher_datasource.dart';
import '../../data/datasources/remote_analytics_teacher_datasource.dart';
import '../../data/repositories/analytics_teacher_repository_impl.dart';
import '../../domain/repositories/i_analytics_teacher_repository.dart';
import '../../domain/usecases/get_teacher_analytics.dart';
import 'analytics_teacher_controller.dart';

class AnalyticsTeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IAnalyticsTeacherDatasource>(
      () => RemoteAnalyticsTeacherDatasource(
        Get.find<http.Client>(tag: 'apiClient'),
      ),
    );

    Get.lazyPut<IAnalyticsTeacherRepository>(
      () => AnalyticsTeacherRepositoryImpl(Get.find()),
    );

    Get.lazyPut(() => GetTeacherAnalytics(Get.find()));

    Get.lazyPut(
      () => AnalyticsTeacherController(getTeacherAnalytics: Get.find()),
    );
  }
}
