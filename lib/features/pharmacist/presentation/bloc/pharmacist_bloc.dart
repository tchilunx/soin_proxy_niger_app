import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/pharmacist_repository.dart';
import '../../domain/entities/pharmacist.dart';
import 'pharmacist_event.dart';
import 'pharmacist_state.dart';

class PharmacistBloc extends Bloc<PharmacistEvent, PharmacistState> {
  final PharmacistRepository _repository;

  PharmacistBloc(this._repository) : super(const PharmacistState()) {
    on<PharmacistLoadRequested>(_onLoadRequested);
    on<PharmacistStatusToggled>(_onStatusToggled);
    on<PharmacistLocationUpdated>(_onLocationUpdated);
    on<PharmacistProfileUpdated>(_onProfileUpdated);
    on<PharmacistRequestsLoadRequested>(_onRequestsLoadRequested);
    on<PrescriptionRequestAccepted>(_onRequestAccepted);
    on<PrescriptionRequestRejected>(_onRequestRejected);
    on<PrescriptionRequestMarkPreparing>(_onMarkPreparing);
    on<PrescriptionRequestMarkReady>(_onMarkReady);
    on<PrescriptionRequestMarkOnRoute>(_onMarkOnRoute);
    on<PrescriptionRequestMarkDelivered>(_onMarkDelivered);
  }

  Future<void> _onLoadRequested(
    PharmacistLoadRequested event,
    Emitter<PharmacistState> emit,
  ) async {
    emit(state.copyWith(status: PharmacistStateStatus.loading));

    final profileResult = await _repository.getMyProfile();
    final requestsResult = await _repository.getMyRequests();
    final pendingResult = await _repository.getPendingRequests();

    profileResult.fold(
      (failure) => emit(state.copyWith(
        status: PharmacistStateStatus.failure,
        errorMessage: failure.message,
      )),
      (profile) {
        requestsResult.fold(
          (failure) => emit(state.copyWith(
            status: PharmacistStateStatus.failure,
            errorMessage: failure.message,
          )),
          (requests) {
            pendingResult.fold(
              (failure) => emit(state.copyWith(
                status: PharmacistStateStatus.failure,
                errorMessage: failure.message,
              )),
              (pendingRequests) => emit(state.copyWith(
                status: PharmacistStateStatus.loaded,
                profile: profile,
                myRequests: requests,
                pendingRequests: pendingRequests,
              )),
            );
          },
        );
      },
    );
  }

