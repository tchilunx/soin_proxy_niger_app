import '../../domain/entities/patient.dart';

class PatientModel extends Patient {
  const PatientModel({
    super.id,
    super.userId,
    super.dateOfBirth,
    super.medicalNotes,
    super.userFullName,
    super.userEmail,
    super.userPhone,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return PatientModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int? ?? user?['id'] as int?,
      dateOfBirth: json['date_of_birth'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      userFullName: user?['full_name'] as String?,
      userEmail: user?['email'] as String?,
      userPhone: user?['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (medicalNotes != null) 'medical_notes': medicalNotes,
    };
  }
}
