import '../entities/eval_submission.dart';
import '../repositories/i_eval_form_repository.dart';

class SubmitPeerEvaluation {
  final IEvalFormRepository repository;

  SubmitPeerEvaluation(this.repository);

  Future<void> call(EvalSubmission submission) =>
      repository.submitEvaluation(submission);
}
