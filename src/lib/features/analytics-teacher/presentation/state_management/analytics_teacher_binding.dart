import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:src/core/i_local_preferences.dart';
import '../../data/datasources/i_analytics_teacher_datasource.dart';
import '../../data/datasources/local_analytics_teacher_cache_source.dart';
import '../../data/datasources/remote_analytics_teacher_datasource.dart';
import '../../data/repositories/analytics_teacher_repository_impl.dart';
import '../../domain/repositories/i_analytics_teacher_repository.dart';
import '../../domain/usecases/get_teacher_analytics.dart';
import 'analytics_teacher_controller.dart';

class AnalyticsTeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LocalAnalyticsTeacherCacheSource(Get.find<ILocalPreferences>()),
    );

    Get.lazyPut<IAnalyticsTeacherDatasource>(
      () => RemoteAnalyticsTeacherDatasource(
        Get.find<http.Client>(tag: 'apiClient'),
      ),
    );

    Get.lazyPut<IAnalyticsTeacherRepository>(
      () => AnalyticsTeacherRepositoryImpl(Get.find(), Get.find()),
    );

    Get.lazyPut(() => GetTeacherAnalytics(Get.find()));

    Get.lazyPut(
      () => AnalyticsTeacherController(getTeacherAnalytics: Get.find()),
    );
  }
}
