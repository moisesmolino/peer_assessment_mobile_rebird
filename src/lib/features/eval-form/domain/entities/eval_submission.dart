class EvalSubmission {
  final String evaluationId;
  final String evaluatorEmail;
  final String evaluatedEmail;
  final Map<String, double> scores; // criterionKey -> score
  final String? comment;

  const EvalSubmission({
    required this.evaluationId,
    required this.evaluatorEmail,
    required this.evaluatedEmail,
    required this.scores,
    this.comment,
  });
}
