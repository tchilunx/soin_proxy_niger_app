import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/care_request_repository.dart';
import 'care_request_event.dart';
import 'care_request_state.dart';

@injectable
class CareRequestBloc extends Bloc<CareRequestEvent, CareRequestState> {
  final CareRequestRepository _repository;

  CareRequestBloc(this._repository) : super(const CareRequestState()) {
    on<CareRequestCreateRequested>(_onCreateRequested);
    on<CareRequestListRequested>(_onListRequested);
    on<CareRequestCancelRequested>(_onCancelRequested);
    on<CareRequestActiveChecked>(_onActiveChecked);
    on<CareRequestRefreshRequested>(_onRefreshRequested);
    on<CareRequestRatingSubmitted>(_onRatingSubmitted);
    on<CareRequestDeliveryRequested>(_onDeliveryRequested);
  }

  Future<void> _onCreateRequested(
    CareRequestCreateRequested event,
    Emitter<CareRequestState> emit,
  ) async {
    emit(state.copyWith(status: CareRequestStateStatus.creating));

    final result = await _repository.createCareRequest(
      professionType: event.professionType,
      latitude: event.latitude,
      longitude: event.longitude,
      address: event.address,
      notes: event.notes,
      isUrgent: event.isUrgent,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CareRequestStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) => emit(state.copyWith(
        status: CareRequestStateStatus.created,
        activeRequest: request,
        lastCreatedRequest: request,
      )),
    );
  }

  Future<void> _onListRequested(
    CareRequestListRequested event,
    Emitter<CareRequestState> emit,
  ) async {
    emit(state.copyWith(status: CareRequestStateStatus.loading));

    final result = await _repository.getCareRequests();

    result.fold(
      (failure) => emit(state.copyWith(
        status: CareRequestStateStatus.failure,
        errorMessage: failure.message,
      )),
      (requests) => emit(state.copyWith(
        status: CareRequestStateStatus.success,
        requests: requests,
      )),
    );
  }

  Future<void> _onCancelRequested(
    CareRequestCancelRequested event,
    Emitter<CareRequestState> emit,
  ) async {
    emit(state.copyWith(status: CareRequestStateStatus.cancelling));

    final result = await _repository.cancelCareRequest(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: CareRequestStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) => emit(state.copyWith(
        status: CareRequestStateStatus.cancelled,
        clearActiveRequest: true,
      )),
    );
  }

  Future<void> _onActiveChecked(
    CareRequestActiveChecked event,
    Emitter<CareRequestState> emit,
  ) async {
    emit(state.copyWith(status: CareRequestStateStatus.loading));

    final result = await _repository.getActiveRequest();

    result.fold(
      (failure) => emit(state.copyWith(
        status: CareRequestStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) => emit(state.copyWith(
        status: CareRequestStateStatus.success,
        activeRequest: request,
        clearActiveRequest: request == null,
      )),
    );
  }

  Future<void> _onRefreshRequested(
    CareRequestRefreshRequested event,
    Emitter<CareRequestState> emit,
  ) async {
    add(const CareRequestActiveChecked());
    add(const CareRequestListRequested());
  }

  Future<void> _onRatingSubmitted(
    CareRequestRatingSubmitted event,
    Emitter<CareRequestState> emit,
  ) async {
    emit(state.copyWith(status: CareRequestStateStatus.loading));

    final result = await _repository.submitRating(
      requestId: event.requestId,
      rating: event.rating,
      comment: event.comment,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CareRequestStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) {
        // Update the request in the list
        final updatedRequests = state.requests.map((r) {
          return r.id == request.id ? request : r;
        }).toList();
        
        emit(state.copyWith(
          status: CareRequestStateStatus.success,
          requests: updatedRequests,
        ));
      },
    );
  }

  Future<void> _onDeliveryRequested(
    CareRequestDeliveryRequested event,
    Emitter<CareRequestState> emit,
  ) async {
    emit(state.copyWith(status: CareRequestStateStatus.loading));

    final result = await _repository.requestDelivery(event.requestId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: CareRequestStateStatus.failure,
        errorMessage: failure.message,
      )),
      (request) {
        // Update the request in the list
        final updatedRequests = state.requests.map((r) {
          return r.id == request.id ? request : r;
        }).toList();
        
        emit(state.copyWith(
          status: CareRequestStateStatus.success,
          requests: updatedRequests,
        ));
      },
    );
  }
}

