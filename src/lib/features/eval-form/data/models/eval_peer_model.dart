import 'package:src/features/eval-form/domain/entities/eval_peer.dart';

class EvalPeerModel {
  final String firstName;
  final String lastName;
  final String email;

  const EvalPeerModel({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory EvalPeerModel.fromJson(Map<String, dynamic> json) => EvalPeerModel(
        firstName: json['FirstName'] as String,
        lastName: json['LastName'] as String,
        email: json['correo'] as String,
      );

  EvalPeer toEntity() => EvalPeer(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
}
