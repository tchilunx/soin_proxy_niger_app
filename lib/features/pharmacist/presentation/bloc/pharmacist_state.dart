import 'package:equatable/equatable.dart';
import '../../domain/entities/pharmacist.dart';
import '../../domain/entities/prescription_request.dart';

enum PharmacistStateStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  failure,
}

class PharmacistState extends Equatable {
  final PharmacistStateStatus status;
  final Pharmacist? profile;
  final List<PrescriptionRequest> pendingRequests;
  final List<PrescriptionRequest> myRequests;
  final PrescriptionRequest? activeRequest;
  final String? errorMessage;

  const PharmacistState({
    this.status = PharmacistStateStatus.initial,
    this.profile,
    this.pendingRequests = const [],
    this.myRequests = const [],
    this.activeRequest,
    this.errorMessage,
  });

  bool get isAvailable => profile?.isAvailable ?? false;

  int get pendingCount => pendingRequests.length;

  List<PrescriptionRequest> get inProgressRequests => myRequests
      .where((r) =>
          r.status == PrescriptionRequestStatus.accepted ||
          r.status == PrescriptionRequestStatus.preparing ||
          r.status == PrescriptionRequestStatus.ready ||
          r.status == PrescriptionRequestStatus.onRoute)
      .toList();

  List<PrescriptionRequest> get completedRequests => myRequests
      .where((r) => r.status == PrescriptionRequestStatus.delivered)
      .toList();

  PharmacistState copyWith({
    PharmacistStateStatus? status,
    Pharmacist? profile,
    List<PrescriptionRequest>? pendingRequests,
    List<PrescriptionRequest>? myRequests,
    PrescriptionRequest? activeRequest,
    String? errorMessage,
    bool clearActiveRequest = false,
  }) {
    return PharmacistState(
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


