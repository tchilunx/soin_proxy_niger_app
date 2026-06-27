import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_professional.dart';

abstract class ProfessionalEvent extends Equatable {
  const ProfessionalEvent();

  @override
  List<Object?> get props => [];
}

class ProfessionalLoadRequested extends ProfessionalEvent {
  const ProfessionalLoadRequested();
}

class ProfessionalStatusToggled extends ProfessionalEvent {
  final bool isAvailable;

  const ProfessionalStatusToggled(this.isAvailable);

  @override
  List<Object?> get props => [isAvailable];
}

class ProfessionalLocationUpdated extends ProfessionalEvent {
  final double latitude;
  final double longitude;

  const ProfessionalLocationUpdated({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class ProfessionalRequestsLoadRequested extends ProfessionalEvent {
  const ProfessionalRequestsLoadRequested();
}

class ProfessionalRequestAccepted extends ProfessionalEvent {
  final int requestId;

  const ProfessionalRequestAccepted(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class ProfessionalRequestRejected extends ProfessionalEvent {
  final int requestId;

  const ProfessionalRequestRejected(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class ProfessionalRequestStatusUpdated extends ProfessionalEvent {
  final int requestId;
  final String status;
  final String? prescribedMedications;
  final int? suggestedPharmacistId;

  const ProfessionalRequestStatusUpdated({
    required this.requestId,
    required this.status,
    this.prescribedMedications,
    this.suggestedPharmacistId,
  });

  @override
  List<Object?> get props => [requestId, status, prescribedMedications, suggestedPharmacistId];
}

