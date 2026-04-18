import '../../domain/entities/teacher_analytics.dart';

class TeacherAnalyticsModel {
  final List<Map<String, dynamic>> rows;
  final Map<String, String> emailToDisplayName;
  final Map<String, String> emailToGroupName;
  final Map<String, String> evalIdToName;

  const TeacherAnalyticsModel({
    required this.rows,
    required this.emailToDisplayName,
    required this.emailToGroupName,
    required this.evalIdToName,
  });

  TeacherAnalytics toEntity({required String courseName}) {
    if (rows.isEmpty) {
      return TeacherAnalytics(
        courseName: courseName,
        perActivity: [],
        perGroup: [],
        perStudent: [],
      );
    }

    double _avg(Iterable<Map<String, dynamic>> subset) {
      if (subset.isEmpty) return 0;
      final scores = subset.map((r) {
        final p = (r['punctuality'] as num).toDouble();
        final c = (r['contributions'] as num).toDouble();
        final cm = (r['commitment'] as num).toDouble();
        final a = (r['attitude'] as num).toDouble();
        return (p + c + cm + a) / 4;
      });
      return scores.reduce((a, b) => a + b) / scores.length;
    }

    double _criterion(Iterable<Map<String, dynamic>> subset, String key) {
      if (subset.isEmpty) return 0;
      return subset.map((r) => (r[key] as num).toDouble()).reduce((a, b) => a + b) /
          subset.length;
    }

    // Per activity
    final perActivity = evalIdToName.entries.map((e) {
      final subset = rows.where((r) => r['evaluation_id']?.toString() == e.key);
      return ActivityAverage(evaluationName: e.value, avgScore: _avg(subset));
    }).toList();

    // Per group
    final Map<String, List<Map<String, dynamic>>> byGroup = {};
    for (final row in rows) {
      final email = row['evaluated_email'] as String? ?? '';
      final group = emailToGroupName[email] ?? 'Unknown';
      byGroup.putIfAbsent(group, () => []).add(row);
    }
    final perGroup = byGroup.entries
        .map((e) => GroupAverage(groupName: e.key, avgScore: _avg(e.value)))
        .toList();

    // Per student
    final Map<String, List<Map<String, dynamic>>> byStudent = {};
    for (final row in rows) {
      final email = row['evaluated_email'] as String? ?? '';
      byStudent.putIfAbsent(email, () => []).add(row);
    }
    final perStudent = byStudent.entries.map((e) {
      final subset = e.value;
      return StudentSummary(
        email: e.key,
        displayName: emailToDisplayName[e.key] ?? e.key,
        punctuality: _criterion(subset, 'punctuality'),
        contributions: _criterion(subset, 'contributions'),
        commitment: _criterion(subset, 'commitment'),
        attitude: _criterion(subset, 'attitude'),
      );
    }).toList()
      ..sort((a, b) => b.avgScore.compareTo(a.avgScore));

    return TeacherAnalytics(
      courseName: courseName,
      perActivity: perActivity,
      perGroup: perGroup,
      perStudent: perStudent,
    );
  }
}
