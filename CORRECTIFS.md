# Plan de correctifs — SoinProxi Niger (MediNear)

> Audit réalisé le 2026-06-27. Ce document est la référence d'implémentation.
> Attaquer les phases dans l'ordre : les phases suivantes supposent que les précédentes sont terminées.

---

## Phase 1 — Bugs bloquants `~2-3 jours`

### BUG-01 — Annulation de demande sans appel API
**Fichier :** `lib/features/care_request/presentation/pages/care_request_tracking_page.dart` ligne 488  
**Symptôme :** Le bouton "Annuler la demande" navigue vers `/patient` sans jamais appeler le backend. La demande reste `pending` en base.  
**Correction :**
```dart
// Dans _showCancelDialog, remplacer :
ElevatedButton(
  onPressed: () {
    Navigator.pop(context);
    context.go('/patient'); // ← BUG : pas d'appel API
  },

// Par :
ElevatedButton(
  onPressed: () {
    Navigator.pop(context);
    context.read<CareRequestBloc>().add(
      CareRequestCancelRequested(request!.id!),
    );
    // La navigation vers /patient se fait via BlocListener sur status == cancelled
  },
```
**Ajouter un `BlocListener`** dans `CareRequestTrackingPage` qui réagit à `CareRequestStateStatus.cancelled` pour faire `context.go('/patient')`.

---

### BUG-02 — `copyWith` cassé sur `deliveryRequested`
**Fichier :** `lib/features/care_request/domain/entities/care_request.dart` ligne 100  
**Symptôme :** Le paramètre `deliveryRequested` est absent de la signature de `copyWith` — impossible de passer `deliveryRequested: false`.  
**Correction :** Ajouter `bool? deliveryRequested` dans la signature et dans le corps :
```dart
CareRequest copyWith({
  // ... autres paramètres existants ...
  bool? deliveryRequested, // ← AJOUTER
}) {
  return CareRequest(
    // ... autres champs ...
    deliveryRequested: deliveryRequested ?? this.deliveryRequested, // ← AJOUTER
  );
}
```

---

### BUG-03 — `_subscription` typé `dynamic` dans GoRouterRefreshStream
**Fichier :** `lib/core/router/app_router.dart` ligne 250  
**Symptôme :** `late final dynamic _subscription` — perte de sécurité de type, `.cancel()` invoqué sans garantie.  
**Correction :**
```dart
// Remplacer :
late final dynamic _subscription;

// Par :
late final StreamSubscription<AuthState> _subscription;
```
**Ajouter l'import :**
```dart
import 'dart:async';
```

---

### BUG-04 — `accepted_at` généré côté client
**Fichier :** `lib/features/professional/data/datasources/professional_remote_datasource.dart` ligne 158  
**Symptôme :** Le timestamp `accepted_at` est `DateTime.now()` côté Flutter — dérives d'horloge possibles, manipulable.  
**Correction :** Supprimer `accepted_at` du payload, laisser le serveur le générer :
```dart
// Remplacer :
data: {
  'care_request': {
    'status': 'accepted',
    'accepted_at': DateTime.now().toIso8601String(), // ← SUPPRIMER
  },
},

// Par :
data: {
  'care_request': {
    'status': 'accepted',
  },
},
```

---

### BUG-05 — Route `/pharmacist/request/:id` = stub non implémenté
**Fichier :** `lib/core/router/app_router.dart` lignes 202-209  
**Symptôme :** Affiche un `Scaffold` avec `Text('Détails de la demande $id')`.  
**Correction :** Créer `lib/features/pharmacist/presentation/pages/pharmacist_request_detail_page.dart` qui charge et affiche `CareRequest` via `CareRequestBloc` (événement `CareRequestGetById`) et le relier dans le router.

---

## Phase 2 — Architecture : aligner `Professional` sur les autres features `~1-2 jours`

### ARCH-01 — Créer la couche Repository pour `Professional`
`ProfessionalBloc` appelle directement `ProfessionalRemoteDataSource` — violation de la Clean Architecture. Aucune gestion `Either<Failure, T>`.

**Fichiers à créer :**
- `lib/features/professional/domain/repositories/professional_repository.dart`
- `lib/features/professional/data/repositories/professional_repository_impl.dart`

