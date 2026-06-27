class ApiConstants {
  ApiConstants._();

  // Base URL — configurable via --dart-define=API_BASE_URL=https://...
  // Default: Android emulator → 10.0.2.2:3000 | iOS → localhost:3000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // WebSocket — dérivé de baseUrl (http→ws, https→wss)
  static String get wsBaseUrl {
    final ws = baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$ws/cable';
  }

  // Auth endpoints
  static const String login = '$apiBaseUrl/auth/login';
  static const String register = '$apiBaseUrl/auth/register';

  // Patient endpoints
  static const String patient = '$apiBaseUrl/patient';

  // Medical Professional endpoints
  static const String medicalProfessionals = '$apiBaseUrl/medical_professionals';

  // Care Request endpoints
  static const String careRequests = '$apiBaseUrl/care_requests';

  // Pharmacist endpoints
  static const String pharmacists = '$apiBaseUrl/pharmacists';

  // Prescription Request endpoints
  static const String prescriptionRequests = '$apiBaseUrl/prescription_requests';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

