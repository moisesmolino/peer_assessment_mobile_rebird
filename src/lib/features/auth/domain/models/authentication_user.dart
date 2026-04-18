class AuthenticationUser {
  String? id;
  final String email;
  final String name;
  final bool student;

  AuthenticationUser({
    this.id,
    required this.email,
    required this.name,
    required this.student,
  });

  factory AuthenticationUser.fromJson(Map<String, dynamic> json) {
    return AuthenticationUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      student: json['student'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': id, 'email': email, 'name': name, 'student': student};
  }
}
