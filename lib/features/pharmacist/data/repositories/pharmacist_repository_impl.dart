import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/pharmacist.dart';
import '../../domain/entities/prescription_request.dart';
import '../../domain/repositories/pharmacist_repository.dart';
import '../datasources/pharmacist_remote_datasource.dart';

class PharmacistRepositoryImpl implements PharmacistRepository {
  final PharmacistRemoteDataSource _remoteDataSource;

  PharmacistRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Pharmacist>> getMyProfile() async {
    try {
      final result = await _remoteDataSource.getMyProfile();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pharmacist>> updateStatus(PharmacistStatus status) async {
    try {
      final result = await _remoteDataSource.updateStatus(status);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pharmacist>> updateLocation(double latitude, double longitude) async {
    try {
      final result = await _remoteDataSource.updateLocation(latitude, longitude);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pharmacist>> updateProfile({
    String? pharmacyName,
    String? address,
    String? licenseNumber,
  }) async {
    try {
      final result = await _remoteDataSource.updateProfile(
        pharmacyName: pharmacyName,
        address: address,
        licenseNumber: licenseNumber,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrescriptionRequest>>> getPendingRequests() async {
    try {
      final result = await _remoteDataSource.getPendingRequests();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrescriptionRequest>>> getMyRequests() async {
    try {
      final result = await _remoteDataSource.getMyRequests();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrescriptionRequest>> acceptRequest(int requestId) async {
    try {
      final result = await _remoteDataSource.acceptRequest(requestId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrescriptionRequest>> rejectRequest(int requestId) async {
    try {
      final result = await _remoteDataSource.rejectRequest(requestId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrescriptionRequest>> markPreparing(int requestId) async {
    try {
      final result = await _remoteDataSource.markPreparing(requestId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrescriptionRequest>> markReady(int requestId) async {
    try {
      final result = await _remoteDataSource.markReady(requestId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrescriptionRequest>> markOnRoute(int requestId) async {
    try {
      final result = await _remoteDataSource.markOnRoute(requestId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrescriptionRequest>> markDelivered(int requestId) async {
    try {
      final result = await _remoteDataSource.markDelivered(requestId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}