**Interface à définir :**
```dart
abstract class ProfessionalRepository {
  Future<Either<Failure, MedicalProfessional>> getMyProfile();
  Future<Either<Failure, MedicalProfessional>> updateStatus(ProfessionalStatus status);
  Future<Either<Failure, MedicalProfessional>> updateLocation(double lat, double lng);
  Future<Either<Failure, List<CareRequest>>> getPendingRequests();
  Future<Either<Failure, List<CareRequest>>> getMyRequests();
  Future<Either<Failure, CareRequest>> acceptRequest(int requestId);
  Future<Either<Failure, CareRequest>> rejectRequest(int requestId);
  Future<Either<Failure, CareRequest>> updateRequestStatus(int requestId, String status, {String? prescribedMedications, int? suggestedPharmacistId});
}
```

**Modifier `ProfessionalBloc`** pour injecter `ProfessionalRepository` et utiliser `result.fold(...)`.

**Enregistrer dans `injection.dart` :**
```dart
getIt.registerLazySingleton<ProfessionalRepository>(
  () => ProfessionalRepositoryImpl(getIt<ProfessionalRemoteDataSource>()),
);
getIt.registerFactory<ProfessionalBloc>(
  () => ProfessionalBloc(getIt<ProfessionalRepository>()),
);
```

---

### ARCH-02 — Uniformiser l'injection (supprimer `@injectable` orphelin)
**Fichier :** `lib/features/care_request/presentation/bloc/care_request_bloc.dart` ligne 7  
Retirer l'annotation `@injectable` — l'injection est 100% manuelle, la codegen n'est pas configurée.

---

### ARCH-03 — Corriger `wsBaseUrl` pour supporter `wss://`
**Fichier :** `lib/core/constants/api_constants.dart` ligne 15  
**Correction :** Dériver automatiquement `ws://` ou `wss://` selon le scheme de `baseUrl` :
```dart
static String get wsBaseUrl {
  final base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000');
  final wsBase = base.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
  return '$wsBase/cable';
}
```

---

## Phase 3 — Fonctionnalités core manquantes `~3-5 jours`

### FEAT-01 — Temps réel : WebSocket pour le suivi de statut
**Contexte :** Le backend semble être Rails avec Action Cable (`/cable`). `web_socket_channel` est déjà dans les dépendances.

**Fichier à créer :** `lib/core/services/web_socket_service.dart`
```dart
class WebSocketService {
  WebSocketChannel? _channel;

  void connect(String token) {
    _channel = WebSocketChannel.connect(
      Uri.parse('${ApiConstants.wsBaseUrl}?token=$token'),
    );
  }

  Stream<dynamic> subscribeToRequest(int requestId) {
    _sendSubscription('CareRequestChannel', {'request_id': requestId});
    return _channel!.stream;
  }

  void _sendSubscription(String channelName, Map<String, dynamic> params) {
    _channel?.sink.add(jsonEncode({
      'command': 'subscribe',
      'identifier': jsonEncode({'channel': channelName, ...params}),
    }));
  }

  void disconnect() => _channel?.sink.close();
}
```

**Intégrer dans `CareRequestTrackingPage` :**
- `initState` → `webSocketService.subscribeToRequest(request.id)` → écouter les messages → dispatcher `CareRequestStatusUpdated` dans le bloc.

**Intégrer dans `ProfessionalHomePage` :**
- Écouter `ProfessionalRequestsChannel` pour recevoir les nouvelles demandes en temps réel et dispatcher `ProfessionalRequestsLoadRequested`.

---

### FEAT-02 — Google Maps réel dans NavigationPage
**Fichier :** `lib/features/professional/presentation/pages/navigation_page.dart`  
**Action :** Remplacer `CustomPainter` fictif par `GoogleMap` widget :
```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(request!.latitude!, request.longitude!),
    zoom: 15,
  ),
  markers: {
    Marker(
      markerId: const MarkerId('patient'),
      position: LatLng(request.latitude!, request.longitude!),
      infoWindow: InfoWindow(title: request.patientName ?? 'Patient'),
    ),
  },
  myLocationEnabled: true,
  myLocationButtonEnabled: true,
)
```
**Prérequis :** Ajouter la clé API Google Maps dans `android/app/src/main/AndroidManifest.xml` et `ios/Runner/AppDelegate.swift`.

