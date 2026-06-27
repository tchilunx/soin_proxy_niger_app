import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../../professional/domain/entities/medical_professional.dart';
import 'patient_event.dart';
import 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository _repository;

  PatientBloc(this._repository) : super(const PatientState()) {
    on<LoadPatientProfile>(_onLoadProfile);
    on<LoadAvailableProfessionals>(_onLoadProfessionals);
    on<LoadAvailablePharmacists>(_onLoadPharmacists);
    on<FilterProfessionals>(_onFilterProfessionals);
  }

  Future<void> _onLoadProfile(LoadPatientProfile event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading, clearError: true));
    try {
      final patient = await _repository.getMyProfile();
      emit(state.copyWith(status: PatientStatus.success, patient: patient));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLoadProfessionals(LoadAvailableProfessionals event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading, clearError: true));
    try {
      final professionals = await _repository.getAvailableProfessionals(
        profession: event.profession,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(state.copyWith(
        status: PatientStatus.success,
        professionals: professionals,
        filteredProfessionals: professionals,
        clearProfessionFilter: true,
      ));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onLoadPharmacists(LoadAvailablePharmacists event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading, clearError: true));
    try {
      final pharmacists = await _repository.getAvailablePharmacists(
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(state.copyWith(status: PatientStatus.success, pharmacists: pharmacists));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.failure, error: e.toString()));
    }
  }

  void _onFilterProfessionals(FilterProfessionals event, Emitter<PatientState> emit) {
    final profession = event.profession;
    List<MedicalProfessional> filtered;
    if (profession == null || profession == 'all') {
      filtered = state.professionals;
    } else {
      filtered = state.professionals.where((p) {
        return profession == 'doctor'
            ? p.profession == Profession.doctor
            : p.profession == Profession.nurse;
      }).toList();
    }
    emit(state.copyWith(
      filteredProfessionals: filtered,
      professionFilter: profession,
    ));
  }
}
