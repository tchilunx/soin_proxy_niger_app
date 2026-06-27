import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../care_request/domain/entities/care_request.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';

class NavigationPage extends StatefulWidget {
  final String requestId;
  final CareRequest? request;

  const NavigationPage({
    super.key,
    required this.requestId,
    this.request,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Update status to on_route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfessionalBloc>().add(
            ProfessionalRequestStatusUpdated(
              requestId: int.parse(widget.requestId),
              status: 'on_route',
            ),
          );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  CareRequest? _getActiveRequest(ProfessionalState state) {
    // Try to find the request from activeRequest or myRequests
    if (state.activeRequest?.id.toString() == widget.requestId) {
      return state.activeRequest;
    }
    try {
      return state.myRequests.firstWhere(
        (r) => r.id.toString() == widget.requestId,
      );
    } catch (_) {
      return widget.request;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfessionalBloc, ProfessionalState>(
      builder: (context, state) {
        final request = _getActiveRequest(state);

        return Scaffold(
          body: Stack(
            children: [
              // Map placeholder
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFE8F4F8),
                child: CustomPaint(
                  painter: _MapPainter(),
                  child: const Center(
                    child: Text(
                      'Carte de navigation',
                      style: TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              // Top bar
              _buildTopBar(context, request),
              // Route indicator
              _buildRouteIndicator(context, request),
              // Destination marker
              _buildDestinationMarker(),
              // Bottom panel
              _buildBottomPanel(context, request),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, CareRequest? request) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'En chemin vers le patient',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.successColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '~10 min • ~2 km',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'En route',
                style: TextStyle(
                  color: AppTheme.infoColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteIndicator(BuildContext context, CareRequest? request) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.navigation,
                    color: AppTheme.infoColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Destination',
                        style: TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request?.address ?? 'Adresse du patient',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Open in Maps button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openInMaps(request),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Ouvrir dans Google Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationMarker() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 60 + (20 * _pulseController.value),
            height: 60 + (20 * _pulseController.value),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(
                alpha: 0.2 - (0.15 * _pulseController.value),
              ),
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, CareRequest? request) {
    final patientName = request?.patientName ?? 'Patient';
    final patientInitial = patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Patient info
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      patientInitial,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 22,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request?.address ?? 'Adresse non spécifiée',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Call button
                GestureDetector(
                  onTap: () => _callPatient(request?.patientPhone),
                  child: Container(
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
            const SizedBox(height: 16),
            // Request details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.medical_services_outlined,
                    request?.notes ?? 'Consultation',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.schedule,
                    _formatRequestTime(request?.requestedAt),
                  ),
                  if (request?.isUrgent == true) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.warning_amber_rounded,
                      'Demande urgente',
                      color: AppTheme.errorColor,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _showArrivedDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Je suis arrivé'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppTheme.textHint),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: color ?? Colors.grey[700],
            fontSize: 14,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatRequestTime(DateTime? time) {
    if (time == null) return 'Demandé récemment';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Demandé à l\'instant';
    if (diff.inMinutes < 60) return 'Demandé il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Demandé il y a ${diff.inHours}h';
    return 'Demandé il y a ${diff.inDays}j';
  }

  Future<void> _openInMaps(CareRequest? request) async {
    if (request?.latitude != null && request?.longitude != null) {
      final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${request!.latitude},${request.longitude}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else if (request?.address != null) {
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(request!.address!)}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _callPatient(String? phone) async {
    if (phone != null && phone.isNotEmpty) {
      final url = Uri.parse('tel:$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  void _showCancelDialog(BuildContext context) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Annuler la course ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette demande ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfessionalBloc>().add(
                    ProfessionalRequestStatusUpdated(
                      requestId: int.parse(widget.requestId),
                      status: 'cancelled',
                    ),
                  );
              context.go('/professional');
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

  void _showArrivedDialog(BuildContext context) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Confirmer l\'arrivée'),
        content: const Text(
          'Confirmez-vous être arrivé chez le patient ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfessionalBloc>().add(
                    ProfessionalRequestStatusUpdated(
                      requestId: int.parse(widget.requestId),
                      status: 'in_progress',
                    ),
                  );
              context.push('/professional/consultation/${widget.requestId}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Oui, je suis arrivé'),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw some grid lines to simulate a map
    for (var i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(0, i * size.height / 10),
        Offset(size.width, i * size.height / 10),
        paint,
      );
      canvas.drawLine(
        Offset(i * size.width / 10, 0),
        Offset(i * size.width / 10, size.height),
        paint,
      );
    }

    // Draw a route line
    final routePaint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.6,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.4,
        size.width * 0.5,
        size.height * 0.5,
      );

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
