import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/care_request.dart';

abstract class CareRequestRepository {
  Future<Either<Failure, CareRequest>> createCareRequest({
    required ProfessionType professionType,
    required double latitude,
    required double longitude,
    String? address,
    String? notes,
    bool isUrgent,
  });

  Future<Either<Failure, List<CareRequest>>> getCareRequests();

  Future<Either<Failure, CareRequest>> getCareRequestById(int id);

  Future<Either<Failure, CareRequest>> cancelCareRequest(int id);

  Future<Either<Failure, CareRequest?>> getActiveRequest();

  Future<Either<Failure, CareRequest>> submitRating({
    required int requestId,
    required int rating,
    String? comment,
  });

  Future<Either<Failure, CareRequest>> requestDelivery(int requestId);
}

