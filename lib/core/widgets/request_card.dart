import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RequestCard extends StatelessWidget {
  final String patientName;
  final String? requestType;
  final String? address;
  final String? distance;
  final String? time;
  final String status;
  final bool isUrgent;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RequestCard({
    super.key,
    required this.patientName,
    this.requestType,
    this.address,
    this.distance,
    this.time,
    required this.status,
    this.isUrgent = false,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent
                ? AppTheme.errorColor.withValues(alpha: 0.3)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      patientName.isNotEmpty ? patientName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Urgent',
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (requestType != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          requestType!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Details
            if (address != null)
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (distance != null) ...[
                  Icon(Icons.directions_car_outlined, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text(
                    distance!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (time != null) ...[
                  Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text(
                    time!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
                const Spacer(),
                _buildStatusBadge(),
              ],
            ),
            // Actions
            if (onAccept != null || onReject != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onAccept != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Accepter'),
                      ),
                    ),
                  if (onAccept != null && onReject != null)
                    const SizedBox(width: 12),
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Refuser'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        color = AppTheme.warningColor;
        label = 'En attente';
        break;
      case 'accepted':
        color = AppTheme.successColor;
        label = 'Acceptée';
        break;
      case 'on_route':
        color = AppTheme.infoColor;
        label = 'En route';
        break;
      case 'in_progress':
        color = AppTheme.primaryColor;
        label = 'En cours';
        break;
      case 'completed':
        color = AppTheme.successColor;
        label = 'Terminée';
        break;
      case 'cancelled':
        color = AppTheme.textHint;
        label = 'Annulée';
        break;
      default:
        color = AppTheme.textHint;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

