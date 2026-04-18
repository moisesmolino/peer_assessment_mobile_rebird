import '../entities/eval_peer.dart';
import '../repositories/i_eval_form_repository.dart';

class GetGroupPeers {
  final IEvalFormRepository repository;

  GetGroupPeers(this.repository);

  Future<List<EvalPeer>> call(String groupCategory, String studentEmail) =>
      repository.getGroupPeers(groupCategory, studentEmail);
}
