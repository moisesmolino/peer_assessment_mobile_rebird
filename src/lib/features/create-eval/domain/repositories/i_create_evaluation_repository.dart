import '../entities/create_evaluation_params.dart';

abstract class ICreateEvaluationRepository {
  Future<void> createEvaluation(CreateEvaluationParams params);
}