**Optionnel :** Intégrer Directions API pour tracer l'itinéraire.

---

### FEAT-03 — GPS réel dans le formulaire de demande patient
**Fichier :** `lib/features/care_request/presentation/pages/care_request_form_page.dart`  
**Action :** Utiliser `geolocator` (déjà en dépendance) pour obtenir la position GPS du patient :
```dart
Future<void> _getLocation() async {
  final permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) return;
  
  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  
  setState(() {
    _latitude = position.latitude;
    _longitude = position.longitude;
  });
  
  // Optionnel : reverse geocoding pour remplir le champ adresse
}
```
Appeler `_getLocation()` dans `initState`.

**Permissions à ajouter :**
- Android : `ACCESS_FINE_LOCATION` dans `AndroidManifest.xml`
- iOS : `NSLocationWhenInUseUsageDescription` dans `Info.plist`

---

### FEAT-04 — Mise à jour périodique de localisation du professionnel
**Fichier :** `lib/features/professional/presentation/bloc/professional_bloc.dart`  
**Action :** Démarrer un `Timer.periodic` quand le professionnel est `available` ou `on_route` :
```dart
Timer? _locationTimer;

// Dans _onStatusToggled, quand isAvailable = true :
_locationTimer = Timer.periodic(const Duration(seconds: 45), (_) {
  _updateCurrentLocation();
});

// Arrêter quand offline ou completed :
_locationTimer?.cancel();

Future<void> _updateCurrentLocation() async {
  final position = await Geolocator.getCurrentPosition();
  add(ProfessionalLocationUpdated(position.latitude, position.longitude));
}
```

---

