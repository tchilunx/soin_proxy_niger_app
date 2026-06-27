import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../../care_request/presentation/bloc/care_request_bloc.dart';
import '../../../care_request/presentation/bloc/care_request_event.dart';
import '../../../care_request/presentation/bloc/care_request_state.dart';
import '../../../care_request/domain/entities/care_request.dart';

class ConsultationDetailPage extends StatelessWidget {
  final String requestId;

  const ConsultationDetailPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CareRequestBloc>()
        ..add(const CareRequestListRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la consultation'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<CareRequestBloc, CareRequestState>(
          builder: (context, state) {
            if (state.status == CareRequestStateStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            CareRequest? request;
            try {
              request = state.requests.firstWhere(
                (r) => r.id.toString() == requestId,
              );
            } catch (_) {
              request = state.requests.isNotEmpty ? state.requests.first : null;
            }

            if (request == null || state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Consultation introuvable',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(request),
                  const SizedBox(height: 20),
                  // Professional Info
                  if (request.professionalName != null) ...[
                    _buildProfessionalCard(request),
                    const SizedBox(height: 20),
                  ],
                  // Consultation Date
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date de consultation',
                    value: request.completedAt != null
                        ? _formatDate(request.completedAt!)
                        : request.requestedAt != null
                            ? _formatDate(request.requestedAt!)
                            : 'Non définie',
                  ),
                  const SizedBox(height: 20),
                  // Prescribed Medications
                  if (request.prescribedMedications != null &&
                      request.prescribedMedications!.isNotEmpty) ...[
                    _buildMedicationsCard(request.prescribedMedications!),
                    const SizedBox(height: 20),
                  ],
                  // Suggested Pharmacist
                  if (request.suggestedPharmacistName != null) ...[
                    _buildPharmacistCard(request),
                    const SizedBox(height: 20),
                  ],
                  // Notes
                  if (request.notes != null && request.notes!.isNotEmpty) ...[
                    _buildNotesCard(request.notes!),
                    const SizedBox(height: 20),
                  ],
                  // Delivery Request Button (if completed, has medications, and not yet requested)
                  if (request.status == CareRequestStatus.completed &&
                      request.prescribedMedications != null &&
                      request.prescribedMedications!.isNotEmpty &&
                      !request.deliveryRequested &&
                      request.suggestedPharmacistId != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (request != null) {
                            _requestDelivery(context, request);
                          }
                        },
                        icon: const Icon(Icons.local_shipping, size: 20),
                        label: const Text('Se faire livrer les médicaments'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Delivery Requested Status (if already requested)
                  if (request.deliveryRequested) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_shipping,
                            color: AppTheme.accentColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Livraison demandée - En attente du pharmacien',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Rating Button (if completed and not rated)
                  if (request.status == CareRequestStatus.completed &&
                      request.rating == null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/patient/consultation/$requestId/rating');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Noter cette consultation'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(CareRequest request) {
    final statusColor = _getStatusColor(request.status);
    final statusLabel = _getStatusLabel(request.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withValues(alpha: 0.1), statusColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getStatusIcon(request.status), color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Demande #${request.id}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(CareRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.doctorGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                request.professionalName?.substring(0, 1).toUpperCase() ?? 'D',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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
                  request.professionalName ?? 'Professionnel',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRequestTypeLabel(request.professionType),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (request.professionalPhone != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        request.professionalPhone!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsCard(String medications) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Médicaments prescrits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              medications,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacistCard(CareRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
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
                  Icons.local_pharmacy,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pharmacien suggéré',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            request.suggestedPharmacistName ?? 'Pharmacien',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (request.suggestedPharmacistPhone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  request.suggestedPharmacistPhone!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            notes,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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

  Color _getStatusColor(CareRequestStatus status) {
    switch (status) {
      case CareRequestStatus.pending:
        return AppTheme.textHint;
      case CareRequestStatus.assigned:
        return AppTheme.infoColor;
      case CareRequestStatus.accepted:
        return AppTheme.primaryColor;
      case CareRequestStatus.onRoute:
        return AppTheme.warningColor;
      case CareRequestStatus.inProgress:
        return AppTheme.accentColor;
      case CareRequestStatus.completed:
        return AppTheme.successColor;
      default:
        return AppTheme.errorColor;
    }
  }

  String _getStatusLabel(CareRequestStatus status) {
    switch (status) {
      case CareRequestStatus.pending:
        return 'En attente';
      case CareRequestStatus.assigned:
        return 'Assignée';
      case CareRequestStatus.accepted:
        return 'Acceptée';
      case CareRequestStatus.onRoute:
        return 'En route';
      case CareRequestStatus.inProgress:
        return 'En cours';
      case CareRequestStatus.completed:
        return 'Terminée';
      default:
        return 'Annulée';
    }
  }

  IconData _getStatusIcon(CareRequestStatus status) {
    switch (status) {
      case CareRequestStatus.pending:
        return Icons.pending;
      case CareRequestStatus.assigned:
        return Icons.assignment;
      case CareRequestStatus.accepted:
        return Icons.check_circle_outline;
      case CareRequestStatus.onRoute:
        return Icons.directions_car;
      case CareRequestStatus.inProgress:
        return Icons.medical_services;
      case CareRequestStatus.completed:
        return Icons.check_circle;
      default:
        return Icons.cancel;
    }
  }

  String _getRequestTypeLabel(ProfessionType type) {
    return type == ProfessionType.doctor ? 'Médecin' : 'Infirmier(e)';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _requestDelivery(BuildContext context, CareRequest request) {
    if (request.id == null) return;

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Demander la livraison'),
        content: const Text(
          'Voulez-vous demander la livraison de vos médicaments par le pharmacien suggéré ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Update care request with delivery_requested = true
              context.read<CareRequestBloc>().add(
                    CareRequestDeliveryRequested(requestId: request.id!),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
