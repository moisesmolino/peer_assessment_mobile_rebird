import 'package:get/get.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import '../../domain/entities/student_analytics.dart';
import '../../domain/usecases/get_student_analytics.dart';

class AnalyticsStudentController extends GetxController {
  final GetStudentAnalytics getStudentAnalytics;

  AnalyticsStudentController({required this.getStudentAnalytics});

  final RxBool isLoading = true.obs;
  final Rxn<StudentAnalytics> analytics = Rxn<StudentAnalytics>();
  final RxBool hasNoData = false.obs;

  late final String _evaluationId;
  late final String _evaluationName;
  late final String _courseName;
  late final bool _isPublic;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    _evaluationId = args['evaluationId'] as String;
    _evaluationName = args['evaluationName'] as String;
    _courseName = args['courseName'] as String;
    _isPublic = args['isPublic'] as bool;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final studentEmail =
        Get.find<UserController>().loggedUser?.email ?? '';

    final result = await getStudentAnalytics(
      evaluationId: _evaluationId,
      evaluationName: _evaluationName,
      courseName: _courseName,
      isPublic: _isPublic,
      studentEmail: studentEmail,
    );

    analytics.value = result;
    hasNoData.value = result == null;
    isLoading.value = false;
  }

  String get evaluationName => _evaluationName;
  String get courseName => _courseName;
}
