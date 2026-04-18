import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/create_evaluation_datasource.dart';
import '../../data/datasources/remote_create_evaluation_datasource.dart';
import '../../data/repositories/create_evaluation_repository_impl.dart';
import '../../domain/repositories/i_create_evaluation_repository.dart';
import '../../domain/usecases/create_evaluation.dart';
import 'create_evaluation_controller.dart';

class CreateEvaluationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateEvaluationDatasource>(
      () => RemoteCreateEvaluationDatasource(
        Get.find<http.Client>(tag: 'apiClient'),
      ),
    );

    Get.lazyPut<ICreateEvaluationRepository>(
      () => CreateEvaluationRepositoryImpl(Get.find()),
    );

    Get.lazyPut(() => CreateEvaluation(Get.find()));

    Get.lazyPut(
      () => CreateEvaluationController(
        createEvaluationUseCase: Get.find(),
      ),
    );
  }
}
