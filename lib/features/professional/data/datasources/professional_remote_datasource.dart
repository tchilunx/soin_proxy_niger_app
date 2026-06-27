import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../care_request/data/models/care_request_model.dart';
import '../models/medical_professional_model.dart';
import '../../domain/entities/medical_professional.dart';

abstract class ProfessionalRemoteDataSource {
  Future<MedicalProfessionalModel> getMyProfile();
  Future<MedicalProfessionalModel> updateStatus(ProfessionalStatus status);
  Future<MedicalProfessionalModel> updateLocation(double latitude, double longitude);
  Future<List<CareRequestModel>> getPendingRequests();
  Future<List<CareRequestModel>> getMyRequests();
  Future<CareRequestModel> acceptRequest(int requestId);
  Future<CareRequestModel> rejectRequest(int requestId);
  Future<CareRequestModel> updateRequestStatus(
    int requestId,
    String status, {
    String? prescribedMedications,
    int? suggestedPharmacistId,
  });
}

class ProfessionalRemoteDataSourceImpl implements ProfessionalRemoteDataSource {
  final ApiClient _apiClient;

  ProfessionalRemoteDataSourceImpl(this._apiClient);

  @override
  Future<MedicalProfessionalModel> getMyProfile() async {
    try {
      final response = await _apiClient.get('${ApiConstants.medicalProfessionals}/me');

      if (response.statusCode == 200) {
        return MedicalProfessionalModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to fetch profile');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MedicalProfessionalModel> updateStatus(ProfessionalStatus status) async {
    try {
      String statusStr;
      switch (status) {
        case ProfessionalStatus.available:
          statusStr = 'available';
          break;
        case ProfessionalStatus.onRoute:
          statusStr = 'on_route';
          break;
        case ProfessionalStatus.busy:
          statusStr = 'busy';
          break;
        default:
          statusStr = 'offline';
      }

      final response = await _apiClient.patch(
        '${ApiConstants.medicalProfessionals}/me',
        data: {
          'medical_professional': {
            'status': statusStr,
          },
        },
      );

      if (response.statusCode == 200) {
        return MedicalProfessionalModel.fromJson(response.data);
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
  Future<MedicalProfessionalModel> updateLocation(double latitude, double longitude) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.medicalProfessionals}/me',
        data: {
          'medical_professional': {
            'current_latitude': latitude,
            'current_longitude': longitude,
            'last_location_at': DateTime.now().toIso8601String(),
          },
        },
      );

      if (response.statusCode == 200) {
        return MedicalProfessionalModel.fromJson(response.data);
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
  Future<List<CareRequestModel>> getPendingRequests() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.careRequests}?status=pending',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data['data'] ?? [];
        return data.map((json) => CareRequestModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch pending requests');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CareRequestModel>> getMyRequests() async {
    try {
      final response = await _apiClient.get(ApiConstants.careRequests);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data['data'] ?? [];
        return data.map((json) => CareRequestModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch requests');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CareRequestModel> acceptRequest(int requestId) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.careRequests}/$requestId',
        data: {
          'care_request': {
            'status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
          },
        },
      );

      if (response.statusCode == 200) {
        return CareRequestModel.fromJson(response.data);
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
  Future<CareRequestModel> rejectRequest(int requestId) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.careRequests}/$requestId',
        data: {
          'care_request': {
            'status': 'cancelled',
          },
        },
      );

      if (response.statusCode == 200) {
        return CareRequestModel.fromJson(response.data);
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
  Future<CareRequestModel> updateRequestStatus(
    int requestId,
    String status, {
    String? prescribedMedications,
    int? suggestedPharmacistId,
  }) async {
    try {
      final data = <String, dynamic>{
        'care_request': {
          'status': status,
          if (prescribedMedications != null) 'prescribed_medications': prescribedMedications,
          if (suggestedPharmacistId != null) 'suggested_pharmacist_id': suggestedPharmacistId,
        },
      };

      final response = await _apiClient.patch(
        '${ApiConstants.careRequests}/$requestId',
        data: data,
      );

      if (response.statusCode == 200) {
        return CareRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to update request status',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}

