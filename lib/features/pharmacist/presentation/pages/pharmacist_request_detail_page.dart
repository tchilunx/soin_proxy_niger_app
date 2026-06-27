import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/prescription_request.dart';
import '../bloc/pharmacist_bloc.dart';
import '../bloc/pharmacist_event.dart';
import '../bloc/pharmacist_state.dart';

class PharmacistRequestDetailPage extends StatelessWidget {
  final String requestId;

  const PharmacistRequestDetailPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PharmacistBloc, PharmacistState>(
      builder: (context, state) {
        PrescriptionRequest? request;
        final allRequests = [...state.pendingRequests, ...state.myRequests];
        try {
          request = allRequests.firstWhere(
            (r) => r.id?.toString() == requestId,
          );
        } catch (_) {
          request = null;
        }

        if (state.status == PharmacistStateStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (request == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text('Demande #$requestId'),
              foregroundColor: AppTheme.textPrimary,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Demande introuvable',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text('Demande #${request.id}'),
            foregroundColor: AppTheme.textPrimary,
            actions: [
              if (request.isUrgent)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(request),
                const SizedBox(height: 16),
                _buildPatientCard(request),
                const SizedBox(height: 16),
                _buildPrescriptionCard(request),
                const SizedBox(height: 24),
                _buildActionButton(context, request),
                const SizedBox(height: 16),
                if (request.status == PrescriptionRequestStatus.pending)
                  _buildRejectButton(context, request),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(PrescriptionRequest request) {
    final steps = [
      (PrescriptionRequestStatus.pending, 'Reçue', Icons.inbox),
      (PrescriptionRequestStatus.accepted, 'Acceptée', Icons.check_circle_outline),
      (PrescriptionRequestStatus.preparing, 'En préparation', Icons.science),
      (PrescriptionRequestStatus.ready, 'Prête', Icons.done_all),
      (PrescriptionRequestStatus.onRoute, 'En livraison', Icons.local_shipping),
      (PrescriptionRequestStatus.delivered, 'Livrée', Icons.verified),
    ];

    final currentIdx = steps.indexWhere((s) => s.$1 == request.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Statut de la demande',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isDone = idx <= currentIdx;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppTheme.accentColor
                            : const Color(0xFFE2E8F0),
                      ),
                      child: Icon(
                        step.$3,
                        size: 16,
                        color: isDone ? Colors.white : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.$2,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDone ? AppTheme.accentColor : Colors.grey,
                        fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(PrescriptionRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Patient',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    request.patientName?.isNotEmpty == true
                        ? request.patientName![0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 22,
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
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            request.patientPhone!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (request.requestedAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(request.requestedAt!),
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
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                  Icons.medication,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Prescription médicale',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              request.prescriptionText.isNotEmpty
                  ? request.prescriptionText
                  : 'Aucune prescription spécifiée',
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Notes',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              request.notes!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, PrescriptionRequest request) {
    String label;
    Color color;
    VoidCallback? onPressed;

    switch (request.status) {
      case PrescriptionRequestStatus.pending:
        label = 'Accepter la demande';
        color = AppTheme.successColor;
        onPressed = () {
          if (request.id != null) {
            context.read<PharmacistBloc>().add(
                  PrescriptionRequestAccepted(request.id!),
                );
            context.pop();
          }
        };
        break;
      case PrescriptionRequestStatus.accepted:
        label = 'Commencer la préparation';
        color = AppTheme.accentColor;
        onPressed = () {
          if (request.id != null) {
            context.read<PharmacistBloc>().add(
                  PrescriptionRequestMarkPreparing(request.id!),
                );
          }
        };
        break;
      case PrescriptionRequestStatus.preparing:
        label = 'Marquer comme prête';
        color = AppTheme.primaryColor;
        onPressed = () {
          if (request.id != null) {
            context.read<PharmacistBloc>().add(
                  PrescriptionRequestMarkReady(request.id!),
                );
          }
        };
        break;
      case PrescriptionRequestStatus.ready:
        label = 'Partir en livraison';
        color = AppTheme.infoColor;
        onPressed = () {
          if (request.id != null) {
            context.read<PharmacistBloc>().add(
                  PrescriptionRequestMarkOnRoute(request.id!),
                );
          }
        };
        break;
      case PrescriptionRequestStatus.onRoute:
        label = 'Confirmer la livraison';
        color = AppTheme.successColor;
        onPressed = () {
          if (request.id != null) {
            context.read<PharmacistBloc>().add(
                  PrescriptionRequestMarkDelivered(request.id!),
                );
            context.pop();
          }
        };
        break;
      case PrescriptionRequestStatus.delivered:
        label = 'Demande livrée';
        color = Colors.grey;
        onPressed = null;
        break;
      case PrescriptionRequestStatus.cancelled:
        label = 'Demande annulée';
        color = Colors.grey;
        onPressed = null;
        break;
      default:
        label = 'Action';
        color = AppTheme.primaryColor;
        onPressed = null;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRejectButton(BuildContext context, PrescriptionRequest request) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          if (request.id != null) {
            context.read<PharmacistBloc>().add(
                  PrescriptionRequestRejected(request.id!),
                );
            context.pop();
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          side: const BorderSide(color: AppTheme.errorColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Refuser la demande',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return '${date.day}/${date.month}/${date.year}';
  }
}
