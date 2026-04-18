class StudentSummary {
  final String email;
  final String displayName;
  final double punctuality;
  final double contributions;
  final double commitment;
  final double attitude;

  const StudentSummary({
    required this.email,
    required this.displayName,
    required this.punctuality,
    required this.contributions,
    required this.commitment,
    required this.attitude,
  });

  double get avgScore => (punctuality + contributions + commitment + attitude) / 4;

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }
}

class ActivityAverage {
  final String evaluationName;
  final double avgScore;

  const ActivityAverage({required this.evaluationName, required this.avgScore});
}

class GroupAverage {
  final String groupName;
  final double avgScore;

  const GroupAverage({required this.groupName, required this.avgScore});
}

class TeacherAnalytics {
  final String courseName;
  final List<ActivityAverage> perActivity;
  final List<GroupAverage> perGroup;
  final List<StudentSummary> perStudent;

  const TeacherAnalytics({
    required this.courseName,
    required this.perActivity,
    required this.perGroup,
    required this.perStudent,
  });
}
