class Course {
  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.period,
    required this.studentsCount,
    required this.activeEvaluations,
    required this.totalEvaluations,
  });

  String id;
  String code;
  String name;
  String period;
  int studentsCount;
  int activeEvaluations;
  int totalEvaluations;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["_id"],
    code: json["code"] ?? "---",
    name: json["name"] ?? "---",
    period: json["period"] ?? "---",
    studentsCount: json["studentsCount"] ?? 0,
    activeEvaluations: json["activeEvaluations"] ?? 0,
    totalEvaluations: json["totalEvaluations"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "code": code,
    "name": name,
    "period": period,
    "studentsCount": studentsCount,
    "activeEvaluations": activeEvaluations,
    "totalEvaluations": totalEvaluations,
  };

  Map<String, dynamic> toJsonNoId() => {
    "code": code,
    "name": name,
    "period": period,
    "studentsCount": studentsCount,
    "activeEvaluations": activeEvaluations,
    "totalEvaluations": totalEvaluations,
  };

  @override
  String toString() {
    return 'Course{id: $id, code: $code, name: $name, period: $period, studentsCount: $studentsCount, activeEvaluations: $activeEvaluations, totalEvaluations: $totalEvaluations}';
  }
}