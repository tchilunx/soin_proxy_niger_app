import 'package:equatable/equatable.dart';
import '../../../care_request/domain/entities/care_request.dart';
import '../../domain/entities/medical_professional.dart';

enum ProfessionalStateStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  failure,
}

class ProfessionalState extends Equatable {
  final ProfessionalStateStatus status;
  final MedicalProfessional? profile;
  final List<CareRequest> pendingRequests;
  final List<CareRequest> myRequests;
  final CareRequest? activeRequest;
  final String? errorMessage;

  const ProfessionalState({
    this.status = ProfessionalStateStatus.initial,
    this.profile,
    this.pendingRequests = const [],
    this.myRequests = const [],
    this.activeRequest,
    this.errorMessage,
  });

  bool get isAvailable => profile?.isAvailable ?? false;

  int get pendingCount => pendingRequests.length;

  List<CareRequest> get inProgressRequests => myRequests
      .where((r) =>
          r.status == CareRequestStatus.assigned ||
          r.status == CareRequestStatus.accepted ||
          r.status == CareRequestStatus.onRoute ||
          r.status == CareRequestStatus.inProgress)
      .toList();

  List<CareRequest> get completedRequests => myRequests
      .where((r) => r.status == CareRequestStatus.completed)
      .toList();

  ProfessionalState copyWith({
    ProfessionalStateStatus? status,
    MedicalProfessional? profile,
    List<CareRequest>? pendingRequests,
    List<CareRequest>? myRequests,
    CareRequest? activeRequest,
    String? errorMessage,
    bool clearActiveRequest = false,
  }) {
    return ProfessionalState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      myRequests: myRequests ?? this.myRequests,
      activeRequest: clearActiveRequest ? null : (activeRequest ?? this.activeRequest),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        pendingRequests,
        myRequests,
        activeRequest,
        errorMessage,
      ];
}

