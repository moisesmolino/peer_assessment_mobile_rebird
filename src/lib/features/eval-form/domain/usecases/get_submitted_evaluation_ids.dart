import '../repositories/i_eval_form_repository.dart';

class GetSubmittedEvaluationIds {
  final IEvalFormRepository repository;

  GetSubmittedEvaluationIds(this.repository);

  Future<Set<String>> call(String studentEmail) =>
      repository.getSubmittedEvaluationIds(studentEmail);
}
