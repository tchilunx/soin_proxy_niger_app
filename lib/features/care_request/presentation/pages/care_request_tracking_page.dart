import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/care_request.dart';
import '../bloc/care_request_bloc.dart';
import '../bloc/care_request_event.dart';

class CareRequestTrackingPage extends StatefulWidget {
  final CareRequest? request;

  const CareRequestTrackingPage({
    super.key,
    this.request,
  });

  @override
  State<CareRequestTrackingPage> createState() => _CareRequestTrackingPageState();
}

class _CareRequestTrackingPageState extends State<CareRequestTrackingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late CareRequestBloc _careRequestBloc;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _careRequestBloc = getIt<CareRequestBloc>();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _careRequestBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final isDoctor = request?.professionType == ProfessionType.doctor;
    final color = isDoctor ? AppTheme.doctorColor : AppTheme.nurseColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.go('/patient'),
        ),
        title: const Text(
          'Suivi de la demande',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status card with animation
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Animated pulse indicator
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Container(
                            width: 80 + (20 * _pulseController.value),
                            height: 80 + (20 * _pulseController.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(
                                alpha: 0.3 - (0.2 * _pulseController.value),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withValues(alpha: 0.8),
                                      color,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  _getStatusIcon(request?.status),
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _getStatusTitle(request?.status),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusDescription(request?.status),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progress steps
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progression',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProgressStep(
                    title: 'Demande envoyée',
                    subtitle: 'Votre demande a été enregistrée',
                    isCompleted: true,
                    isActive: request?.status == CareRequestStatus.pending,
                    color: color,
                  ),
                  _buildProgressLine(
                    isCompleted: _isStatusAfter(request?.status, CareRequestStatus.pending),
                    color: color,
                  ),
                  _buildProgressStep(
                    title: 'Professionnel assigné',
                    subtitle: 'Un professionnel a accepté votre demande',
                    isCompleted: _isStatusAfter(request?.status, CareRequestStatus.pending),
                    isActive: request?.status == CareRequestStatus.assigned ||
                        request?.status == CareRequestStatus.accepted,
                    color: color,
                  ),
                  _buildProgressLine(
                    isCompleted: _isStatusAfter(request?.status, CareRequestStatus.accepted),
                    color: color,
                  ),
                  _buildProgressStep(
                    title: 'En route',
                    subtitle: 'Le professionnel se dirige vers vous',
                    isCompleted: _isStatusAfter(request?.status, CareRequestStatus.accepted),
                    isActive: request?.status == CareRequestStatus.onRoute,
                    color: color,
                  ),
                  _buildProgressLine(
                    isCompleted: _isStatusAfter(request?.status, CareRequestStatus.onRoute),
                    color: color,
                  ),
                  _buildProgressStep(
                    title: 'Soin en cours',
                    subtitle: 'Le professionnel est arrivé',
                    isCompleted: _isStatusAfter(request?.status, CareRequestStatus.onRoute),
                    isActive: request?.status == CareRequestStatus.inProgress,
                    color: color,
                  ),
                  _buildProgressLine(
                    isCompleted: request?.status == CareRequestStatus.completed,
                    color: color,
                  ),
                  _buildProgressStep(
                    title: 'Terminé',
                    subtitle: 'Le soin a été effectué',
                    isCompleted: request?.status == CareRequestStatus.completed,
                    isActive: false,
                    color: color,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Professional info (if assigned)
            if (request?.professionalName != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.8), color],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          request!.professionalName!.substring(0, 1).toUpperCase(),
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
                            request.professionalName!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDoctor ? 'Médecin' : 'Infirmier(e)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (request.professionalPhone != null)
                      IconButton(
                        onPressed: () {
                          // TODO: Call professional
                        },
                        icon: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Cancel button (only if pending or assigned)
            if (request?.status == CareRequestStatus.pending ||
                request?.status == CareRequestStatus.assigned)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showCancelDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Annuler la demande',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive ? color : const Color(0xFFE2E8F0),
            border: isActive
                ? Border.all(color: color.withValues(alpha: 0.3), width: 4)
                : null,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isCompleted || isActive
                      ? AppTheme.textPrimary
                      : AppTheme.textHint,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine({required bool isCompleted, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 4, bottom: 4),
      width: 2,
      height: 30,
      color: isCompleted ? color : const Color(0xFFE2E8F0),
    );
  }

  bool _isStatusAfter(CareRequestStatus? current, CareRequestStatus target) {
    if (current == null) return false;
    final order = [
      CareRequestStatus.pending,
      CareRequestStatus.assigned,
      CareRequestStatus.accepted,
      CareRequestStatus.onRoute,
      CareRequestStatus.inProgress,
      CareRequestStatus.completed,
    ];
    return order.indexOf(current) > order.indexOf(target);
  }

  IconData _getStatusIcon(CareRequestStatus? status) {
    switch (status) {
      case CareRequestStatus.pending:
        return Icons.hourglass_empty;
      case CareRequestStatus.assigned:
      case CareRequestStatus.accepted:
        return Icons.person_search;
      case CareRequestStatus.onRoute:
        return Icons.directions_car;
      case CareRequestStatus.inProgress:
        return Icons.medical_services;
      case CareRequestStatus.completed:
        return Icons.check_circle;
      case CareRequestStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  String _getStatusTitle(CareRequestStatus? status) {
    switch (status) {
      case CareRequestStatus.pending:
        return 'Recherche en cours...';
      case CareRequestStatus.assigned:
        return 'Professionnel trouvé !';
      case CareRequestStatus.accepted:
        return 'Demande acceptée';
      case CareRequestStatus.onRoute:
        return 'En route vers vous';
      case CareRequestStatus.inProgress:
        return 'Soin en cours';
      case CareRequestStatus.completed:
        return 'Soin terminé';
      case CareRequestStatus.cancelled:
        return 'Demande annulée';
      default:
        return 'Recherche en cours...';
    }
  }

  String _getStatusDescription(CareRequestStatus? status) {
    switch (status) {
      case CareRequestStatus.pending:
        return 'Nous recherchons le professionnel de santé le plus proche de vous.';
      case CareRequestStatus.assigned:
        return 'Un professionnel a été assigné à votre demande.';
      case CareRequestStatus.accepted:
        return 'Le professionnel a accepté votre demande et se prépare.';
      case CareRequestStatus.onRoute:
        return 'Le professionnel est en route vers votre position.';
      case CareRequestStatus.inProgress:
        return 'Le professionnel est arrivé et effectue les soins.';
      case CareRequestStatus.completed:
        return 'Merci d\'avoir utilisé MediNear !';
      case CareRequestStatus.cancelled:
        return 'Votre demande a été annulée.';
      default:
        return 'Veuillez patienter...';
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Annuler la demande ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette demande de soin ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (widget.request?.id != null) {
                _careRequestBloc.add(
                  CareRequestCancelRequested(widget.request!.id!),
                );
              }
              context.go('/patient');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }
}

