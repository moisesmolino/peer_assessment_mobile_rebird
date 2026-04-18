import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:src/features/eval-form/data/datasources/eval_form_datasource.dart';
import 'package:src/features/eval-form/data/datasources/remote_eval_form_datasource.dart';
import 'package:src/features/eval-form/data/repositories/eval_form_repository_impl.dart';
import 'package:src/features/eval-form/domain/repositories/i_eval_form_repository.dart';
import 'package:src/features/eval-form/domain/usecases/get_group_peers.dart';
import 'package:src/features/eval-form/domain/usecases/get_submitted_evaluation_ids.dart';
import 'package:src/features/eval-form/domain/usecases/submit_peer_evaluation.dart';
import 'eval_form_controller.dart';

class EvalFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EvalFormDatasource>(
      () => RemoteEvalFormDatasource(Get.find<http.Client>(tag: 'apiClient')),
    );

    Get.lazyPut<IEvalFormRepository>(
      () => EvalFormRepositoryImpl(Get.find()),
    );

    Get.lazyPut(() => GetGroupPeers(Get.find()));
    Get.lazyPut(() => GetSubmittedEvaluationIds(Get.find()));
    Get.lazyPut(() => SubmitPeerEvaluation(Get.find()));

    Get.lazyPut(() => EvalFormController(
          getGroupPeers: Get.find(),
          submitPeerEvaluation: Get.find(),
        ));
  }
}
