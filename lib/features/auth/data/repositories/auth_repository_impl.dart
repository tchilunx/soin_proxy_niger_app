import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Cache token and user
      await _localDataSource.cacheToken(response.token);
      await _localDataSource.cacheUser(response.user as UserModel);
      await _localDataSource.cacheUserRole(response.user.role);

      return Right(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? profession,
    String? licenseNumber,
    String? pharmacyName,
    String? address,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
        profession: profession,
        licenseNumber: licenseNumber,
        pharmacyName: pharmacyName,
        address: address,
      );

      // Cache token and user
      await _localDataSource.cacheToken(response.token);
      await _localDataSource.cacheUser(response.user as UserModel);
      await _localDataSource.cacheUserRole(response.user.role);

      return Right(response);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        errors: e.errors?.cast<String, List<String>>(),
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _localDataSource.getUser();
      if (user == null) {
        return const Left(AuthFailure(message: 'Utilisateur non connecté'));
      }
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.isLoggedIn();
  }

  @override
  Future<String?> getToken() async {
    return await _localDataSource.getToken();
  }

  @override
  Future<String?> getUserRole() async {
    return await _localDataSource.getUserRole();
  }
}

