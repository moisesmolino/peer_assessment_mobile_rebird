class AuthUser {
  final String name;
  final String email;
  String? password;
  int? id;

  AuthUser({
    required this.name,
    required this.email,
    required this.password,
    this.id,
  });
}
