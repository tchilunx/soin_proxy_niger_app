import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? profession,
    String? licenseNumber,
    String? pharmacyName,
    String? address,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AuthResponseModel> register({
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
      final data = {
        'user': {
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      };

      // Add medical professional specific fields
      if (role == 'medical_professional' && profession != null) {
        data['medical_professional'] = {
          'profession': profession,
          if (licenseNumber != null) 'license_number': licenseNumber,
        };
      }
      
      // Add pharmacist specific fields
      if (role == 'pharmacist') {
        data['pharmacist'] = {
          if (pharmacyName != null) 'pharmacy_name': pharmacyName,
          if (licenseNumber != null) 'license_number': licenseNumber,
          if (address != null) 'address': address,
        };
      }

      final response = await _apiClient.post(
        ApiConstants.register,
        data: data,
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

