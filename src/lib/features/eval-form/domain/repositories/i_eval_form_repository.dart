import '../entities/eval_peer.dart';
import '../entities/eval_submission.dart';

abstract class IEvalFormRepository {
  Future<List<EvalPeer>> getGroupPeers(String groupCategory, String studentEmail);
  Future<void> submitEvaluation(EvalSubmission submission);
  Future<Set<String>> getSubmittedEvaluationIds(String studentEmail);
}
