import 'package:src/features/analytics-teacher/domain/entities/teacher_analytics.dart';
import 'package:src/features/analytics-teacher/presentation/widgets/bar_chart_widget.dart';

StudentSummary buildStudentSummary({
  String email = 'sam@example.com',
  String displayName = 'Sam Carter',
  double punctuality = 4.5,
  double contributions = 3.8,
  double commitment = 4.0,
  double attitude = 4.2,
  List<StudentComment> comments = const [
    StudentComment(evaluatorEmail: 'peer1@example.com', text: 'Great teammate'),
  ],
}) {
  return StudentSummary(
    email: email,
    displayName: displayName,
    punctuality: punctuality,
    contributions: contributions,
    commitment: commitment,
    attitude: attitude,
    comments: comments,
  );
}

List<BarChartEntry> buildBarEntries() {
  return const [
    BarChartEntry(label: 'A1', value: 4.1),
    BarChartEntry(label: 'A2', value: 3.6),
    BarChartEntry(label: 'A3', value: 4.8),
    BarChartEntry(label: 'A4', value: 2),
  ];
}
