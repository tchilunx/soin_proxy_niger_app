import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/professional_remote_datasource.dart';
import '../../domain/entities/medical_professional.dart';
import 'professional_event.dart';
import 'professional_state.dart';

class ProfessionalBloc extends Bloc<ProfessionalEvent, ProfessionalState> {
  final ProfessionalRemoteDataSource _remoteDataSource;

  ProfessionalBloc(this._remoteDataSource) : super(const ProfessionalState()) {
    on<ProfessionalLoadRequested>(_onLoadRequested);
    on<ProfessionalStatusToggled>(_onStatusToggled);
    on<ProfessionalLocationUpdated>(_onLocationUpdated);
    on<ProfessionalRequestsLoadRequested>(_onRequestsLoadRequested);
    on<ProfessionalRequestAccepted>(_onRequestAccepted);
    on<ProfessionalRequestRejected>(_onRequestRejected);
    on<ProfessionalRequestStatusUpdated>(_onRequestStatusUpdated);
  }

  Future<void> _onLoadRequested(
    ProfessionalLoadRequested event,
    Emitter<ProfessionalState> emit,
  ) async {
    emit(state.copyWith(status: ProfessionalStateStatus.loading));

    try {
      final profile = await _remoteDataSource.getMyProfile();
      final requests = await _remoteDataSource.getMyRequests();
      final pendingRequests = await _remoteDataSource.getPendingRequests();

      emit(state.copyWith(
        status: ProfessionalStateStatus.loaded,
        profile: profile,
        myRequests: requests,
        pendingRequests: pendingRequests,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfessionalStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStatusToggled(
    ProfessionalStatusToggled event,
    Emitter<ProfessionalState> emit,
  ) async {
    emit(state.copyWith(status: ProfessionalStateStatus.updating));

    try {
      final newStatus = event.isAvailable
          ? ProfessionalStatus.available
          : ProfessionalStatus.offline;

      final profile = await _remoteDataSource.updateStatus(newStatus);

      emit(state.copyWith(
        status: ProfessionalStateStatus.updated,
        profile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfessionalStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLocationUpdated(
    ProfessionalLocationUpdated event,
    Emitter<ProfessionalState> emit,
  ) async {
    try {
      final profile = await _remoteDataSource.updateLocation(
        event.latitude,
        event.longitude,
      );

      emit(state.copyWith(profile: profile));
    } catch (e) {
      // Silently fail for location updates
    }
  }

  Future<void> _onRequestsLoadRequested(
    ProfessionalRequestsLoadRequested event,
    Emitter<ProfessionalState> emit,
  ) async {
    try {
      final requests = await _remoteDataSource.getMyRequests();
      final pendingRequests = await _remoteDataSource.getPendingRequests();

      emit(state.copyWith(
        myRequests: requests,
        pendingRequests: pendingRequests,
      ));
    } catch (e) {
      // Silently fail for refresh
    }
  }

  Future<void> _onRequestAccepted(
    ProfessionalRequestAccepted event,
    Emitter<ProfessionalState> emit,
  ) async {
    emit(state.copyWith(status: ProfessionalStateStatus.updating));

    try {
      final request = await _remoteDataSource.acceptRequest(event.requestId);

      // Refresh lists
      final requests = await _remoteDataSource.getMyRequests();
      final pendingRequests = await _remoteDataSource.getPendingRequests();

      emit(state.copyWith(
        status: ProfessionalStateStatus.updated,
        activeRequest: request,
        myRequests: requests,
        pendingRequests: pendingRequests,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfessionalStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRequestRejected(
    ProfessionalRequestRejected event,
    Emitter<ProfessionalState> emit,
  ) async {
    emit(state.copyWith(status: ProfessionalStateStatus.updating));

    try {
      await _remoteDataSource.rejectRequest(event.requestId);

      // Refresh lists
      final requests = await _remoteDataSource.getMyRequests();
      final pendingRequests = await _remoteDataSource.getPendingRequests();

      emit(state.copyWith(
        status: ProfessionalStateStatus.updated,
        myRequests: requests,
        pendingRequests: pendingRequests,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfessionalStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRequestStatusUpdated(
    ProfessionalRequestStatusUpdated event,
    Emitter<ProfessionalState> emit,
  ) async {
    emit(state.copyWith(status: ProfessionalStateStatus.updating));

    try {
      final request = await _remoteDataSource.updateRequestStatus(
        event.requestId,
        event.status,
        prescribedMedications: event.prescribedMedications,
        suggestedPharmacistId: event.suggestedPharmacistId,
      );

      // Refresh lists
      final requests = await _remoteDataSource.getMyRequests();
      final pendingRequests = await _remoteDataSource.getPendingRequests();

      emit(state.copyWith(
        status: ProfessionalStateStatus.updated,
        activeRequest: request,
        myRequests: requests,
        pendingRequests: pendingRequests,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfessionalStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

