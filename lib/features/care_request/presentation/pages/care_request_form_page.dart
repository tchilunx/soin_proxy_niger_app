import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/care_request.dart';
import '../bloc/care_request_bloc.dart';
import '../bloc/care_request_event.dart';
import '../bloc/care_request_state.dart';

class CareRequestFormPage extends StatefulWidget {
  final ProfessionType professionType;

  const CareRequestFormPage({
    super.key,
    required this.professionType,
  });

  @override
  State<CareRequestFormPage> createState() => _CareRequestFormPageState();
}

class _CareRequestFormPageState extends State<CareRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isUrgent = false;
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Les services de localisation sont désactivés. Veuillez les activer.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Permission de localisation refusée.';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Permission de localisation refusée définitivement. Veuillez l\'activer dans les paramètres.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Impossible d\'obtenir votre position: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  void _submitRequest(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez attendre la localisation ou réessayer'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      context.read<CareRequestBloc>().add(
        CareRequestCreateRequested(
          professionType: widget.professionType,
          latitude: _latitude!,
          longitude: _longitude!,
          address: _addressController.text.isNotEmpty ? _addressController.text : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          isUrgent: _isUrgent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = widget.professionType == ProfessionType.doctor;
    final color = isDoctor ? AppTheme.doctorColor : AppTheme.nurseColor;
    final title = isDoctor ? 'Demander un Médecin' : 'Demander un Infirmier(e)';

    return BlocProvider(
      create: (context) => getIt<CareRequestBloc>(),
      child: BlocConsumer<CareRequestBloc, CareRequestState>(
        listener: (context, state) {
          if (state.status == CareRequestStateStatus.created) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Demande envoyée avec succès !'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/patient/tracking', extra: state.lastCreatedRequest);
          } else if (state.status == CareRequestStateStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Une erreur est survenue'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == CareRequestStateStatus.creating;

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Professional type card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.8), color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isDoctor ? Icons.local_hospital : Icons.healing,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDoctor ? 'Médecin' : 'Infirmier(e)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isDoctor
                                      ? 'Consultation médicale à domicile'
                                      : 'Soins infirmiers à domicile',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Location section
                    _buildSectionTitle('Votre position'),
                    const SizedBox(height: 12),
                    _buildLocationCard(),

                    const SizedBox(height: 24),

                    // Address field
                    _buildSectionTitle('Adresse (optionnel)'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: _buildInputDecoration(
                        hintText: 'Ex: 123 Rue de la Santé, Apt 4B',
                        prefixIcon: Icons.home_outlined,
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    // Notes field
                    _buildSectionTitle('Description des symptômes'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: _buildInputDecoration(
                        hintText: 'Décrivez vos symptômes ou la raison de votre demande...',
                        prefixIcon: Icons.note_outlined,
                      ),
                      maxLines: 4,
                    ),

                    const SizedBox(height: 24),

                    // Urgent toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isUrgent
                            ? AppTheme.errorColor.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isUrgent
                              ? AppTheme.errorColor.withValues(alpha: 0.3)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _isUrgent
                                  ? AppTheme.errorColor.withValues(alpha: 0.2)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.priority_high,
                              color: _isUrgent ? AppTheme.errorColor : AppTheme.textHint,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Demande urgente',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Priorisera votre demande',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isUrgent,
                            onChanged: (value) => setState(() => _isUrgent = value),
                            activeColor: AppTheme.errorColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading || _isLoadingLocation || _latitude == null
                            ? null
                            : () => _submitRequest(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Envoyer la demande',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Warning
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.warningColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.warningColor,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'En cas d\'urgence vitale, appelez le 15 (SAMU)',
                              style: TextStyle(
                                color: AppTheme.warningColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _locationError != null
                      ? AppTheme.errorColor.withValues(alpha: 0.1)
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoadingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _locationError != null
                            ? Icons.location_off
                            : Icons.my_location,
                        color: _locationError != null
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoadingLocation
                          ? 'Localisation en cours...'
                          : _locationError != null
                              ? 'Erreur de localisation'
                              : 'Position obtenue',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: _locationError != null
                            ? AppTheme.errorColor
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoadingLocation
                          ? 'Veuillez patienter...'
                          : _locationError != null
                              ? _locationError!
                              : 'Lat: ${_latitude?.toStringAsFixed(6)}, Lng: ${_longitude?.toStringAsFixed(6)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_locationError != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(prefixIcon, color: AppTheme.textHint),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}

