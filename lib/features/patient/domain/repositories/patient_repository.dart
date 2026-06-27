import '../entities/patient.dart';
import '../../../professional/domain/entities/medical_professional.dart';
import '../../../pharmacist/domain/entities/pharmacist.dart';

abstract class PatientRepository {
  Future<Patient> getMyProfile();
  Future<Patient> updateMyProfile({String? dateOfBirth, String? medicalNotes});
  Future<List<MedicalProfessional>> getAvailableProfessionals({
    String? profession,
    double? latitude,
    double? longitude,
    double? radius,
  });
  Future<List<Pharmacist>> getAvailablePharmacists({
    double? latitude,
    double? longitude,
    double? radius,
  });
}
