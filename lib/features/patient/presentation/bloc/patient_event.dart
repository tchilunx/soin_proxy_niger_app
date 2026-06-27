import 'package:equatable/equatable.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatientProfile extends PatientEvent {
  const LoadPatientProfile();
}

class LoadAvailableProfessionals extends PatientEvent {
  final String? profession;
  final double? latitude;
  final double? longitude;

  const LoadAvailableProfessionals({this.profession, this.latitude, this.longitude});

  @override
  List<Object?> get props => [profession, latitude, longitude];
}

class LoadAvailablePharmacists extends PatientEvent {
  final double? latitude;
  final double? longitude;

  const LoadAvailablePharmacists({this.latitude, this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class FilterProfessionals extends PatientEvent {
  final String? profession;

  const FilterProfessionals({this.profession});

  @override
  List<Object?> get props => [profession];
}
