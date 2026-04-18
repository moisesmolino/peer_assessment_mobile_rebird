import '../models/eval_peer_model.dart';
import '../models/eval_submission_model.dart';
//diosmio
abstract class EvalFormDatasource {
  Future<List<EvalPeerModel>> getGroupPeers(String groupCategory, String studentEmail);
  Future<void> submitEvaluation(EvalSubmissionModel model);
  Future<Set<String>> getSubmittedEvaluationIds(String studentEmail);
}