### FEAT-05 — Appel téléphonique depuis le suivi patient
**Fichier :** `lib/features/care_request/presentation/pages/care_request_tracking_page.dart` ligne 286  
**Action :** Implémenter le `onPressed` du bouton téléphone (déjà visible dans l'UI) :
```dart
onPressed: () async {
  final phone = request.professionalPhone;
  if (phone != null) {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
},
```
`url_launcher` est déjà dans les dépendances.

---

### FEAT-06 — Distance réelle dans ProfessionalHomePage
**Fichier :** `lib/features/professional/presentation/pages/professional_home_page.dart` ligne 617  
**Action :** Remplacer `return '~2 km'` par un calcul réel :
```dart
String _calculateDistance(CareRequest request) {
  if (request.latitude == null || request.longitude == null) return 'N/A';
  // state.profile contient la position courante du professionnel
  final profLat = state.profile?.currentLatitude;
  final profLng = state.profile?.currentLongitude;
  if (profLat == null || profLng == null) return 'N/A';
  
  final distanceMeters = Geolocator.distanceBetween(
    profLat, profLng,
    request.latitude!, request.longitude!,
  );
  final km = distanceMeters / 1000;
  return '${km.toStringAsFixed(1)} km';
}
```

---

## Phase 4 — Fonctionnalités complémentaires `~3-4 jours`

### FEAT-07 — Refresh token sur 401
**Fichier :** `lib/core/network/api_client.dart`  
**Action :** Dans `_onError`, tenter un refresh avant de clear :
```dart
Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
  if (error.response?.statusCode == 401) {
    final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
    if (refreshToken != null) {
      try {
        final response = await _dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
        final newToken = response.data['token'] as String;
        await _storage.write(key: AppConstants.tokenKey, value: newToken);
        // Rejouer la requête originale
        error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await _dio.fetch(error.requestOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        // Refresh échoué → déconnexion
      }
    }
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }
  handler.next(error);
}
```
**Prérequis :** Le backend doit exposer `/api/v1/auth/refresh`. Ajouter `AppConstants.refreshTokenKey` et sauvegarder le refresh token lors du login/register.

---

### FEAT-08 — Push notifications (FCM)
**Dépendances à ajouter :**
```yaml
dependencies:
  firebase_core: ^3.x.x
  firebase_messaging: ^15.x.x
```

**Service à créer :** `lib/core/services/notification_service.dart`
- Initialiser Firebase dans `main.dart`
- Demander les permissions iOS
- Envoyer le FCM token au backend via `PATCH /api/v1/users/me` avec `fcm_token`
- Gérer les messages en foreground, background et terminated

**Triggers backend à configurer :**
- Quand une demande est `assigned` → notification au patient
- Quand une nouvelle demande `pending` arrive → notification aux professionnels disponibles à proximité
- Quand la demande est `accepted` → notification au patient

---

### FEAT-09 — Pages profil implémentées
**Fichiers à créer :**
- `lib/features/patient/presentation/pages/patient_profile_edit_page.dart`
- `lib/features/professional/presentation/pages/professional_profile_edit_page.dart`

**Champs éditables patient :** `full_name`, `phone`  
**Endpoint :** `PATCH /api/v1/patient`

**Champs éditables professionnel :** `full_name`, `phone`, `specialties`  
**Endpoint :** `PATCH /api/v1/medical_professionals/me`

Relier les `onTap: () {}` vides dans les pages profil vers ces nouvelles pages.

---

## Phase 5 — Qualité et robustesse `~2 jours`

### QUAL-01 — Migrer vers `freezed` + `json_serializable` ou supprimer
**Choix :** Les dépendances `freezed`, `json_annotation`, `json_serializable`, `build_runner`, `freezed_annotation` sont présentes mais aucun modèle n'est généré.

**Option A (recommandée) :** Migrer `CareRequest`, `User`, `MedicalProfessional` vers `@freezed` pour :
- `copyWith` généré automatiquement (résout BUG-02 à jamais)
- `fromJson`/`toJson` générés (moins d'erreurs parsing)
- Pattern matching sur les états

**Option B :** Supprimer toutes ces dépendances de `pubspec.yaml` pour allèger le projet.

---

### QUAL-02 — Tests unitaires BLoCs critiques
**Fichiers à créer :**
- `test/features/auth/auth_bloc_test.dart`
- `test/features/care_request/care_request_bloc_test.dart`

Tester les flux principaux : login/logout, création de demande, annulation, rating.

---

### QUAL-03 — Gestion offline
**Fichier :** `lib/core/network/api_client.dart`  
Détecter l'absence de réseau avant les appels (via `connectivity_plus` package) et émettre une `NetworkFailure` claire sans attendre le timeout de 30s.

---

## Checklist de suivi

### Phase 1 — Bugs bloquants
- [ ] BUG-01 : Annulation demande appelle l'API
- [ ] BUG-02 : `copyWith` avec `deliveryRequested`
- [ ] BUG-03 : `_subscription` typé `StreamSubscription<AuthState>`
- [ ] BUG-04 : Supprimer `accepted_at` côté client
- [ ] BUG-05 : Page détail demande pharmacien implémentée

### Phase 2 — Architecture
- [ ] ARCH-01 : Repository + impl pour Professional
- [ ] ARCH-01 : ProfessionalBloc utilise Either<Failure,T>
- [ ] ARCH-01 : Enregistré dans injection.dart
- [ ] ARCH-02 : Annotation `@injectable` retirée de CareRequestBloc
- [ ] ARCH-03 : `wsBaseUrl` dérivé dynamiquement

### Phase 3 — Features core
- [ ] FEAT-01 : WebSocketService créé
- [ ] FEAT-01 : CareRequestTrackingPage écoute WebSocket
- [ ] FEAT-01 : ProfessionalHomePage écoute nouvelles demandes en temps réel
- [ ] FEAT-02 : GoogleMap réel dans NavigationPage
- [ ] FEAT-03 : GPS réel dans formulaire de demande
- [ ] FEAT-04 : Timer localisation professionnel
- [ ] FEAT-05 : Appel téléphonique depuis tracking patient
- [ ] FEAT-06 : Distance réelle calculée

### Phase 4 — Features complémentaires
- [ ] FEAT-07 : Refresh token sur 401
- [ ] FEAT-08 : Push notifications FCM
- [ ] FEAT-09 : Pages profil éditables

### Phase 5 — Qualité
- [ ] QUAL-01 : Décision freezed (migrer ou supprimer)
- [ ] QUAL-02 : Tests unitaires AuthBloc et CareRequestBloc
- [ ] QUAL-03 : Gestion offline avec connectivity_plus
