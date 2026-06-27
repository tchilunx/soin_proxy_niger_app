import '../../domain/entities/pharmacist.dart';

class PharmacistModel extends Pharmacist {
  const PharmacistModel({
    super.id,
    super.userId,
    super.pharmacyName,
    super.licenseNumber,
    super.address,
    super.status,
    super.currentLatitude,
    super.currentLongitude,
    super.lastLocationAt,
    super.userFullName,
    super.userEmail,
    super.userPhone,
  });

  factory PharmacistModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    
    return PharmacistModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int? ?? user?['id'] as int?,
      pharmacyName: json['pharmacy_name'] as String?,
      licenseNumber: json['license_number'] as String?,
      address: json['address'] as String?,
      status: _parseStatus(json['status']),
      currentLatitude: _parseDouble(json['current_latitude']),
      currentLongitude: _parseDouble(json['current_longitude']),
      lastLocationAt: json['last_location_at'] != null
          ? DateTime.tryParse(json['last_location_at'])
          : null,
      userFullName: user?['full_name'] as String? ?? json['user_full_name'] as String?,
      userEmail: user?['email'] as String? ?? json['user_email'] as String?,
      userPhone: user?['phone'] as String? ?? json['user_phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (pharmacyName != null) 'pharmacy_name': pharmacyName,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (address != null) 'address': address,
      'status': _statusToString(status),
      if (currentLatitude != null) 'current_latitude': currentLatitude,
      if (currentLongitude != null) 'current_longitude': currentLongitude,
    };
  }

  static PharmacistStatus _parseStatus(dynamic value) {
    if (value == null) return PharmacistStatus.offline;
    final str = value.toString().toLowerCase();
    switch (str) {
      case 'available':
      case '1':
        return PharmacistStatus.available;
      case 'on_route':
      case 'onRoute':
      case '2':
        return PharmacistStatus.onRoute;
      case 'busy':
      case '3':
        return PharmacistStatus.busy;
      default:
        return PharmacistStatus.offline;
    }
  }

  static String _statusToString(PharmacistStatus status) {
    switch (status) {
      case PharmacistStatus.available:
        return 'available';
      case PharmacistStatus.onRoute:
        return 'on_route';
      case PharmacistStatus.busy:
        return 'busy';
      default:
        return 'offline';
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}


