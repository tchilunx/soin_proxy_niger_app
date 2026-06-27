import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final int? id;
  final int? userId;
  final String? dateOfBirth;
  final String? medicalNotes;
  final String? userFullName;
  final String? userEmail;
  final String? userPhone;

  const Patient({
    this.id,
    this.userId,
    this.dateOfBirth,
    this.medicalNotes,
    this.userFullName,
    this.userEmail,
    this.userPhone,
  });

  Patient copyWith({
    int? id,
    int? userId,
    String? dateOfBirth,
    String? medicalNotes,
    String? userFullName,
    String? userEmail,
    String? userPhone,
  }) {
    return Patient(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      userFullName: userFullName ?? this.userFullName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
    );
  }

  @override
  List<Object?> get props => [id, userId, dateOfBirth, medicalNotes, userFullName, userEmail, userPhone];
}
