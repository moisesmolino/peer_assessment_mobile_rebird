import 'package:get/get.dart';
import '../../domain/entities/teacher_analytics.dart';
import '../../domain/usecases/get_teacher_analytics.dart';

class AnalyticsTeacherController extends GetxController {
  final GetTeacherAnalytics getTeacherAnalytics;

  AnalyticsTeacherController({required this.getTeacherAnalytics});

  final RxBool isLoading = true.obs;
  final Rxn<TeacherAnalytics> analytics = Rxn<TeacherAnalytics>();
  final RxBool hasNoData = false.obs;

  late final String _courseId;
  late final String _courseName;
  late final Map<String, String> _evalIdToName;

  final RxString expandedEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    _courseId = args['courseId'] as String;
    _courseName = args['courseName'] as String;
    _evalIdToName = Map<String, String>.from(args['evalIdToName'] as Map);
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final result = await getTeacherAnalytics(
      courseId: _courseId,
      courseName: _courseName,
      evalIdToName: _evalIdToName,
    );
    analytics.value = result;
    hasNoData.value = result == null;
    isLoading.value = false;
  }

  void toggleStudent(String email) {
    expandedEmail.value = expandedEmail.value == email ? '' : email;
  }

  String get courseName => _courseName;

  String get subtitle =>
      _evalIdToName.length == 1 ? _evalIdToName.values.first : _courseName;
}
