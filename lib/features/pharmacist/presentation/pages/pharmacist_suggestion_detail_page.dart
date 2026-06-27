import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../../care_request/presentation/bloc/care_request_bloc.dart';
import '../../../care_request/presentation/bloc/care_request_event.dart';
import '../../../care_request/presentation/bloc/care_request_state.dart';
import '../../../care_request/domain/entities/care_request.dart';

class PharmacistSuggestionDetailPage extends StatefulWidget {
  final String requestId;

  const PharmacistSuggestionDetailPage({super.key, required this.requestId});

  @override
  State<PharmacistSuggestionDetailPage> createState() => _PharmacistSuggestionDetailPageState();
}

class _PharmacistSuggestionDetailPageState extends State<PharmacistSuggestionDetailPage> {
  List<Map<String, dynamic>> _medications = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CareRequestBloc>()
        ..add(const CareRequestListRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la suggestion'),
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
                (r) => r.id.toString() == widget.requestId,
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
                      'Suggestion introuvable',
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

            // Initialize medications if empty
            if (_medications.isEmpty && request != null && request.prescribedMedications != null) {
              final medicationsText = request.prescribedMedications!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _medications = _parseMedications(medicationsText);
                  });
                }
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientCard(request),
                  const SizedBox(height: 16),
                  _buildProblemCard(request),
                  const SizedBox(height: 16),
                  if (request.prescribedMedications != null &&
                      request.prescribedMedications!.isNotEmpty &&
                      _medications.isNotEmpty) ...[
                    _buildMedicationsCard(context, request),
                    const SizedBox(height: 16),
                  ],
                  if (request.deliveryRequested) ...[
                    _buildDeliveryRequestedCard(),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            );
          },
        ),
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

  Widget _buildProblemCard(CareRequest request) {
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
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: AppTheme.errorColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Problème énuméré par le patient',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
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
              request.notes ?? 'Aucun problème spécifié',
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

  Widget _buildMedicationsCard(BuildContext context, CareRequest request) {
    final allAvailable = _medications.every((med) => med['available'] == true);

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
              const Expanded(
                child: Text(
                  'Médicaments prescrits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Médicament',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Disponible',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              ..._medications.map((med) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          med['name'] as String,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              med['available'] == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: med['available'] == true
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                med['available'] = !(med['available'] == true);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          if (allAvailable && request.deliveryRequested) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showDeliveryDialog(context, request);
                },
                icon: const Icon(Icons.local_shipping, size: 20),
                label: const Text(
                  'Livrer les médicaments au patient',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryRequestedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: AppTheme.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Livraison demandée',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Le patient a demandé la livraison des médicaments',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _parseMedications(String medicationsText) {
    // Parse medications from format: "Medication - dosage, pendant X jour(s)"
    final lines = medicationsText.split('\n');
    return lines.map((line) {
      final parts = line.split(' - ');
      return {
        'name': parts.isNotEmpty ? parts[0].trim() : line.trim(),
        'available': false, // Default to not available
      };
    }).toList();
  }

  void _showDeliveryDialog(BuildContext context, CareRequest request) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Confirmer la livraison'),
        content: const Text(
          'Êtes-vous sûr de vouloir marquer ces médicaments comme livrés au patient ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Implement delivery logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Livraison confirmée'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

