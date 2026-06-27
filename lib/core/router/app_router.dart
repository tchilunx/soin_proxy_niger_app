import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/care_request/domain/entities/care_request.dart';
import '../../features/care_request/presentation/pages/care_request_form_page.dart';
import '../../features/care_request/presentation/pages/care_request_tracking_page.dart';
import '../../features/patient/presentation/pages/patient_home_page.dart';
import '../../features/patient/presentation/pages/search_professional_page.dart';
import '../../features/patient/presentation/pages/search_pharmacist_page.dart';
import '../../features/patient/presentation/pages/consultation_detail_page.dart';
import '../../features/patient/presentation/pages/consultation_rating_page.dart';
import '../../features/professional/presentation/bloc/professional_bloc.dart';
import '../../features/professional/presentation/bloc/professional_event.dart';
import '../../features/professional/presentation/pages/professional_home_page.dart';
import '../../features/professional/presentation/pages/navigation_page.dart';
import '../../features/professional/presentation/pages/consultation_page.dart';
import '../../features/professional/presentation/pages/consultation_detail_page.dart';
import '../../features/professional/presentation/pages/rating_page.dart';
import '../../features/pharmacist/presentation/bloc/pharmacist_bloc.dart';
import '../../features/pharmacist/presentation/bloc/pharmacist_event.dart';
import '../../features/pharmacist/presentation/pages/pharmacist_home_page.dart';
import '../../features/pharmacist/presentation/pages/pharmacist_request_detail_page.dart';
import '../../features/pharmacist/presentation/pages/pharmacist_suggestion_detail_page.dart';
import '../../injection/injection.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _professionalShellKey = GlobalKey<NavigatorState>(debugLabel: 'professionalShell');
  static final _pharmacistShellKey = GlobalKey<NavigatorState>(debugLabel: 'pharmacistShell');

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/login',
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggedIn = authState.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // If not logged in and not on login/register page, redirect to login
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // If logged in and on login/register page, redirect to appropriate home
        if (isLoggedIn && isLoggingIn) {
          if (authState.isPatient) {
            return '/patient';
          } else if (authState.isMedicalProfessional) {
            return '/professional';
          } else if (authState.isPharmacist) {
            return '/pharmacist';
          }
        }

        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        // Patient routes
        GoRoute(
          path: '/patient',
          name: 'patient-home',
          builder: (context, state) => const PatientHomePage(),
          routes: [
            GoRoute(
              path: 'search',
              name: 'patient-search',
              builder: (context, state) => const SearchProfessionalPage(),
            ),
            GoRoute(
              path: 'search-pharmacist',
              name: 'patient-search-pharmacist',
              builder: (context, state) => const SearchPharmacistPage(),
            ),
            GoRoute(
              path: 'request-doctor',
              name: 'patient-request-doctor',
              builder: (context, state) => const CareRequestFormPage(
                professionType: ProfessionType.doctor,
              ),
            ),
            GoRoute(
              path: 'request-nurse',
              name: 'patient-request-nurse',
              builder: (context, state) => const CareRequestFormPage(
                professionType: ProfessionType.nurse,
              ),
            ),
            GoRoute(
              path: 'tracking',
              name: 'patient-tracking',
              builder: (context, state) {
                final request = state.extra as CareRequest?;
                return CareRequestTrackingPage(request: request);
              },
            ),
            GoRoute(
              path: 'request/:id',
              name: 'patient-request-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ConsultationDetailPage(requestId: id);
              },
            ),
            GoRoute(
              path: 'consultation/:id/rating',
              name: 'patient-consultation-rating',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ConsultationRatingPage(requestId: id);
              },
            ),
          ],
        ),
        // Professional routes with ShellRoute to provide ProfessionalBloc
        ShellRoute(
          navigatorKey: _professionalShellKey,
          builder: (context, state, child) {
            return BlocProvider(
              create: (context) => getIt<ProfessionalBloc>()
                ..add(const ProfessionalLoadRequested()),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/professional',
              name: 'professional-home',
              builder: (context, state) => const ProfessionalHomePage(),
            ),
            GoRoute(
              path: '/professional/navigation/:requestId',
              name: 'professional-navigation',
              builder: (context, state) {
                final requestId = state.pathParameters['requestId']!;
                final request = state.extra as CareRequest?;
                return NavigationPage(requestId: requestId, request: request);
              },
            ),
            GoRoute(
              path: '/professional/consultation/:requestId',
              name: 'professional-consultation',
              builder: (context, state) {
                final requestId = state.pathParameters['requestId']!;
                return ConsultationPage(requestId: requestId);
              },
            ),
            GoRoute(
              path: '/professional/rating/:requestId',
              name: 'professional-rating',
              builder: (context, state) {
                final requestId = state.pathParameters['requestId']!;
                return RatingPage(requestId: requestId);
              },
            ),
            GoRoute(
              path: '/professional/request/:id',
              name: 'professional-request-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ProfessionalConsultationDetailPage(requestId: id);
              },
            ),
          ],
        ),
        // Pharmacist routes with ShellRoute to provide PharmacistBloc
        ShellRoute(
          navigatorKey: _pharmacistShellKey,
          builder: (context, state, child) {
            return BlocProvider(
              create: (context) => getIt<PharmacistBloc>()
                ..add(const PharmacistLoadRequested()),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/pharmacist',
              name: 'pharmacist-home',
              builder: (context, state) => const PharmacistHomePage(),
            ),
            GoRoute(
              path: '/pharmacist/request/:id',
              name: 'pharmacist-request-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PharmacistRequestDetailPage(requestId: id);
              },
            ),
            GoRoute(
              path: '/pharmacist/suggestion/:id',
              name: 'pharmacist-suggestion-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PharmacistSuggestionDetailPage(requestId: id);
              },
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page non trouvée: ${state.uri}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
