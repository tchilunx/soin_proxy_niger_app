import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../professional/data/models/medical_professional_model.dart';
import '../../../pharmacist/data/models/pharmacist_model.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<PatientModel> getMyProfile();
  Future<PatientModel> updateMyProfile({String? dateOfBirth, String? medicalNotes});
  Future<List<MedicalProfessionalModel>> getAvailableProfessionals({
    String? profession,
    double? latitude,
    double? longitude,
    double? radius,
  });
  Future<List<PharmacistModel>> getAvailablePharmacists({
    double? latitude,
    double? longitude,
    double? radius,
  });
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final ApiClient _apiClient;

  PatientRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PatientModel> getMyProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.patient);
      if (response.statusCode == 200) {
        return PatientModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(message: 'Impossible de récupérer le profil');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PatientModel> updateMyProfile({String? dateOfBirth, String? medicalNotes}) async {
    try {
      final data = <String, dynamic>{};
      if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth;
      if (medicalNotes != null) data['medical_notes'] = medicalNotes;

      final response = await _apiClient.patch(ApiConstants.patient, data: {'patient': data});
      if (response.statusCode == 200) {
        return PatientModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(message: 'Impossible de mettre à jour le profil');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MedicalProfessionalModel>> getAvailableProfessionals({
    String? profession,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (profession != null) queryParams['profession'] = profession;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radius != null) queryParams['radius'] = radius;

      final response = await _apiClient.get(
        ApiConstants.medicalProfessionals,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>;
        return list
            .map((e) => MedicalProfessionalModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(message: 'Impossible de récupérer les professionnels');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PharmacistModel>> getAvailablePharmacists({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, dynamic>{'status': 'available'};
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radius != null) queryParams['radius'] = radius;

      final response = await _apiClient.get(
        ApiConstants.pharmacists,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>;
        return list
            .map((e) => PharmacistModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(message: 'Impossible de récupérer les pharmaciens');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
