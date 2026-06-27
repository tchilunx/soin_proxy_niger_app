import 'package:equatable/equatable.dart';

enum ProfessionalStatus {
  offline,
  available,
  onRoute,
  busy,
}

enum Profession {
  doctor,
  nurse,
}

class MedicalProfessional extends Equatable {
  final int? id;
  final int? userId;
  final Profession profession;
  final ProfessionalStatus status;
  final String? licenseNumber;
  final List<String>? specialties;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationAt;
  final String? userFullName;
  final String? userEmail;
  final String? userPhone;

  const MedicalProfessional({
    this.id,
    this.userId,
    this.profession = Profession.doctor,
    this.status = ProfessionalStatus.offline,
    this.licenseNumber,
    this.specialties,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationAt,
    this.userFullName,
    this.userEmail,
    this.userPhone,
  });

  bool get isAvailable => status == ProfessionalStatus.available;
  bool get isOffline => status == ProfessionalStatus.offline;

  MedicalProfessional copyWith({
    int? id,
    int? userId,
    Profession? profession,
    ProfessionalStatus? status,
    String? licenseNumber,
    List<String>? specialties,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationAt,
    String? userFullName,
    String? userEmail,
    String? userPhone,
  }) {
    return MedicalProfessional(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profession: profession ?? this.profession,
      status: status ?? this.status,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialties: specialties ?? this.specialties,
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
        profession,
        status,
        licenseNumber,
        specialties,
        currentLatitude,
        currentLongitude,
        lastLocationAt,
        userFullName,
        userEmail,
        userPhone,
      ];
}

