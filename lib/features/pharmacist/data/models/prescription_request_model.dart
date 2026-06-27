import '../../domain/entities/prescription_request.dart';

class PrescriptionRequestModel extends PrescriptionRequest {
  const PrescriptionRequestModel({
    super.id,
    super.patientId,
    super.pharmacistId,
    required super.prescriptionText,
    super.status,
    super.isUrgent,
    super.notes,
    super.requestedAt,
    super.acceptedAt,
    super.completedAt,
    super.deliveredAt,
    super.patientName,
    super.patientPhone,
    super.patientEmail,
    super.pharmacyName,
    super.pharmacistName,
    super.pharmacistPhone,
  });

  factory PrescriptionRequestModel.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] as Map<String, dynamic>?;
    final pharmacist = json['pharmacist'] as Map<String, dynamic>?;
    
    return PrescriptionRequestModel(
      id: json['id'] as int?,
      patientId: json['patient_id'] as int? ?? patient?['id'] as int?,
      pharmacistId: json['pharmacist_id'] as int? ?? pharmacist?['id'] as int?,
      prescriptionText: json['prescription_text'] as String? ?? '',
      status: _parseStatus(json['status']),
      isUrgent: json['is_urgent'] as bool? ?? false,
      notes: json['notes'] as String?,
      requestedAt: json['requested_at'] != null
          ? DateTime.tryParse(json['requested_at'])
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
      patientName: patient?['full_name'] as String? ?? json['patient_name'] as String?,
      patientPhone: patient?['phone'] as String? ?? json['patient_phone'] as String?,
      patientEmail: patient?['email'] as String? ?? json['patient_email'] as String?,
      pharmacyName: pharmacist?['pharmacy_name'] as String? ?? json['pharmacy_name'] as String?,
      pharmacistName: pharmacist?['user']?['full_name'] as String? ?? json['pharmacist_name'] as String?,
      pharmacistPhone: pharmacist?['user']?['phone'] as String? ?? json['pharmacist_phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'prescription_text': prescriptionText,
      if (notes != null) 'notes': notes,
      'is_urgent': isUrgent,
      'status': _statusToString(status),
    };
  }

  static PrescriptionRequestStatus _parseStatus(dynamic value) {
    if (value == null) return PrescriptionRequestStatus.pending;
    final str = value.toString().toLowerCase();
    switch (str) {
      case 'assigned':
      case '1':
        return PrescriptionRequestStatus.assigned;
      case 'accepted':
      case '2':
        return PrescriptionRequestStatus.accepted;
      case 'preparing':
      case '3':
        return PrescriptionRequestStatus.preparing;
      case 'ready':
      case '4':
        return PrescriptionRequestStatus.ready;
      case 'on_route':
      case 'onRoute':
      case '5':
        return PrescriptionRequestStatus.onRoute;
      case 'delivered':
      case '6':
        return PrescriptionRequestStatus.delivered;
      case 'cancelled':
      case '7':
        return PrescriptionRequestStatus.cancelled;
      default:
        return PrescriptionRequestStatus.pending;
    }
  }

  static String _statusToString(PrescriptionRequestStatus status) {
    switch (status) {
      case PrescriptionRequestStatus.assigned:
        return 'assigned';
      case PrescriptionRequestStatus.accepted:
        return 'accepted';
      case PrescriptionRequestStatus.preparing:
        return 'preparing';
      case PrescriptionRequestStatus.ready:
        return 'ready';
      case PrescriptionRequestStatus.onRoute:
        return 'on_route';
      case PrescriptionRequestStatus.delivered:
        return 'delivered';
      case PrescriptionRequestStatus.cancelled:
        return 'cancelled';
      default:
        return 'pending';
    }
  }
}


