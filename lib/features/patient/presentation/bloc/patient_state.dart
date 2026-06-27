import 'package:equatable/equatable.dart';
import '../../../patient/domain/entities/patient.dart';
import '../../../professional/domain/entities/medical_professional.dart';
import '../../../pharmacist/domain/entities/pharmacist.dart';

enum PatientStatus { initial, loading, success, failure }

class PatientState extends Equatable {
  final PatientStatus status;
  final Patient? patient;
  final List<MedicalProfessional> professionals;
  final List<MedicalProfessional> filteredProfessionals;
  final List<Pharmacist> pharmacists;
  final String? professionFilter;
  final String? error;

  const PatientState({
    this.status = PatientStatus.initial,
    this.patient,
    this.professionals = const [],
    this.filteredProfessionals = const [],
    this.pharmacists = const [],
    this.professionFilter,
    this.error,
  });

  PatientState copyWith({
    PatientStatus? status,
    Patient? patient,
    List<MedicalProfessional>? professionals,
    List<MedicalProfessional>? filteredProfessionals,
    List<Pharmacist>? pharmacists,
    String? professionFilter,
    String? error,
    bool clearError = false,
    bool clearProfessionFilter = false,
  }) {
    return PatientState(
      status: status ?? this.status,
      patient: patient ?? this.patient,
      professionals: professionals ?? this.professionals,
      filteredProfessionals: filteredProfessionals ?? this.filteredProfessionals,
      pharmacists: pharmacists ?? this.pharmacists,
      professionFilter: clearProfessionFilter ? null : professionFilter ?? this.professionFilter,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, patient, professionals, filteredProfessionals, pharmacists, professionFilter, error];
}
