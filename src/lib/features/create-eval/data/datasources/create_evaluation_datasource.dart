import '../models/create_evaluation_model.dart';

abstract class CreateEvaluationDatasource {
  Future<void> createEvaluation(CreateEvaluationModel model);
}
