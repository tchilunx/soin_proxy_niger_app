import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pharmacist.dart';
import '../entities/prescription_request.dart';

abstract class PharmacistRepository {
  Future<Either<Failure, Pharmacist>> getMyProfile();
  Future<Either<Failure, Pharmacist>> updateStatus(PharmacistStatus status);
  Future<Either<Failure, Pharmacist>> updateLocation(double latitude, double longitude);
  Future<Either<Failure, Pharmacist>> updateProfile({
    String? pharmacyName,
    String? address,
    String? licenseNumber,
  });
  Future<Either<Failure, List<PrescriptionRequest>>> getPendingRequests();
  Future<Either<Failure, List<PrescriptionRequest>>> getMyRequests();
  Future<Either<Failure, PrescriptionRequest>> acceptRequest(int requestId);
  Future<Either<Failure, PrescriptionRequest>> rejectRequest(int requestId);
  Future<Either<Failure, PrescriptionRequest>> markPreparing(int requestId);
  Future<Either<Failure, PrescriptionRequest>> markReady(int requestId);
  Future<Either<Failure, PrescriptionRequest>> markOnRoute(int requestId);
  Future<Either<Failure, PrescriptionRequest>> markDelivered(int requestId);
}


