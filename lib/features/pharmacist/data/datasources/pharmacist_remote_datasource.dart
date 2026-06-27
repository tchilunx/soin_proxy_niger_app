import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/pharmacist_model.dart';
import '../models/prescription_request_model.dart';
import '../../domain/entities/pharmacist.dart';

abstract class PharmacistRemoteDataSource {
  Future<PharmacistModel> getMyProfile();
  Future<PharmacistModel> updateStatus(PharmacistStatus status);
  Future<PharmacistModel> updateLocation(double latitude, double longitude);
  Future<PharmacistModel> updateProfile({
    String? pharmacyName,
    String? address,
    String? licenseNumber,
  });
  Future<List<PrescriptionRequestModel>> getPendingRequests();
  Future<List<PrescriptionRequestModel>> getMyRequests();
  Future<PrescriptionRequestModel> acceptRequest(int requestId);
  Future<PrescriptionRequestModel> rejectRequest(int requestId);
  Future<PrescriptionRequestModel> markPreparing(int requestId);
  Future<PrescriptionRequestModel> markReady(int requestId);
  Future<PrescriptionRequestModel> markOnRoute(int requestId);
  Future<PrescriptionRequestModel> markDelivered(int requestId);
}

class PharmacistRemoteDataSourceImpl implements PharmacistRemoteDataSource {
  final ApiClient _apiClient;

  PharmacistRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PharmacistModel> getMyProfile() async {
    try {
      final response = await _apiClient.get('${ApiConstants.pharmacists}/me');

      if (response.statusCode == 200) {
        return PharmacistModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to fetch profile');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PharmacistModel> updateStatus(PharmacistStatus status) async {
    try {
      String statusStr;
      switch (status) {
        case PharmacistStatus.available:
          statusStr = 'available';
          break;
        case PharmacistStatus.onRoute:
          statusStr = 'on_route';
          break;
        case PharmacistStatus.busy:
          statusStr = 'busy';
          break;
        default:
          statusStr = 'offline';
      }

      final response = await _apiClient.post(
        '${ApiConstants.pharmacists}/me/status',
        data: {'status': statusStr},
      );

      if (response.statusCode == 200) {
        return PharmacistModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to update status',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PharmacistModel> updateLocation(double latitude, double longitude) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.pharmacists}/me/update_location',
        data: {
          'pharmacist': {
            'current_latitude': latitude,
            'current_longitude': longitude,
          },
        },
      );

      if (response.statusCode == 200) {
        return PharmacistModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to update location',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PharmacistModel> updateProfile({
    String? pharmacyName,
    String? address,
    String? licenseNumber,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.pharmacists}/me',
        data: {
          'pharmacist': {
            if (pharmacyName != null) 'pharmacy_name': pharmacyName,
            if (address != null) 'address': address,
            if (licenseNumber != null) 'license_number': licenseNumber,
          },
        },
      );

      if (response.statusCode == 200) {
        return PharmacistModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PrescriptionRequestModel>> getPendingRequests() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.prescriptionRequests}?pending=true',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data['data'] ?? [];
        return data.map((json) => PrescriptionRequestModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch pending requests');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PrescriptionRequestModel>> getMyRequests() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.prescriptionRequests}?my_requests=true',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data['data'] ?? [];
        return data.map((json) => PrescriptionRequestModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch requests');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PrescriptionRequestModel> acceptRequest(int requestId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.prescriptionRequests}/$requestId/accept',
      );

      if (response.statusCode == 200) {
        return PrescriptionRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to accept request',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PrescriptionRequestModel> rejectRequest(int requestId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.prescriptionRequests}/$requestId/reject',
      );

      if (response.statusCode == 200) {
        return PrescriptionRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to reject request',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PrescriptionRequestModel> markPreparing(int requestId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.prescriptionRequests}/$requestId/mark_preparing',
      );

      if (response.statusCode == 200) {
        return PrescriptionRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to update status',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PrescriptionRequestModel> markReady(int requestId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.prescriptionRequests}/$requestId/mark_ready',
      );

      if (response.statusCode == 200) {
        return PrescriptionRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to update status',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PrescriptionRequestModel> markOnRoute(int requestId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.prescriptionRequests}/$requestId/mark_on_route',
      );

      if (response.statusCode == 200) {
        return PrescriptionRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to update status',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PrescriptionRequestModel> markDelivered(int requestId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.prescriptionRequests}/$requestId/mark_delivered',
      );

      if (response.statusCode == 200) {
        return PrescriptionRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to update status',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}


