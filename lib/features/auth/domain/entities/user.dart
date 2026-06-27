import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String? fullName;
  final String? phone;
  final String role;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    required this.role,
    this.createdAt,
  });

  bool get isPatient => role == 'patient';
  bool get isMedicalProfessional => role == 'medical_professional';
  bool get isPharmacist => role == 'pharmacist';

  @override
  List<Object?> get props => [id, email, fullName, phone, role, createdAt];
}

class AuthResponse extends Equatable {
  final String token;
  final User user;

  const AuthResponse({
    required this.token,
    required this.user,
  });

  @override
  List<Object?> get props => [token, user];
}

