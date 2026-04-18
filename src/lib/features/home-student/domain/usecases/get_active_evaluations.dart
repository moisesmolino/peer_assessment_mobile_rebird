import '../entities/evaluation.dart';
import '../repositories/home_student_repository.dart';

class GetActiveEvaluations {
  final HomeStudentRepository repository;

  GetActiveEvaluations(this.repository);

  Future<List<Evaluation>> call(String studentId, Set<String> submittedIds) {
    return repository.getActiveEvaluations(studentId, submittedIds);
  }
}
