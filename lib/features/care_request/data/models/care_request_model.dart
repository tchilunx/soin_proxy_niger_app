import '../../domain/entities/care_request.dart';

class CareRequestModel extends CareRequest {
  const CareRequestModel({
    super.id,
    super.patientId,
    super.medicalProfessionalId,
    required super.professionType,
    super.status,
    super.notes,
    super.isUrgent,
    super.latitude,
    super.longitude,
    super.address,
    super.requestedAt,
    super.acceptedAt,
    super.startedAt,
    super.completedAt,
    super.professionalName,
    super.professionalPhone,
    super.patientName,
    super.patientPhone,
    super.prescribedMedications,
    super.suggestedPharmacistId,
    super.suggestedPharmacistName,
    super.suggestedPharmacistPhone,
    super.suggestedPharmacyName,
    super.rating,
    super.ratingComment,
    super.deliveryRequested,
  });

  factory CareRequestModel.fromJson(Map<String, dynamic> json) {
    return CareRequestModel(
      id: json['id'] as int?,
      patientId: json['patient_id'] as int?,
      medicalProfessionalId: json['medical_professional_id'] as int?,
      professionType: _parseProfessionType(json['profession_type'] ?? json['profession']),
      status: _parseStatus(json['status']),
      notes: json['notes'] as String?,
      isUrgent: json['is_urgent'] as bool? ?? false,
      latitude: _parseDouble(json['latitude'] ?? json['location']?['latitude']),
      longitude: _parseDouble(json['longitude'] ?? json['location']?['longitude']),
      address: json['address'] ?? json['location']?['address'] as String?,
      requestedAt: _parseDateTime(json['requested_at']),
      acceptedAt: _parseDateTime(json['accepted_at']),
      startedAt: _parseDateTime(json['started_at']),
      completedAt: _parseDateTime(json['completed_at']),
      professionalName: json['medical_professional']?['user']?['full_name'] as String?,
      professionalPhone: json['medical_professional']?['user']?['phone'] as String?,
      patientName: json['patient']?['user']?['full_name'] as String?,
      patientPhone: json['patient']?['user']?['phone'] as String?,
      prescribedMedications: json['prescribed_medications'] as String?,
      suggestedPharmacistId: json['suggested_pharmacist_id'] as int?,
      suggestedPharmacistName: json['suggested_pharmacist']?['user']?['full_name'] as String?,
      suggestedPharmacistPhone: json['suggested_pharmacist']?['user']?['phone'] as String?,
      suggestedPharmacyName: json['suggested_pharmacist']?['pharmacy_name'] as String?,
      rating: json['rating'] as int?,
      ratingComment: json['rating_comment'] as String?,
      deliveryRequested: json['delivery_requested'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'profession_type': professionType == ProfessionType.doctor ? 'doctor' : 'nurse',
      'notes': notes,
      'is_urgent': isUrgent,
      'location_attributes': {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      },
    };
  }

  static ProfessionType _parseProfessionType(dynamic value) {
    if (value == null) return ProfessionType.doctor;
    final str = value.toString().toLowerCase();
    if (str == 'nurse') return ProfessionType.nurse;
    return ProfessionType.doctor;
  }

  static CareRequestStatus _parseStatus(dynamic value) {
    if (value == null) return CareRequestStatus.pending;
    final str = value.toString().toLowerCase();
    switch (str) {
      case 'assigned':
        return CareRequestStatus.assigned;
      case 'accepted':
        return CareRequestStatus.accepted;
      case 'on_route':
        return CareRequestStatus.onRoute;
      case 'in_progress':
        return CareRequestStatus.inProgress;
      case 'completed':
        return CareRequestStatus.completed;
      case 'cancelled':
        return CareRequestStatus.cancelled;
      default:
        return CareRequestStatus.pending;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

