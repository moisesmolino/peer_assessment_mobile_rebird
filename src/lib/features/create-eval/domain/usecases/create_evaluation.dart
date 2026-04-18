import '../entities/create_evaluation_params.dart';
import '../repositories/i_create_evaluation_repository.dart';

class CreateEvaluation {
  final ICreateEvaluationRepository repository;

  CreateEvaluation(this.repository);

  Future<void> call(CreateEvaluationParams params) =>
      repository.createEvaluation(params);
}
