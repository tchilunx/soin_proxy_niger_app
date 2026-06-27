import 'package:equatable/equatable.dart';
import '../../domain/entities/care_request.dart';

abstract class CareRequestEvent extends Equatable {
  const CareRequestEvent();

  @override
  List<Object?> get props => [];
}

class CareRequestCreateRequested extends CareRequestEvent {
  final ProfessionType professionType;
  final double latitude;
  final double longitude;
  final String? address;
  final String? notes;
  final bool isUrgent;

  const CareRequestCreateRequested({
    required this.professionType,
    required this.latitude,
    required this.longitude,
    this.address,
    this.notes,
    this.isUrgent = false,
  });

  @override
  List<Object?> get props => [professionType, latitude, longitude, address, notes, isUrgent];
}

class CareRequestListRequested extends CareRequestEvent {
  const CareRequestListRequested();
}

class CareRequestCancelRequested extends CareRequestEvent {
  final int requestId;

  const CareRequestCancelRequested(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class CareRequestActiveChecked extends CareRequestEvent {
  const CareRequestActiveChecked();
}

class CareRequestRefreshRequested extends CareRequestEvent {
  const CareRequestRefreshRequested();
}

class CareRequestRatingSubmitted extends CareRequestEvent {
  final int requestId;
  final int rating;
  final String? comment;

  const CareRequestRatingSubmitted({
    required this.requestId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [requestId, rating, comment];
}

class CareRequestDeliveryRequested extends CareRequestEvent {
  final int requestId;

  const CareRequestDeliveryRequested({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

