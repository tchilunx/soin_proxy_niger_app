class AppConstants {
  AppConstants._();

  static const String appName = 'SoinProxi-Niger';
  static const String appVersion = '1.0.0';
  
  // Assets paths
  static const String logoPath = 'assets/images/logo_soin_proxy_niger.jpeg';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String userRoleKey = 'user_role';

  // User roles
  static const String rolePatient = 'patient';
  static const String roleMedicalProfessional = 'medical_professional';
  static const String rolePharmacist = 'pharmacist';

  // Professional types
  static const String professionDoctor = 'doctor';
  static const String professionNurse = 'nurse';

  // Care request statuses
  static const String statusPending = 'pending';
  static const String statusAssigned = 'assigned';
  static const String statusAccepted = 'accepted';
  static const String statusOnRoute = 'on_route';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Professional statuses
  static const String professionalOffline = 'offline';
  static const String professionalAvailable = 'available';
  static const String professionalOnRoute = 'on_route';
  static const String professionalBusy = 'busy';

  // Location update interval (in seconds)
  static const int locationUpdateInterval = 10;

  // Search radius (in km)
  static const double defaultSearchRadius = 10.0;
}

