import 'package:equatable/equatable.dart';

enum CareRequestStatus {
  pending,
  assigned,
  accepted,
  onRoute,
  inProgress,
  completed,
  cancelled,
}

enum ProfessionType {
  doctor,
  nurse,
}

class CareRequest extends Equatable {
  final int? id;
  final int? patientId;
  final int? medicalProfessionalId;
  final ProfessionType professionType;
  final CareRequestStatus status;
  final String? notes;
  final bool isUrgent;
  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime? requestedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? professionalName;
  final String? professionalPhone;
  final String? patientName;
  final String? patientPhone;
  final String? prescribedMedications;
  final int? suggestedPharmacistId;
  final String? suggestedPharmacistName;
  final String? suggestedPharmacistPhone;
  final String? suggestedPharmacyName;
  final int? rating;
  final String? ratingComment;
  final bool deliveryRequested;

  const CareRequest({
    this.id,
    this.patientId,
    this.medicalProfessionalId,
    required this.professionType,
    this.status = CareRequestStatus.pending,
    this.notes,
    this.isUrgent = false,
    this.latitude,
    this.longitude,
    this.address,
    this.requestedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.professionalName,
    this.professionalPhone,
    this.patientName,
    this.patientPhone,
    this.prescribedMedications,
    this.suggestedPharmacistId,
    this.suggestedPharmacistName,
    this.suggestedPharmacistPhone,
    this.suggestedPharmacyName,
    this.rating,
    this.ratingComment,
    this.deliveryRequested = false,
  });

  CareRequest copyWith({
    int? id,
    int? patientId,
    int? medicalProfessionalId,
    ProfessionType? professionType,
    CareRequestStatus? status,
    String? notes,
    bool? isUrgent,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? professionalName,
    String? professionalPhone,
    String? patientName,
    String? patientPhone,
    String? prescribedMedications,
    int? suggestedPharmacistId,
    String? suggestedPharmacistName,
    String? suggestedPharmacistPhone,
    String? suggestedPharmacyName,
    int? rating,
    String? ratingComment,
  }) {
    return CareRequest(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      medicalProfessionalId: medicalProfessionalId ?? this.medicalProfessionalId,
      professionType: professionType ?? this.professionType,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isUrgent: isUrgent ?? this.isUrgent,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      professionalName: professionalName ?? this.professionalName,
      professionalPhone: professionalPhone ?? this.professionalPhone,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      prescribedMedications: prescribedMedications ?? this.prescribedMedications,
      suggestedPharmacistId: suggestedPharmacistId ?? this.suggestedPharmacistId,
      suggestedPharmacistName: suggestedPharmacistName ?? this.suggestedPharmacistName,
      suggestedPharmacistPhone: suggestedPharmacistPhone ?? this.suggestedPharmacistPhone,
      suggestedPharmacyName: suggestedPharmacyName ?? this.suggestedPharmacyName,
      rating: rating ?? this.rating,
      ratingComment: ratingComment ?? this.ratingComment,
      deliveryRequested: deliveryRequested ?? this.deliveryRequested,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        medicalProfessionalId,
        professionType,
        status,
        notes,
        isUrgent,
        latitude,
        longitude,
        address,
        requestedAt,
        acceptedAt,
        startedAt,
        completedAt,
        professionalName,
        professionalPhone,
        patientName,
        patientPhone,
        prescribedMedications,
        suggestedPharmacistId,
        suggestedPharmacistName,
        suggestedPharmacistPhone,
        suggestedPharmacyName,
        rating,
        ratingComment,
        deliveryRequested,
      ];
}

