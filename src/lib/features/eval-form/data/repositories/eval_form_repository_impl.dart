import 'package:src/features/eval-form/data/datasources/eval_form_datasource.dart';
import 'package:src/features/eval-form/data/models/eval_submission_model.dart';
import 'package:src/features/eval-form/domain/entities/eval_peer.dart';
import 'package:src/features/eval-form/domain/entities/eval_submission.dart';
import 'package:src/features/eval-form/domain/repositories/i_eval_form_repository.dart';

class EvalFormRepositoryImpl implements IEvalFormRepository {
  final EvalFormDatasource datasource;

  EvalFormRepositoryImpl(this.datasource);

  @override
  Future<List<EvalPeer>> getGroupPeers(
    String groupCategory,
    String studentEmail,
  ) async {
    final models = await datasource.getGroupPeers(groupCategory, studentEmail);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> submitEvaluation(EvalSubmission submission) =>
      datasource.submitEvaluation(EvalSubmissionModel.fromEntity(submission));

  @override
  Future<Set<String>> getSubmittedEvaluationIds(String studentEmail) =>
      datasource.getSubmittedEvaluationIds(studentEmail);
}
