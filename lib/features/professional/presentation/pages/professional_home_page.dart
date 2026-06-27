import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/request_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../care_request/domain/entities/care_request.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/medical_professional.dart';

class ProfessionalHomePage extends StatefulWidget {
  const ProfessionalHomePage({super.key});

  @override
  State<ProfessionalHomePage> createState() => _ProfessionalHomePageState();
}

class _ProfessionalHomePageState extends State<ProfessionalHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ProfessionalBloc is provided by ShellRoute in app_router.dart
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      },
      child: BlocBuilder<ProfessionalBloc, ProfessionalState>(
        builder: (context, proState) {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: [
                _HomeTab(state: proState),
                _RequestsTab(state: proState),
                _HistoryTab(state: proState),
                const _ProfileTab(),
              ],
            ),
            bottomNavigationBar: CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              isDoctor: true,
            ),
          );
        },
      ),
    );
  }
}

// ==================== HOME TAB ====================
class _HomeTab extends StatelessWidget {
  final ProfessionalState state;

  const _HomeTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasActiveRequest = state.inProgressRequests.isNotEmpty;

    return Scaffold(
      appBar: const CustomAppBar(showLogo: true),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfessionalBloc>().add(const ProfessionalLoadRequested());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.doctorGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            authState.user?.fullName?.substring(0, 1).toUpperCase() ?? 'D',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour ${authState.user?.fullName?.split(' ').first ?? "Docteur"}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.profile?.profession == Profession.nurse
                                  ? 'Infirmier(e)'
                                  : state.profile?.specialties?.isNotEmpty == true
                                      ? state.profile!.specialties!.first
                                      : 'Médecin Généraliste',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Active request card (if any)
              if (hasActiveRequest) ...[
                _buildActiveRequestCard(context),
                const SizedBox(height: 24),
              ],
              // Availability toggle (only show if no active request)
              if (!hasActiveRequest) ...[
                _buildAvailabilityCard(context),
                const SizedBox(height: 24),
              ],
              // Stats cards
              _buildStatsSection(),
              const SizedBox(height: 24),
              // New requests
              _buildNewRequestsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard(BuildContext context) {
    final isAvailable = state.isAvailable;
    final isUpdating = state.status == ProfessionalStateStatus.updating;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isAvailable
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              )
            : const LinearGradient(
                colors: [Color(0xFF64748B), Color(0xFF475569)],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isAvailable ? AppTheme.successColor : AppTheme.textHint)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? 'Vous êtes disponible' : 'Vous êtes hors ligne',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAvailable
                      ? 'Vous pouvez recevoir des demandes'
                      : 'Activez pour recevoir des demandes',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isUpdating)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else
            Switch(
              value: isAvailable,
              onChanged: (value) {
                context.read<ProfessionalBloc>().add(ProfessionalStatusToggled(value));
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }

  // Active request card - shows when there's an accepted request
  Widget _buildActiveRequestCard(BuildContext context) {
    final activeRequests = state.inProgressRequests;
    if (activeRequests.isEmpty) return const SizedBox.shrink();

    final activeRequest = activeRequests.first;
    final patientName = activeRequest.patientName ?? 'Patient #${activeRequest.patientId}';

    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (activeRequest.status) {
      case CareRequestStatus.assigned:
        statusText = 'Assignée - À accepter';
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.assignment;
        break;
      case CareRequestStatus.accepted:
        statusText = 'Acceptée - En attente';
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case CareRequestStatus.onRoute:
        statusText = 'En route vers le patient';
        statusColor = AppTheme.infoColor;
        statusIcon = Icons.directions_car;
        break;
      case CareRequestStatus.inProgress:
        statusText = 'Consultation en cours';
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.medical_services;
        break;
      default:
        statusText = 'En cours';
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.pending;
    }

    return GestureDetector(
      onTap: () {
        if (activeRequest.status == CareRequestStatus.inProgress) {
          context.push('/professional/consultation/${activeRequest.id}');
        } else if (activeRequest.status == CareRequestStatus.assigned) {
          // For assigned requests, allow accepting them
          _showAcceptDialog(context, activeRequest);
        } else {
          context.push('/professional/navigation/${activeRequest.id}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [statusColor.withValues(alpha: 0.9), statusColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.3),
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
                      Icon(statusIcon, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (activeRequest.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                        patientName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeRequest.address ?? 'Adresse non spécifiée',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (activeRequest.status == CareRequestStatus.inProgress) {
                        context.push('/professional/consultation/${activeRequest.id}');
                      } else if (activeRequest.status == CareRequestStatus.assigned) {
                        _showAcceptDialog(context, activeRequest);
                      } else {
                        context.push('/professional/navigation/${activeRequest.id}');
                      }
                    },
                    icon: Icon(
                      activeRequest.status == CareRequestStatus.inProgress
                          ? Icons.medical_services
                          : activeRequest.status == CareRequestStatus.assigned
                              ? Icons.check_circle
                              : Icons.navigation,
                      size: 18,
                    ),
                    label: Text(
                      activeRequest.status == CareRequestStatus.inProgress
                          ? 'Continuer la consultation'
                          : activeRequest.status == CareRequestStatus.assigned
                              ? 'Accepter la demande'
                              : 'Naviguer vers le patient',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: statusColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final todayCount = state.myRequests
        .where((r) =>
            r.requestedAt != null &&
            r.requestedAt!.day == DateTime.now().day &&
            r.status == CareRequestStatus.completed)
        .length;

    final monthCount = state.completedRequests.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.assignment_turned_in,
            value: todayCount.toString(),
            label: 'Aujourd\'hui',
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_actions,
            value: state.pendingCount.toString(),
            label: 'En attente',
            color: AppTheme.warningColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            value: monthCount.toString(),
            label: 'Ce mois',
            color: AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNewRequestsSection(BuildContext context) {
    final pendingRequests = state.pendingRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nouvelles demandes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (pendingRequests.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pendingRequests.length} nouvelle${pendingRequests.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.status == ProfessionalStateStatus.loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (pendingRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune demande en attente',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...pendingRequests.take(5).map((request) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RequestCard(
                  patientName: request.patientName ?? 'Patient #${request.patientId}',
                  requestType: request.notes ?? 'Consultation',
                  address: request.address ?? 'Adresse non spécifiée',
                  distance: _calculateDistance(request),
                  time: _formatTime(request.requestedAt),
                  status: 'pending',
                  isUrgent: request.isUrgent,
                  onAccept: () => _showAcceptDialog(context, request),
                  onReject: () => _showRejectDialog(context, request),
                ),
              )),
      ],
    );
  }

  String _calculateDistance(CareRequest request) {
    if (request.latitude == null || request.longitude == null) return 'N/A';
    final profLat = state.profile?.currentLatitude;
    final profLng = state.profile?.currentLongitude;
    if (profLat == null || profLng == null) return '~? km';
    final meters = Geolocator.distanceBetween(
      profLat, profLng,
      request.latitude!, request.longitude!,
    );
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays}j';
  }

  void _showAcceptDialog(BuildContext context, CareRequest request) {
    // Check if context is still valid before showing dialog
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Accepter la demande ?'),
        content: const Text(
          'Vous allez accepter cette demande et vous diriger vers le patient.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfessionalBloc>().add(
                    ProfessionalRequestAccepted(request.id!),
                  );
              context.push('/professional/navigation/${request.id}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, CareRequest request) {
    // Check if context is still valid before showing dialog
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Refuser la demande ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir refuser cette demande ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfessionalBloc>().add(
                    ProfessionalRequestRejected(request.id!),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }
}

// ==================== REQUESTS TAB ====================
class _RequestsTab extends StatelessWidget {
  final ProfessionalState state;

  const _RequestsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Demandes reçues'),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textHint,
                indicatorColor: AppTheme.primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(text: 'Nouvelles'),
                  Tab(text: 'En cours'),
                  Tab(text: 'Terminées'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRequestsList(context, state.pendingRequests, 'pending'),
                  _buildRequestsList(context, state.inProgressRequests, 'in_progress'),
                  _buildRequestsList(context, state.completedRequests, 'completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    List<CareRequest> requests,
    String type,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune demande',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfessionalBloc>().add(const ProfessionalRequestsLoadRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = requests[index];
          return RequestCard(
            patientName: request.patientName ?? 'Patient #${request.patientId}',
            requestType: request.notes ?? 'Consultation',
            address: request.address ?? 'Adresse non spécifiée',
            distance: '~2 km',
            status: _statusToString(request.status),
            isUrgent: request.isUrgent,
            onTap: () {
              if (request.id != null) {
                context.push('/professional/request/${request.id}');
              }
            },
            onAccept: type == 'pending'
                ? () {
                    context.read<ProfessionalBloc>().add(
                          ProfessionalRequestAccepted(request.id!),
                        );
                    context.push('/professional/navigation/${request.id}');
                  }
                : null,
            onReject: type == 'pending'
                ? () {
                    context.read<ProfessionalBloc>().add(
                          ProfessionalRequestRejected(request.id!),
                        );
                  }
                : null,
          );
        },
      ),
    );
  }

  String _statusToString(CareRequestStatus status) {
    switch (status) {
      case CareRequestStatus.pending:
        return 'pending';
      case CareRequestStatus.assigned:
        return 'assigned';
      case CareRequestStatus.accepted:
        return 'accepted';
      case CareRequestStatus.onRoute:
        return 'on_route';
      case CareRequestStatus.inProgress:
        return 'in_progress';
      case CareRequestStatus.completed:
        return 'completed';
      case CareRequestStatus.cancelled:
        return 'cancelled';
    }
  }
}

// ==================== HISTORY TAB ====================
class _HistoryTab extends StatelessWidget {
  final ProfessionalState state;

  const _HistoryTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final completedRequests = state.completedRequests;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Historique'),
      body: completedRequests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun historique',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: completedRequests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = completedRequests[index];
                return _buildHistoryCard(context, request);
              },
            ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, CareRequest request) {
    return GestureDetector(
      onTap: () {
        if (request.id != null) {
          context.push('/professional/request/${request.id}');
        }
      },
      child: Container(
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
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.patientName ?? 'Patient #${request.patientId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.notes ?? 'Consultation',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatDate(request.completedAt ?? request.requestedAt),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
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
                        gradient: AppTheme.doctorGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.doctorColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          state.user?.fullName?.substring(0, 1).toUpperCase() ?? 'D',
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
                      state.user?.fullName ?? 'Dr. Utilisateur',
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
                icon: Icons.badge_outlined,
                label: 'Documents professionnels',
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
                        color: AppTheme.doctorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: AppTheme.doctorColor, size: 20),
                    ),
                    title: Text(
                      item.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    trailing: Icon(
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
  final VoidCallback onTap;

  _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
