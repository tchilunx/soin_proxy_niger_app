import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/care_request.dart';
import '../../domain/repositories/care_request_repository.dart';
import '../datasources/care_request_remote_datasource.dart';

class CareRequestRepositoryImpl implements CareRequestRepository {
  final CareRequestRemoteDataSource _remoteDataSource;

  CareRequestRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, CareRequest>> createCareRequest({
    required ProfessionType professionType,
    required double latitude,
    required double longitude,
    String? address,
    String? notes,
    bool isUrgent = false,
  }) async {
    try {
      final result = await _remoteDataSource.createCareRequest(
        professionType: professionType,
        latitude: latitude,
        longitude: longitude,
        address: address,
        notes: notes,
        isUrgent: isUrgent,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CareRequest>>> getCareRequests() async {
    try {
      final result = await _remoteDataSource.getCareRequests();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CareRequest>> getCareRequestById(int id) async {
    try {
      final result = await _remoteDataSource.getCareRequestById(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CareRequest>> cancelCareRequest(int id) async {
    try {
      final result = await _remoteDataSource.cancelCareRequest(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CareRequest?>> getActiveRequest() async {
    try {
      final requests = await _remoteDataSource.getCareRequests();
      final activeStatuses = [
        CareRequestStatus.pending,
        CareRequestStatus.assigned,
        CareRequestStatus.accepted,
        CareRequestStatus.onRoute,
        CareRequestStatus.inProgress,
      ];
      
      final activeRequest = requests.where(
        (r) => activeStatuses.contains(r.status)
      ).toList();
      
      if (activeRequest.isEmpty) {
        return const Right(null);
      }
      return Right(activeRequest.first);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CareRequest>> submitRating({
    required int requestId,
    required int rating,
    String? comment,
  }) async {
    try {
      final result = await _remoteDataSource.submitRating(
        requestId: requestId,
        rating: rating,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CareRequest>> requestDelivery(int requestId) async {
    try {
      final result = await _remoteDataSource.requestDelivery(requestId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

