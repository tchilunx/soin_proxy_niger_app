import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final String role;
  final String? profession;
  final String? licenseNumber;
  final String? pharmacyName;
  final String? address;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.role,
    this.profession,
    this.licenseNumber,
    this.pharmacyName,
    this.address,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        fullName,
        phone,
        role,
        profession,
        licenseNumber,
        pharmacyName,
        address,
      ];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

