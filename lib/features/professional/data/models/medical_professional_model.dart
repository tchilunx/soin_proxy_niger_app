import '../../domain/entities/medical_professional.dart';

class MedicalProfessionalModel extends MedicalProfessional {
  const MedicalProfessionalModel({
    super.id,
    super.userId,
    super.profession,
    super.status,
    super.licenseNumber,
    super.specialties,
    super.currentLatitude,
    super.currentLongitude,
    super.lastLocationAt,
    super.userFullName,
    super.userEmail,
    super.userPhone,
  });

  factory MedicalProfessionalModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return MedicalProfessionalModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int? ?? user?['id'] as int?,
      profession: _parseProfession(json['profession']),
      status: _parseStatus(json['status']),
      licenseNumber: json['license_number'] as String?,
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : null,
      currentLatitude: _parseDouble(json['current_latitude']),
      currentLongitude: _parseDouble(json['current_longitude']),
      lastLocationAt: json['last_location_at'] != null
          ? DateTime.tryParse(json['last_location_at'])
          : null,
      userFullName: user?['full_name'] as String?,
      userEmail: user?['email'] as String?,
      userPhone: user?['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'profession': profession == Profession.doctor ? 'doctor' : 'nurse',
      'status': _statusToString(status),
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (specialties != null) 'specialties': specialties,
      if (currentLatitude != null) 'current_latitude': currentLatitude,
      if (currentLongitude != null) 'current_longitude': currentLongitude,
    };
  }

  static Profession _parseProfession(dynamic value) {
    if (value == null) return Profession.doctor;
    final str = value.toString().toLowerCase();
    if (str == 'nurse' || str == '1') return Profession.nurse;
    return Profession.doctor;
  }

  static ProfessionalStatus _parseStatus(dynamic value) {
    if (value == null) return ProfessionalStatus.offline;
    final str = value.toString().toLowerCase();
    switch (str) {
      case 'available':
      case '1':
        return ProfessionalStatus.available;
      case 'on_route':
      case '2':
        return ProfessionalStatus.onRoute;
      case 'busy':
      case '3':
        return ProfessionalStatus.busy;
      default:
        return ProfessionalStatus.offline;
    }
  }

  static String _statusToString(ProfessionalStatus status) {
    switch (status) {
      case ProfessionalStatus.available:
        return 'available';
      case ProfessionalStatus.onRoute:
        return 'on_route';
      case ProfessionalStatus.busy:
        return 'busy';
      default:
        return 'offline';
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

