import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../injection/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../care_request/domain/entities/care_request.dart';
import '../../../care_request/presentation/bloc/care_request_bloc.dart';
import '../../../care_request/presentation/bloc/care_request_event.dart';
import '../../../care_request/presentation/bloc/care_request_state.dart';
import '../../domain/entities/prescription_request.dart';
import '../bloc/pharmacist_bloc.dart';
import '../bloc/pharmacist_event.dart';
import '../bloc/pharmacist_state.dart';

class PharmacistHomePage extends StatefulWidget {
  const PharmacistHomePage({super.key});

  @override
  State<PharmacistHomePage> createState() => _PharmacistHomePageState();
}

class _PharmacistHomePageState extends State<PharmacistHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      },
      child: BlocBuilder<PharmacistBloc, PharmacistState>(
        builder: (context, pharmacistState) {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: [
                _HomeTab(state: pharmacistState),
                _RequestsTab(state: pharmacistState),
                _HistoryTab(state: pharmacistState),
                const _ProfileTab(),
              ],
            ),
            bottomNavigationBar: CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              isDoctor: false, // Pharmacist uses different icons
            ),
          );
        },
      ),
    );
  }
}

// ==================== HOME TAB ====================
class _HomeTab extends StatelessWidget {
  final PharmacistState state;

  const _HomeTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasActiveRequest = state.inProgressRequests.isNotEmpty;

