import '../../domain/entities/create_evaluation_params.dart';
import '../../domain/repositories/i_create_evaluation_repository.dart';
import '../datasources/create_evaluation_datasource.dart';
import '../models/create_evaluation_model.dart';

class CreateEvaluationRepositoryImpl implements ICreateEvaluationRepository {
  final CreateEvaluationDatasource datasource;

  CreateEvaluationRepositoryImpl(this.datasource);

  @override
  Future<void> createEvaluation(CreateEvaluationParams params) =>
      datasource.createEvaluation(CreateEvaluationModel.fromEntity(params));
}
