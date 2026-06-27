import 'package:equatable/equatable.dart';

enum PrescriptionRequestStatus {
  pending,
  assigned,
  accepted,
  preparing,
  ready,
  onRoute,
  delivered,
  cancelled,
}

class PrescriptionRequest extends Equatable {
  final int? id;
  final int? patientId;
  final int? pharmacistId;
  final String prescriptionText;
  final PrescriptionRequestStatus status;
  final bool isUrgent;
  final String? notes;
  final DateTime? requestedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? deliveredAt;
  final String? patientName;
  final String? patientPhone;
  final String? patientEmail;
  final String? pharmacyName;
  final String? pharmacistName;
  final String? pharmacistPhone;

  const PrescriptionRequest({
    this.id,
    this.patientId,
    this.pharmacistId,
    required this.prescriptionText,
    this.status = PrescriptionRequestStatus.pending,
    this.isUrgent = false,
    this.notes,
    this.requestedAt,
    this.acceptedAt,
    this.completedAt,
    this.deliveredAt,
    this.patientName,
    this.patientPhone,
    this.patientEmail,
    this.pharmacyName,
    this.pharmacistName,
    this.pharmacistPhone,
  });

  PrescriptionRequest copyWith({
    int? id,
    int? patientId,
    int? pharmacistId,
    String? prescriptionText,
    PrescriptionRequestStatus? status,
    bool? isUrgent,
    String? notes,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? deliveredAt,
    String? patientName,
    String? patientPhone,
    String? patientEmail,
    String? pharmacyName,
    String? pharmacistName,
    String? pharmacistPhone,
  }) {
    return PrescriptionRequest(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      pharmacistId: pharmacistId ?? this.pharmacistId,
      prescriptionText: prescriptionText ?? this.prescriptionText,
      status: status ?? this.status,
      isUrgent: isUrgent ?? this.isUrgent,
      notes: notes ?? this.notes,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientEmail: patientEmail ?? this.patientEmail,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      pharmacistName: pharmacistName ?? this.pharmacistName,
      pharmacistPhone: pharmacistPhone ?? this.pharmacistPhone,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        pharmacistId,
        prescriptionText,
        status,
        isUrgent,
        notes,
        requestedAt,
        acceptedAt,
        completedAt,
        deliveredAt,
        patientName,
        patientPhone,
        patientEmail,
        pharmacyName,
        pharmacistName,
        pharmacistPhone,
      ];
}