  Future<void> _onStatusToggled(
    PharmacistStatusToggled event,
    Emitter<PharmacistState> emit,
  ) async {
    emit(state.copyWith(status: PharmacistStateStatus.updating));

    final newStatus = event.isAvailable
        ? PharmacistStatus.available
        : PharmacistStatus.offline;

    final result = await _repository.updateStatus(newStatus);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PharmacistStateStatus.failure,
        errorMessage: failure.message,
      )),
      (profile) => emit(state.copyWith(
        status: PharmacistStateStatus.updated,
        profile: profile,
      )),
    );
  }

  Future<void> _onLocationUpdated(
    PharmacistLocationUpdated event,
    Emitter<PharmacistState> emit,
  ) async {
    final result = await _repository.updateLocation(
      event.latitude,
      event.longitude,
    );

    result.fold(
      (failure) {
        // Silently fail for location updates
      },
      (profile) => emit(state.copyWith(profile: profile)),
    );
  }

  Future<void> _onProfileUpdated(
    PharmacistProfileUpdated event,
    Emitter<PharmacistState> emit,
  ) async {
    emit(state.copyWith(status: PharmacistStateStatus.updating));

    final result = await _repository.updateProfile(
      pharmacyName: event.pharmacyName,
      address: event.address,
      licenseNumber: event.licenseNumber,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: PharmacistStateStatus.failure,
        errorMessage: failure.message,
      )),
      (profile) => emit(state.copyWith(
        status: PharmacistStateStatus.updated,
        profile: profile,
      )),
    );
  }

  Future<void> _onRequestsLoadRequested(
    PharmacistRequestsLoadRequested event,
    Emitter<PharmacistState> emit,
  ) async {
    final requestsResult = await _repository.getMyRequests();
    final pendingResult = await _repository.getPendingRequests();

    requestsResult.fold(
      (failure) {
        // Silently fail for refresh
      },
      (requests) {
        pendingResult.fold(
          (failure) {
            // Silently fail for refresh
          },
          (pendingRequests) => emit(state.copyWith(
            myRequests: requests,
            pendingRequests: pendingRequests,
          )),
        );
      },
    );
  }

  Future<void> _onRequestAccepted(
    PrescriptionRequestAccepted event,
    Emitter<PharmacistState> emit,
  ) async {
    emit(state.copyWith(status: PharmacistStateStatus.updating));

    final result = await _repository.acceptRequest(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PharmacistStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) async {
        // Refresh lists
        final requestsResult = await _repository.getMyRequests();
        final pendingResult = await _repository.getPendingRequests();

        requestsResult.fold(
          (failure) {
            // Continue with current state
          },
          (requests) {
            pendingResult.fold(
              (failure) {
                // Continue with current state
              },
              (pendingRequests) => emit(state.copyWith(
                status: PharmacistStateStatus.updated,
                activeRequest: request,
                myRequests: requests,
                pendingRequests: pendingRequests,
              )),
            );
          },
        );
      },
    );
  }

  Future<void> _onRequestRejected(
    PrescriptionRequestRejected event,
    Emitter<PharmacistState> emit,
  ) async {
    emit(state.copyWith(status: PharmacistStateStatus.updating));

    final result = await _repository.rejectRequest(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PharmacistStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) async {
        // Refresh lists
        final requestsResult = await _repository.getMyRequests();
        final pendingResult = await _repository.getPendingRequests();

        requestsResult.fold(
          (failure) {
            // Continue with current state
          },
          (requests) {
            pendingResult.fold(
              (failure) {
                // Continue with current state
              },
              (pendingRequests) => emit(state.copyWith(
                status: PharmacistStateStatus.updated,
                myRequests: requests,
                pendingRequests: pendingRequests,
              )),
            );
          },
        );
      },
    );
  }

  Future<void> _onMarkPreparing(
    PrescriptionRequestMarkPreparing event,
    Emitter<PharmacistState> emit,
  ) async {
    emit(state.copyWith(status: PharmacistStateStatus.updating));

    final result = await _repository.markPreparing(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PharmacistStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) async {
        final requestsResult = await _repository.getMyRequests();
        requestsResult.fold(
          (failure) {},
          (requests) => emit(state.copyWith(
            status: PharmacistStateStatus.updated,
            activeRequest: request,
            myRequests: requests,
          )),
        );
      },
    );
  }

  Future<void> _onMarkReady(
    PrescriptionRequestMarkReady event,
    Emitter<PharmacistState> emit,
  ) async {
    emit(state.copyWith(status: PharmacistStateStatus.updating));

    final result = await _repository.markReady(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PharmacistStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) async {
        final requestsResult = await _repository.getMyRequests();
        requestsResult.fold(
          (failure) {},
          (requests) => emit(state.copyWith(
            status: PharmacistStateStatus.updated,
            activeRequest: request,
            myRequests: requests,
          )),
        );
      },
    );
  }

  Future<void> _onMarkOnRoute(
    PrescriptionRequestMarkOnRoute event,
    Emitter<PharmacistState> emit,
  ) async {
    emit(state.copyWith(status: PharmacistStateStatus.updating));

    final result = await _repository.markOnRoute(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PharmacistStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) async {
        final requestsResult = await _repository.getMyRequests();
        requestsResult.fold(
          (failure) {},
          (requests) => emit(state.copyWith(
            status: PharmacistStateStatus.updated,
            activeRequest: request,
            myRequests: requests,
          )),
        );
      },
    );
  }

  Future<void> _onMarkDelivered(
    PrescriptionRequestMarkDelivered event,
    Emitter<PharmacistState> emit,
  ) async {
    emit(state.copyWith(status: PharmacistStateStatus.updating));

    final result = await _repository.markDelivered(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PharmacistStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) async {
        final requestsResult = await _repository.getMyRequests();
        requestsResult.fold(
          (failure) {},
          (requests) => emit(state.copyWith(
            status: PharmacistStateStatus.updated,
            activeRequest: request,
            myRequests: requests,
          )),
        );
      },
    );
  }
}


