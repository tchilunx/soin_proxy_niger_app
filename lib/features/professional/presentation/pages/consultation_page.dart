import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../care_request/domain/entities/care_request.dart';
import '../../../pharmacist/domain/entities/pharmacist.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';

class ConsultationPage extends StatefulWidget {
  final String requestId;

  const ConsultationPage({super.key, required this.requestId});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

// Class to represent a prescribed medication
class _PrescribedMedication {
  final String name;
  final int tabletsMorning;
  final int tabletsEvening;
  final int days;

  _PrescribedMedication({
    required this.name,
    required this.tabletsMorning,
    required this.tabletsEvening,
    required this.days,
  });

  String get description {
    final parts = <String>[];
    if (tabletsMorning > 0) {
      parts.add('$tabletsMorning comprimé(s) le matin');
    }
    if (tabletsEvening > 0) {
      parts.add('$tabletsEvening comprimé(s) le soir');
    }
    return '$name - ${parts.join(', ')}, pendant $days jour(s)';
  }
}

class _ConsultationPageState extends State<ConsultationPage> {
  bool _consultationStarted = true;
  DateTime? _startTime;
  int? _selectedPharmacistId;
  Pharmacist? _selectedPharmacist;
  
  // Medications management
  final List<_PrescribedMedication> _prescribedMedications = [];
  String? _selectedMedication;
  final TextEditingController _customMedicationController = TextEditingController();
  final TextEditingController _tabletsMorningController = TextEditingController();
  final TextEditingController _tabletsEveningController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  
  // Common medications list
  final List<String> _commonMedications = [
    'Paracétamol',
    'Ibuprofène',
    'Amoxicilline',
    'Doxycycline',
    'Ciprofloxacine',
    'Métronidazole',
    'Artéméther-Luméfantrine',
    'Quinine',
    'Chloroquine',
    'Aspirine',
    'Oméprazole',
    'Ranitidine',
    'Loratadine',
    'Salbutamol',
    'Prednisolone',
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _customMedicationController.dispose();
    _tabletsMorningController.dispose();
    _tabletsEveningController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  CareRequest? _getRequest(ProfessionalState state) {
    if (state.myRequests.isEmpty && state.activeRequest == null) {
      return null;
    }
    try {
      return state.myRequests.firstWhere(
        (r) => r.id.toString() == widget.requestId,
      );
    } catch (_) {
      return state.activeRequest;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfessionalBloc, ProfessionalState>(
      builder: (context, state) {
        if (state.status == ProfessionalStateStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final request = _getRequest(state);
        
        if (request == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Consultation introuvable',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: const Center(
              child: Text('Cette consultation n\'existe pas'),
            ),
          );
        }

        final patientName = request.patientName ?? 'Patient';
        final patientInitial = patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Consultation en cours',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Patient info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                patientInitial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
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
                                  patientName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Patient',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                if (request?.isUrgent == true) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'URGENT',
                                      style: TextStyle(
                                        color: AppTheme.errorColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Contact buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _callPatient(request?.patientPhone),
                              child: _buildContactButton(
                                Icons.phone,
                                'Appeler',
                                AppTheme.successColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildContactButton(
                              Icons.message,
                              'Message',
                              AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Consultation details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Détails de la consultation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        Icons.location_on_outlined,
                        'Adresse',
                        request?.address ?? 'Adresse non spécifiée',
                      ),
                      _buildDetailItem(
                        Icons.medical_services_outlined,
                        'Type de consultation',
                        request?.notes ?? 'Consultation',
                      ),
                      _buildDetailItem(
                        Icons.schedule,
                        'Demandé',
                        _formatRequestTime(request?.requestedAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Consultation timer
                if (_consultationStarted)
                  _buildTimerCard(),
                const SizedBox(height: 20),
                // Medications and Pharmacist Section
                if (_consultationStarted) ...[
                  _buildMedicationsSection(context, request),
                  const SizedBox(height: 20),
                ],
                // Selected Pharmacist Card (if selected) - displayed before finish button
                if (_selectedPharmacist != null) ...[
                  _buildSelectedPharmacistCard(_selectedPharmacist!),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 24),
                // Action buttons
                if (!_consultationStarted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _consultationStarted = true;
                          _startTime = DateTime.now();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Démarrer la consultation',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showEndConsultationDialog(context, request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Terminer la consultation',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerCard() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final duration = _startTime != null
            ? DateTime.now().difference(_startTime!)
            : Duration.zero;
        final hours = duration.inHours.toString().padLeft(2, '0');
        final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consultation en cours',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$hours:$minutes:$seconds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isWarning
                  ? AppTheme.warningColor.withValues(alpha: 0.1)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isWarning ? AppTheme.warningColor : AppTheme.textHint,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isWarning ? AppTheme.warningColor : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRequestTime(DateTime? time) {
    if (time == null) return 'Non spécifié';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays}j';
  }

  Future<void> _callPatient(String? phone) async {
    if (phone != null && phone.isNotEmpty) {
      final url = Uri.parse('tel:$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  Widget _buildMedicationsSection(BuildContext context, CareRequest? request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Médicaments prescrits',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          
          // List of prescribed medications
          if (_prescribedMedications.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: _prescribedMedications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final medication = entry.value;
                  return _buildMedicationRow(medication, index);
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Medication selection form
          _buildMedicationForm(),
          
          const SizedBox(height: 16),
          const Text(
            'Suggérer un pharmacien (optionnel)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await context.push('/patient/search-pharmacist');
                if (result != null) {
                  setState(() {
                    if (result is Pharmacist) {
                      _selectedPharmacist = result;
                      _selectedPharmacistId = result.id;
                    } else if (result is int) {
                      _selectedPharmacistId = result;
                      _selectedPharmacist = null; // Will need to fetch details
                    }
                  });
                }
              },
              icon: const Icon(Icons.local_pharmacy),
              label: Text(
                _selectedPharmacistId != null
                    ? 'Pharmacien sélectionné'
                    : 'Sélectionner un pharmacien',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationRow(_PrescribedMedication medication, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: index < _prescribedMedications.length - 1
                ? const Color(0xFFE2E8F0)
                : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMedicationDosage(medication),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppTheme.errorColor,
                size: 18,
              ),
            ),
            onPressed: () {
              setState(() {
                _prescribedMedications.removeAt(index);
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationForm() {
    final isCustomMedication = _selectedMedication == 'custom';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Medication selection dropdown
        DropdownButtonFormField<String>(
          value: _selectedMedication,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Médicament',
            hintText: 'Sélectionner un médicament',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Sélectionner un médicament',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ..._commonMedications.map((med) => DropdownMenuItem<String>(
              value: med,
              child: Text(
                med,
                overflow: TextOverflow.ellipsis,
              ),
            )),
            const DropdownMenuItem<String>(
              value: 'custom',
              child: Text(
                'Saisir un médicament personnalisé',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          selectedItemBuilder: (context) {
            return [
              const Text(
                'Sélectionner un médicament',
                overflow: TextOverflow.ellipsis,
              ),
              ..._commonMedications.map((med) => Text(
                med,
                overflow: TextOverflow.ellipsis,
              )),
              const Text(
                'Saisir un médicament personnalisé',
                overflow: TextOverflow.ellipsis,
              ),
            ];
          },
          onChanged: (value) {
            setState(() {
              _selectedMedication = value;
              if (value != 'custom') {
                _customMedicationController.clear();
              }
            });
          },
        ),
        
        // Custom medication input (if selected)
        if (isCustomMedication) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _customMedicationController,
            decoration: InputDecoration(
              labelText: 'Nom du médicament',
              hintText: 'Entrez le nom du médicament',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        // Dosage inputs - Morning and Evening
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tabletsMorningController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'nbr-matin',
                  hintText: 'Ex: 2',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _tabletsEveningController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'nbr-soir',
                  hintText: 'Ex: 2',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Duration and Add button row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Durée (jours)',
                  hintText: 'Ex: 7',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _addMedication,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatMedicationDosage(_PrescribedMedication medication) {
    final parts = <String>[];
    if (medication.tabletsMorning > 0) {
      parts.add('${medication.tabletsMorning} comprimé(s) le matin');
    }
    if (medication.tabletsEvening > 0) {
      parts.add('${medication.tabletsEvening} comprimé(s) le soir');
    }
    if (parts.isEmpty) {
      return '${medication.days} jour(s)';
    }
    return '${parts.join(', ')}, ${medication.days} jour(s)';
  }

  void _addMedication() {
    final medicationName = isCustomMedication
        ? _customMedicationController.text.trim()
        : _selectedMedication;
    
    if (medicationName == null || medicationName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner ou saisir un médicament')),
      );
      return;
    }

    final tabletsMorningText = _tabletsMorningController.text.trim();
    final tabletsEveningText = _tabletsEveningController.text.trim();
    final daysText = _daysController.text.trim();

    if (tabletsMorningText.isEmpty && tabletsEveningText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir au moins un champ (matin ou soir)')),
      );
      return;
    }

    if (daysText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir la durée')),
      );
      return;
    }

    final tabletsMorning = int.tryParse(tabletsMorningText) ?? 0;
    final tabletsEvening = int.tryParse(tabletsEveningText) ?? 0;
    final days = int.tryParse(daysText);

    if (tabletsMorning < 0 || tabletsEvening < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nombre de comprimés ne peut pas être négatif')),
      );
      return;
    }

    if (days == null || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La durée doit être un nombre positif')),
      );
      return;
    }

    setState(() {
      _prescribedMedications.add(_PrescribedMedication(
        name: medicationName,
        tabletsMorning: tabletsMorning,
        tabletsEvening: tabletsEvening,
        days: days,
      ));
      
      // Reset form
      _selectedMedication = null;
      _customMedicationController.clear();
      _tabletsMorningController.clear();
      _tabletsEveningController.clear();
      _daysController.clear();
    });
  }

  bool get isCustomMedication => _selectedMedication == 'custom';

  Widget _buildSelectedPharmacistCard(Pharmacist pharmacist) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
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
            child: const Icon(
              Icons.local_pharmacy,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Pharmacien suggéré',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Sélectionné',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pharmacist.pharmacyName ?? 'Pharmacie',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (pharmacist.userFullName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    pharmacist.userFullName!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (pharmacist.userPhone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pharmacist.userPhone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: Colors.grey[400],
            onPressed: () {
              setState(() {
                _selectedPharmacist = null;
                _selectedPharmacistId = null;
              });
            },
          ),
        ],
      ),
    );
  }

  void _showEndConsultationDialog(BuildContext context, CareRequest? request) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Terminer la consultation'),
        content: const Text(
          'Êtes-vous sûr de vouloir terminer cette consultation ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Format medications as a string
              final medicationsText = _prescribedMedications
                  .map((m) => m.description)
                  .join('\n');
              
              // Update status to completed with medications and pharmacist
              context.read<ProfessionalBloc>().add(
                    ProfessionalRequestStatusUpdated(
                      requestId: int.parse(widget.requestId),
                      status: 'completed',
                      prescribedMedications: medicationsText.isNotEmpty
                          ? medicationsText
                          : null,
                      suggestedPharmacistId: _selectedPharmacistId,
                    ),
                  );
              context.push('/professional/request/${widget.requestId}');
            },
            child: const Text('Oui, terminer'),
          ),
        ],
      ),
    );
  }
}
