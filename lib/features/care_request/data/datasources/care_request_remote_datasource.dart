import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/care_request_model.dart';
import '../../domain/entities/care_request.dart';

abstract class CareRequestRemoteDataSource {
  Future<CareRequestModel> createCareRequest({
    required ProfessionType professionType,
    required double latitude,
    required double longitude,
    String? address,
    String? notes,
    bool isUrgent = false,
  });

  Future<List<CareRequestModel>> getCareRequests();

  Future<CareRequestModel> getCareRequestById(int id);

  Future<CareRequestModel> cancelCareRequest(int id);

  Future<CareRequestModel> submitRating({
    required int requestId,
    required int rating,
    String? comment,
  });

  Future<CareRequestModel> requestDelivery(int requestId);
}

class CareRequestRemoteDataSourceImpl implements CareRequestRemoteDataSource {
  final ApiClient _apiClient;

  CareRequestRemoteDataSourceImpl(this._apiClient);

  @override
  Future<CareRequestModel> createCareRequest({
    required ProfessionType professionType,
    required double latitude,
    required double longitude,
    String? address,
    String? notes,
    bool isUrgent = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.careRequests,
        data: {
          'care_request': {
            'notes': notes ?? '',
            'is_urgent': isUrgent,
            'location_attributes': {
              'latitude': latitude,
              'longitude': longitude,
              'address': address ?? '',
            },
          },
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CareRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to create care request',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CareRequestModel>> getCareRequests() async {
    try {
      final response = await _apiClient.get(ApiConstants.careRequests);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        return data.map((json) => CareRequestModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch care requests');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CareRequestModel> getCareRequestById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.careRequests}/$id');

      if (response.statusCode == 200) {
        return CareRequestModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Care request not found');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CareRequestModel> cancelCareRequest(int id) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.careRequests}/$id',
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
          message: response.data['error'] ?? 'Failed to cancel care request',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CareRequestModel> submitRating({
    required int requestId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.careRequests}/$requestId',
        data: {
          'care_request': {
            'rating': rating,
            if (comment != null) 'rating_comment': comment,
          },
        },
      );

      if (response.statusCode == 200) {
        return CareRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to submit rating',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CareRequestModel> requestDelivery(int requestId) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.careRequests}/$requestId',
        data: {
          'care_request': {
            'delivery_requested': true,
          },
        },
      );

      if (response.statusCode == 200) {
        return CareRequestModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to request delivery',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}

