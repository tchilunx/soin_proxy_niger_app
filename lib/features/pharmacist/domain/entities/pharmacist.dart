import 'package:equatable/equatable.dart';

enum PharmacistStatus {
  offline,
  available,
  onRoute,
  busy,
}

class Pharmacist extends Equatable {
  final int? id;
  final int? userId;
  final String? pharmacyName;
  final String? licenseNumber;
  final String? address;
  final PharmacistStatus status;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationAt;
  final String? userFullName;
  final String? userEmail;
  final String? userPhone;

  const Pharmacist({
    this.id,
    this.userId,
    this.pharmacyName,
    this.licenseNumber,
    this.address,
    this.status = PharmacistStatus.offline,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationAt,
    this.userFullName,
    this.userEmail,
    this.userPhone,
  });

  bool get isAvailable => status == PharmacistStatus.available;
  bool get isOffline => status == PharmacistStatus.offline;

  Pharmacist copyWith({
    int? id,
    int? userId,
    String? pharmacyName,
    String? licenseNumber,
    String? address,
    PharmacistStatus? status,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationAt,
    String? userFullName,
    String? userEmail,
    String? userPhone,
  }) {
    return Pharmacist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      address: address ?? this.address,
      status: status ?? this.status,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastLocationAt: lastLocationAt ?? this.lastLocationAt,
      userFullName: userFullName ?? this.userFullName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        pharmacyName,
        licenseNumber,
        address,
        status,
        currentLatitude,
        currentLongitude,
        lastLocationAt,
        userFullName,
        userEmail,
        userPhone,
      ];
}