    return Scaffold(
      appBar: const CustomAppBar(showLogo: true),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PharmacistBloc>().add(const PharmacistLoadRequested());
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
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            authState.user?.fullName?.substring(0, 1).toUpperCase() ?? 'P',
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
                              'Bonjour ${authState.user?.fullName?.split(' ').first ?? "Pharmacien"}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.profile?.pharmacyName ?? 'Pharmacie',
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
              // Suggestions from care requests
              _buildSuggestionsSection(context),
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
    final isUpdating = state.status == PharmacistStateStatus.updating;

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
                context.read<PharmacistBloc>().add(PharmacistStatusToggled(value));
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

  Widget _buildActiveRequestCard(BuildContext context) {
    final activeRequests = state.inProgressRequests;
    if (activeRequests.isEmpty) return const SizedBox.shrink();

    final activeRequest = activeRequests.first;
    final patientName = activeRequest.patientName ?? 'Patient #${activeRequest.patientId}';

    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (activeRequest.status) {
      case PrescriptionRequestStatus.accepted:
        statusText = 'Acceptée - En préparation';
        statusColor = AppTheme.infoColor;
        statusIcon = Icons.check_circle;
        break;
      case PrescriptionRequestStatus.preparing:
        statusText = 'En préparation';
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.medication;
        break;
      case PrescriptionRequestStatus.ready:
        statusText = 'Prête pour livraison';
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle_outline;
        break;
      case PrescriptionRequestStatus.onRoute:
        statusText = 'En route vers le patient';
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.directions_car;
        break;
      default:
        statusText = 'En cours';
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.pending;
    }

    return GestureDetector(
      onTap: () {
        // Navigate to request details
        context.push('/pharmacist/request/${activeRequest.id}');
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
                      Icon(statusIcon, color: Colors.white, size: 16),
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
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Demande de prescription',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              patientName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _handleRequestAction(context, activeRequest);
              },
              icon: Icon(
                _getActionIcon(activeRequest.status),
                size: 18,
              ),
              label: Text(_getActionLabel(activeRequest.status)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: statusColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRequestAction(BuildContext context, PrescriptionRequest request) {
    final bloc = context.read<PharmacistBloc>();
    
    switch (request.status) {
      case PrescriptionRequestStatus.accepted:
        bloc.add(PrescriptionRequestMarkPreparing(request.id!));
        break;
      case PrescriptionRequestStatus.preparing:
        bloc.add(PrescriptionRequestMarkReady(request.id!));
        break;
      case PrescriptionRequestStatus.ready:
        bloc.add(PrescriptionRequestMarkOnRoute(request.id!));
        break;
      case PrescriptionRequestStatus.onRoute:
        bloc.add(PrescriptionRequestMarkDelivered(request.id!));
        break;
      default:
        break;
    }
  }

  IconData _getActionIcon(PrescriptionRequestStatus status) {
    switch (status) {
      case PrescriptionRequestStatus.accepted:
        return Icons.medication;
      case PrescriptionRequestStatus.preparing:
        return Icons.check_circle;
      case PrescriptionRequestStatus.ready:
        return Icons.directions_car;
      case PrescriptionRequestStatus.onRoute:
        return Icons.local_shipping;
      default:
        return Icons.arrow_forward;
    }
  }

  String _getActionLabel(PrescriptionRequestStatus status) {
    switch (status) {
      case PrescriptionRequestStatus.accepted:
        return 'Commencer la préparation';
      case PrescriptionRequestStatus.preparing:
        return 'Marquer comme prête';
      case PrescriptionRequestStatus.ready:
        return 'Commencer la livraison';
      case PrescriptionRequestStatus.onRoute:
        return 'Marquer comme livrée';
      default:
        return 'Voir les détails';
    }
  }

  Widget _buildStatsSection() {
    final todayCount = state.myRequests
        .where((r) =>
            r.requestedAt != null &&
            r.requestedAt!.day == DateTime.now().day &&
            r.status == PrescriptionRequestStatus.delivered)
        .length;

    final monthCount = state.completedRequests.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_pharmacy,
            value: todayCount.toString(),
            label: 'Aujourd\'hui',
            color: AppTheme.accentColor,
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
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CareRequestBloc>()
        ..add(const CareRequestListRequested()),
      child: BlocBuilder<CareRequestBloc, CareRequestState>(
        builder: (context, careRequestState) {
          final suggestions = careRequestState.requests
              .where((r) =>
                  r.status == CareRequestStatus.completed &&
                  r.prescribedMedications != null &&
                  r.prescribedMedications!.isNotEmpty)
              .toList();

          if (suggestions.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Suggestions de consultations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (suggestions.length > 3)
                    TextButton(
                      onPressed: () {
                        // Navigate to full suggestions list
                        context.push('/pharmacist/suggestions');
                      },
                      child: const Text('Voir tout'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...suggestions.take(3).map((suggestion) => _buildSuggestionCard(context, suggestion)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, CareRequest suggestion) {
    final patientName = suggestion.patientName ?? 'Patient #${suggestion.patientId}';
    final hasMedications = suggestion.prescribedMedications != null &&
        suggestion.prescribedMedications!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (suggestion.id != null) {
          context.push('/pharmacist/suggestion/${suggestion.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (suggestion.professionalName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Par ${suggestion.professionalName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Consultation terminée',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (hasMedications) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medication,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion.prescribedMedications!.length > 100
                            ? '${suggestion.prescribedMedications!.substring(0, 100)}...'
                            : suggestion.prescribedMedications!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNewRequestsSection(BuildContext context) {
    if (state.pendingRequests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune nouvelle demande',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Les nouvelles demandes apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

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
            if (state.pendingCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.pendingCount}',
                  style: TextStyle(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.pendingRequests.take(3).map((request) => _buildRequestCard(context, request)),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, PrescriptionRequest request) {
    final patientName = request.patientName ?? 'Patient #${request.patientId}';
    final isUrgent = request.isUrgent;

    return GestureDetector(
      onTap: () {
        if (request.id != null) {
          context.push('/pharmacist/request/${request.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? AppTheme.errorColor.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
            width: isUrgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.priority_high, size: 14, color: AppTheme.errorColor),
                      const SizedBox(width: 4),
                      Text(
                        'Urgent',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (request.prescriptionText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              request.prescriptionText.length > 100
                  ? '${request.prescriptionText.substring(0, 100)}...'
                  : request.prescriptionText,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<PharmacistBloc>().add(PrescriptionRequestRejected(request.id!));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: BorderSide(color: AppTheme.errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Refuser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<PharmacistBloc>().add(PrescriptionRequestAccepted(request.id!));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Accepter'),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

// ==================== REQUESTS TAB ====================
class _RequestsTab extends StatelessWidget {
  final PharmacistState state;

  const _RequestsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes demandes'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PharmacistBloc>().add(const PharmacistRequestsLoadRequested());
        },
        child: state.myRequests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune demande',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.myRequests.length,
                itemBuilder: (context, index) {
                  final request = state.myRequests[index];
                  return _buildRequestListItem(context, request);
                },
              ),
      ),
    );
  }

  Widget _buildRequestListItem(BuildContext context, PrescriptionRequest request) {
    final patientName = request.patientName ?? 'Patient #${request.patientId}';
    final statusColor = _getStatusColor(request.status);
    final statusLabel = _getStatusLabel(request.status);

    return GestureDetector(
      onTap: () {
        if (request.id != null) {
          context.push('/pharmacist/request/${request.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          if (request.prescriptionText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              request.prescriptionText.length > 80
                  ? '${request.prescriptionText.substring(0, 80)}...'
                  : request.prescriptionText,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (request.requestedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Demandé le ${_formatDate(request.requestedAt!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Color _getStatusColor(PrescriptionRequestStatus status) {
    switch (status) {
      case PrescriptionRequestStatus.pending:
        return AppTheme.textHint;
      case PrescriptionRequestStatus.accepted:
        return AppTheme.infoColor;
      case PrescriptionRequestStatus.preparing:
        return AppTheme.warningColor;
      case PrescriptionRequestStatus.ready:
        return AppTheme.successColor;
      case PrescriptionRequestStatus.onRoute:
        return AppTheme.primaryColor;
      case PrescriptionRequestStatus.delivered:
        return AppTheme.successColor;
      default:
        return AppTheme.textHint;
    }
  }

  String _getStatusLabel(PrescriptionRequestStatus status) {
    switch (status) {
      case PrescriptionRequestStatus.pending:
        return 'En attente';
      case PrescriptionRequestStatus.accepted:
        return 'Acceptée';
      case PrescriptionRequestStatus.preparing:
        return 'En préparation';
      case PrescriptionRequestStatus.ready:
        return 'Prête';
      case PrescriptionRequestStatus.onRoute:
        return 'En route';
      case PrescriptionRequestStatus.delivered:
        return 'Livrée';
      default:
        return 'Annulée';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ==================== HISTORY TAB ====================
class _HistoryTab extends StatelessWidget {
  final PharmacistState state;

  const _HistoryTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final completedRequests = state.completedRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PharmacistBloc>().add(const PharmacistRequestsLoadRequested());
        },
        child: completedRequests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun historique',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: completedRequests.length,
                itemBuilder: (context, index) {
                  final request = completedRequests[index];
                  return _buildHistoryItem(context, request);
                },
              ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, PrescriptionRequest request) {
    final patientName = request.patientName ?? 'Patient #${request.patientId}';

    return GestureDetector(
      onTap: () {
        if (request.id != null) {
          context.push('/pharmacist/request/${request.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (request.deliveredAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Livré le ${_formatDate(request.deliveredAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ==================== PROFILE TAB ====================
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<PharmacistBloc, PharmacistState>(
            builder: (context, pharmacistState) {
              final profile = pharmacistState.profile;
              final user = authState.user;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                user?.fullName?.substring(0, 1).toUpperCase() ?? 'P',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.fullName ?? 'Pharmacien',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.pharmacyName ?? 'Pharmacie',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Profile info
                    _buildInfoCard('Email', user?.email ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildInfoCard('Téléphone', user?.phone ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildInfoCard('Nom de la pharmacie', profile?.pharmacyName ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildInfoCard('Numéro de licence', profile?.licenseNumber ?? 'N/A'),
                    if (profile?.address != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoCard('Adresse', profile!.address!),
                    ],
                    const SizedBox(height: 24),
                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Déconnexion'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

