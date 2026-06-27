import 'package:equatable/equatable.dart';
import '../../domain/entities/care_request.dart';

enum CareRequestStateStatus {
  initial,
  loading,
  success,
  creating,
  created,
  cancelling,
  cancelled,
  failure,
}

class CareRequestState extends Equatable {
  final CareRequestStateStatus status;
  final List<CareRequest> requests;
  final CareRequest? activeRequest;
  final CareRequest? lastCreatedRequest;
  final String? errorMessage;

  const CareRequestState({
    this.status = CareRequestStateStatus.initial,
    this.requests = const [],
    this.activeRequest,
    this.lastCreatedRequest,
    this.errorMessage,
  });

  CareRequestState copyWith({
    CareRequestStateStatus? status,
    List<CareRequest>? requests,
    CareRequest? activeRequest,
    CareRequest? lastCreatedRequest,
    String? errorMessage,
    bool clearActiveRequest = false,
    bool clearLastCreated = false,
  }) {
    return CareRequestState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      activeRequest: clearActiveRequest ? null : (activeRequest ?? this.activeRequest),
      lastCreatedRequest: clearLastCreated ? null : (lastCreatedRequest ?? this.lastCreatedRequest),
      errorMessage: errorMessage,
    );
  }

  bool get hasActiveRequest => activeRequest != null;

  @override
  List<Object?> get props => [status, requests, activeRequest, lastCreatedRequest, errorMessage];
}

