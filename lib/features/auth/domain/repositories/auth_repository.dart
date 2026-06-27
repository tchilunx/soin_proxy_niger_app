import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthResponse>> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? profession, // For medical professionals
    String? licenseNumber,
    String? pharmacyName, // For pharmacists
    String? address, // For pharmacists
  });

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<bool> isLoggedIn();

  Future<String?> getToken();

  Future<String?> getUserRole();
}

