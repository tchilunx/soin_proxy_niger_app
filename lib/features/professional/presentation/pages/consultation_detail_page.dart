import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../../care_request/presentation/bloc/care_request_bloc.dart';
import '../../../care_request/presentation/bloc/care_request_event.dart';
import '../../../care_request/presentation/bloc/care_request_state.dart';
import '../../../care_request/domain/entities/care_request.dart';

class ProfessionalConsultationDetailPage extends StatelessWidget {
  final String requestId;

  const ProfessionalConsultationDetailPage({super.key, required this.requestId});

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
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
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
                  _buildStatusCard(request),
                  const SizedBox(height: 16),
                  _buildPatientCard(request),
                  const SizedBox(height: 16),
                  if (request.prescribedMedications != null &&
                      request.prescribedMedications!.isNotEmpty) ...[
                    _buildMedicationsCard(request),
                    const SizedBox(height: 16),
                  ],
                  if (request.suggestedPharmacistName != null ||
                      request.suggestedPharmacyName != null) ...[
                    _buildPharmacistCard(request),
                    const SizedBox(height: 16),
                  ],
                  _buildNotesCard(request),
                  if (request.rating != null) ...[
                    const SizedBox(height: 16),
                    _buildRatingCard(request),
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
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (request.status) {
      case CareRequestStatus.pending:
        statusColor = AppTheme.warningColor;
        statusText = 'En attente';
        statusIcon = Icons.pending;
        break;
      case CareRequestStatus.assigned:
        statusColor = AppTheme.infoColor;
        statusText = 'Assignée';
        statusIcon = Icons.assignment;
        break;
      case CareRequestStatus.accepted:
        statusColor = AppTheme.infoColor;
        statusText = 'Acceptée';
        statusIcon = Icons.check_circle_outline;
        break;
      case CareRequestStatus.onRoute:
        statusColor = AppTheme.primaryColor;
        statusText = 'En route';
        statusIcon = Icons.directions_car;
        break;
      case CareRequestStatus.inProgress:
        statusColor = AppTheme.primaryColor;
        statusText = 'En cours';
        statusIcon = Icons.medical_services;
        break;
      case CareRequestStatus.completed:
        statusColor = AppTheme.successColor;
        statusText = 'Terminée';
        statusIcon = Icons.check_circle;
        break;
      case CareRequestStatus.cancelled:
        statusColor = AppTheme.errorColor;
        statusText = 'Annulée';
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consultation #${request.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.isUrgent) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.priority_high,
                    size: 16,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Urgent',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Date',
                  request.requestedAt != null
                      ? _formatDate(request.requestedAt!)
                      : 'N/A',
                  Icons.calendar_today,
                ),
              ),
              if (request.completedAt != null)
                Expanded(
                  child: _buildInfoItem(
                    'Terminée le',
                    _formatDate(request.completedAt!),
                    Icons.check_circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(CareRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.patientName ?? 'Patient',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (request.patientPhone != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.patientPhone!,
                            style: TextStyle(
                              fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildMedicationsCard(CareRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppTheme.primaryColor,
                  size: 20,
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
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              request.prescribedMedications!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
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
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_pharmacy,
                  color: AppTheme.accentColor,
                  size: 20,
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
          if (request.suggestedPharmacyName != null) ...[
            Text(
              request.suggestedPharmacyName!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (request.suggestedPharmacistName != null) ...[
            Text(
              request.suggestedPharmacistName!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (request.suggestedPharmacistPhone != null)
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  request.suggestedPharmacistPhone!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(CareRequest request) {
    if (request.notes == null || request.notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
            request.notes!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(CareRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évaluation du patient',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < (request.rating ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${request.rating}/5',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (request.ratingComment != null &&
              request.ratingComment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request.ratingComment!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

