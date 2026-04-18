import 'package:src/features/eval-form/domain/entities/eval_submission.dart';

class EvalSubmissionModel {
  final String evaluationId;
  final String evaluatorEmail;
  final String evaluatedEmail;
  final Map<String, double> scores;
  final String? comment;

  EvalSubmissionModel.fromEntity(EvalSubmission entity)
      : evaluationId = entity.evaluationId,
        evaluatorEmail = entity.evaluatorEmail,
        evaluatedEmail = entity.evaluatedEmail,
        scores = entity.scores,
        comment = entity.comment;

  Map<String, dynamic> toJson() => {
        'evaluation_id': evaluationId,
        'evaluator_email': evaluatorEmail,
        'evaluated_email': evaluatedEmail,
        'punctuality': scores['punctuality'],
        'contributions': scores['contributions'],
        'commitment': scores['commitment'],
        'attitude': scores['attitude'],
        if (comment != null && comment!.isNotEmpty) 'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      };
}
