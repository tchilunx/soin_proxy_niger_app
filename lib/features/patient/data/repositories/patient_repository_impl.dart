import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';
import '../../../professional/domain/entities/medical_professional.dart';
import '../../../pharmacist/domain/entities/pharmacist.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource _remoteDataSource;

  PatientRepositoryImpl(this._remoteDataSource);

  @override
  Future<Patient> getMyProfile() => _remoteDataSource.getMyProfile();

  @override
  Future<Patient> updateMyProfile({String? dateOfBirth, String? medicalNotes}) =>
      _remoteDataSource.updateMyProfile(dateOfBirth: dateOfBirth, medicalNotes: medicalNotes);

  @override
  Future<List<MedicalProfessional>> getAvailableProfessionals({
    String? profession,
    double? latitude,
    double? longitude,
    double? radius,
  }) =>
      _remoteDataSource.getAvailableProfessionals(
        profession: profession,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

  @override
  Future<List<Pharmacist>> getAvailablePharmacists({
    double? latitude,
    double? longitude,
    double? radius,
  }) =>
      _remoteDataSource.getAvailablePharmacists(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
}
