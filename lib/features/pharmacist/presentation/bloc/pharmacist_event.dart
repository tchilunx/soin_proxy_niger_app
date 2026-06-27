import 'package:equatable/equatable.dart';
import '../../domain/entities/pharmacist.dart';

abstract class PharmacistEvent extends Equatable {
  const PharmacistEvent();

  @override
  List<Object?> get props => [];
}

class PharmacistLoadRequested extends PharmacistEvent {
  const PharmacistLoadRequested();
}

class PharmacistStatusToggled extends PharmacistEvent {
  final bool isAvailable;

  const PharmacistStatusToggled(this.isAvailable);

  @override
  List<Object?> get props => [isAvailable];
}

class PharmacistLocationUpdated extends PharmacistEvent {
  final double latitude;
  final double longitude;

  const PharmacistLocationUpdated({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class PharmacistProfileUpdated extends PharmacistEvent {
  final String? pharmacyName;
  final String? address;
  final String? licenseNumber;

  const PharmacistProfileUpdated({
    this.pharmacyName,
    this.address,
    this.licenseNumber,
  });

  @override
  List<Object?> get props => [pharmacyName, address, licenseNumber];
}

class PharmacistRequestsLoadRequested extends PharmacistEvent {
  const PharmacistRequestsLoadRequested();
}

class PrescriptionRequestAccepted extends PharmacistEvent {
  final int requestId;

  const PrescriptionRequestAccepted(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class PrescriptionRequestRejected extends PharmacistEvent {
  final int requestId;

  const PrescriptionRequestRejected(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class PrescriptionRequestMarkPreparing extends PharmacistEvent {
  final int requestId;

  const PrescriptionRequestMarkPreparing(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class PrescriptionRequestMarkReady extends PharmacistEvent {
  final int requestId;

  const PrescriptionRequestMarkReady(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class PrescriptionRequestMarkOnRoute extends PharmacistEvent {
  final int requestId;

  const PrescriptionRequestMarkOnRoute(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class PrescriptionRequestMarkDelivered extends PharmacistEvent {
  final int requestId;

  const PrescriptionRequestMarkDelivered(this.requestId);

  @override
  List<Object?> get props => [requestId];
}


