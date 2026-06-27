import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/professional_card.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../care_request/presentation/bloc/care_request_bloc.dart';
import '../../../care_request/presentation/bloc/care_request_event.dart';
import '../../../care_request/presentation/bloc/care_request_state.dart';
import '../../../care_request/domain/entities/care_request.dart';
import '../../../professional/domain/entities/medical_professional.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _HomeTab(),
            _RequestsTab(),
            _HistoryTab(),
            _ProfileTab(),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

// ==================== HOME TAB ====================
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientBloc>()..add(const LoadAvailableProfessionals()),
      child: const _HomeTabContent(),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showLogo: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Map Preview
            _buildHeroSection(context),
            const SizedBox(height: 24),
            // Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trouver un médecin\nou infirmier à proximité',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trouvez le professionnel de santé le plus proche de vous',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  // Nearby Professionals
                  _buildNearbyProfessionals(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFBAE6FD),
            Color(0xFFE0F2FE),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Map placeholder gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          // Markers
          Positioned(
            top: 60,
            left: 80,
            child: _buildMapMarker(AppTheme.doctorColor, 'Dr'),
          ),
          Positioned(
            top: 90,
            right: 100,
            child: _buildMapMarker(AppTheme.nurseColor, 'Inf'),
          ),
          Positioned(
            bottom: 70,
            left: 150,
            child: _buildMapMarker(AppTheme.doctorColor, 'Dr'),
          ),
          // Current location
          Positioned(
            bottom: 50,
            right: 80,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Expand button
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.fullscreen,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/patient/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppTheme.textHint),
            const SizedBox(width: 12),
            Text(
              'Rechercher un médecin ou infirmier',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.local_hospital,
                label: 'Médecin',
                color: AppTheme.doctorColor,
                onTap: () => context.push('/patient/request-doctor'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.healing,
                label: 'Infirmier',
                color: AppTheme.nurseColor,
                onTap: () => context.push('/patient/request-nurse'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _QuickActionButton(
          icon: Icons.local_pharmacy,
          label: 'Rechercher un pharmacien',
          color: AppTheme.accentColor,
          onTap: () {
            context.push('/patient/search-pharmacist');
          },
        ),
      ],
    );
  }

  Widget _buildNearbyProfessionals() {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Professionnels disponibles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/patient/search'),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.status == PatientStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (state.professionals.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    'Aucun professionnel disponible pour le moment',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              )
            else
              ...state.professionals.take(3).map((pro) {
                final profLabel = pro.profession == Profession.doctor ? 'Médecin' : 'Infirmier(ère)';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProfessionalCard(
                    name: pro.userFullName ?? profLabel,
                    profession: profLabel,
                    specialty: pro.specialties?.join(', '),
                    distance: null,
                    rating: null,
                    isAvailable: pro.isAvailable,
                    onTap: () => context.push('/patient/search'),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== REQUESTS TAB ====================
class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CareRequestBloc>()
        ..add(const CareRequestListRequested())
        ..add(const CareRequestActiveChecked()),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Mes demandes'),
        body: BlocBuilder<CareRequestBloc, CareRequestState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active request card
                  _buildActiveRequestCard(context, state),
                  const SizedBox(height: 24),
                  const Text(
                    'Demandes récentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.status == CareRequestStateStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : state.requests.isEmpty
                            ? Center(
                                child: Text(
                                  'Aucune demande pour le moment',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  context.read<CareRequestBloc>().add(
                                        const CareRequestRefreshRequested(),
                                      );
                                },
                                child: ListView(
                                  children: state.requests.map((request) {
                                    return GestureDetector(
                                      onTap: () {
                                        context.push('/patient/request/${request.id}');
                                      },
                                      child: _buildRequestHistoryItem(
                                        request.professionalName ?? 'Non assigné',
                                        _getRequestTypeLabel(request.professionType),
                                        _formatRequestDate(request.requestedAt),
                                        _getStatusLabel(request.status.name),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getRequestTypeLabel(ProfessionType type) {
    switch (type) {
      case ProfessionType.doctor:
        return 'Médecin';
      case ProfessionType.nurse:
        return 'Infirmier(e)';
    }
  }

  String _formatRequestDate(DateTime? date) {
    if (date == null) return 'Date inconnue';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Il y a 1 jour';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    }
  }

  Widget _buildActiveRequestCard(BuildContext context, CareRequestState state) {
    final hasActiveRequest = state.hasActiveRequest;
    final activeRequest = state.activeRequest;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: hasActiveRequest ? AppTheme.authGradient : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasActiveRequest ? Icons.circle : Icons.circle_outlined,
                      color: Colors.white,
                      size: 8,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasActiveRequest
                          ? 'Demande active'
                          : 'Aucune demande active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveRequest
                ? 'Demande en cours'
                : 'Besoin d\'un soin ?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasActiveRequest && activeRequest != null
                ? '${_getRequestTypeLabel(activeRequest.professionType)} - ${_getStatusLabel(activeRequest.status.name)}'
                : 'Demandez un médecin ou infirmier à domicile',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: hasActiveRequest
                      ? () => context.push('/patient/request/${activeRequest!.id}')
                      : () => context.push('/patient/request-doctor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(hasActiveRequest ? 'Voir la demande' : 'Nouvelle demande'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'assigned':
        return 'Assignée';
      case 'accepted':
        return 'Acceptée';
      case 'onRoute':
      case 'on_route':
        return 'En route';
      case 'inProgress':
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  Widget _buildRequestHistoryItem(
    String name,
    String type,
    String date,
    String status,
  ) {
    // Convert enum name (e.g., onRoute) to API format (on_route) for color lookup
    final statusKey = status.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)!.toLowerCase()}',
    ).toLowerCase();
    final statusColor = AppTheme.statusColors[statusKey] ?? 
                        AppTheme.statusColors[status] ?? 
                        AppTheme.textSecondary;
    final statusLabel = _getStatusLabel(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$type • $date',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HISTORY TAB ====================
class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CareRequestBloc>()
        ..add(const CareRequestListRequested()),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Historique'),
        body: BlocBuilder<CareRequestBloc, CareRequestState>(
          builder: (context, state) {
            if (state.status == CareRequestStateStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final completedRequests = state.requests
                .where((r) => r.status == CareRequestStatus.completed)
                .toList()
                  ..sort((a, b) => b.requestedAt?.compareTo(a.requestedAt ?? DateTime.now()) ?? 0);

            if (completedRequests.isEmpty) {
              return Center(
                child: Text(
                  'Aucun historique pour le moment',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CareRequestBloc>().add(
                      const CareRequestRefreshRequested(),
                    );
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: _buildHistorySections(completedRequests),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildHistorySections(List<CareRequest> requests) {
    final now = DateTime.now();
    final thisWeek = <CareRequest>[];
    final thisMonth = <CareRequest>[];
    final older = <CareRequest>[];

    for (final request in requests) {
      if (request.requestedAt == null) continue;
      final daysDiff = now.difference(request.requestedAt!).inDays;
      if (daysDiff <= 7) {
        thisWeek.add(request);
      } else if (daysDiff <= 30) {
        thisMonth.add(request);
      } else {
        older.add(request);
      }
    }

    final sections = <Widget>[];

    if (thisWeek.isNotEmpty) {
      sections.add(_buildHistorySection('Cette semaine', thisWeek));
    }
    if (thisMonth.isNotEmpty) {
      sections.add(_buildHistorySection('Ce mois', thisMonth));
    }
    if (older.isNotEmpty) {
      sections.add(_buildHistorySection('Plus ancien', older));
    }

    return sections;
  }

  Widget _buildHistorySection(String title, List<CareRequest> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        ...requests.map((request) => _buildHistoryCard(request)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHistoryCard(CareRequest request) {
    final professionalName = request.professionalName ?? 'Non assigné';
    final requestType = _getRequestTypeLabel(request.professionType);
    final date = request.requestedAt != null
        ? '${request.requestedAt!.day}/${request.requestedAt!.month}/${request.requestedAt!.year}'
        : 'Date inconnue';

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          context.push('/patient/request/${request.id}');
        },
        child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.authGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                professionalName.isNotEmpty ? professionalName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professionalName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$requestType • $date',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  String _getRequestTypeLabel(ProfessionType type) {
    switch (type) {
      case ProfessionType.doctor:
        return 'Médecin';
      case ProfessionType.nurse:
        return 'Infirmier(e)';
    }
  }
}

// ==================== PROFILE TAB ====================
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Profile Header
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          state.user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.user?.fullName ?? 'Utilisateur',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Patient',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            // Menu items
            _buildProfileSection('Mon compte', [
              _ProfileMenuItem(
                icon: Icons.person_outline,
                label: 'Informations personnelles',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.location_on_outlined,
                label: 'Adresses enregistrées',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.medical_information_outlined,
                label: 'Dossier médical',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildProfileSection('Paramètres', [
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.security_outlined,
                label: 'Sécurité',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.language_outlined,
                label: 'Langue',
                trailing: 'Français',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildProfileSection('Support', [
              _ProfileMenuItem(
                icon: Icons.help_outline,
                label: 'Aide & FAQ',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Politique de confidentialité',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.description_outlined,
                label: 'Conditions d\'utilisation',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),
            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                label: const Text('Déconnexion'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<_ProfileMenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: AppTheme.primaryColor, size: 20),
                    ),
                    title: Text(
                      item.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    trailing: item.trailing != null
                        ? Text(
                            item.trailing!,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 70,
                      color: Colors.grey[200],
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });
}
