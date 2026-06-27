import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = AppConstants.rolePatient;
  String _selectedProfession = AppConstants.professionDoctor;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _pharmacyNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
              phone: _phoneController.text.trim(),
              role: _selectedRole,
              profession: _selectedRole == AppConstants.roleMedicalProfessional
                  ? _selectedProfession
                  : null,
              licenseNumber: _selectedRole == AppConstants.roleMedicalProfessional ||
                      _selectedRole == AppConstants.rolePharmacist
                  ? _licenseNumberController.text.trim()
                  : null,
              pharmacyName: _selectedRole == AppConstants.rolePharmacist
                  ? _pharmacyNameController.text.trim()
                  : null,
              address: _selectedRole == AppConstants.rolePharmacist
                  ? _addressController.text.trim()
                  : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Inscription'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Une erreur est survenue'),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state.isAuthenticated) {
            if (state.isPatient) {
              context.go('/patient');
            } else if (state.isMedicalProfessional) {
              context.go('/professional');
            } else if (state.isPharmacist) {
              context.go('/pharmacist');
            }
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                _buildLogo(),
                const SizedBox(height: 24),
                // Role selection
                _buildRoleSelection(),
                  const SizedBox(height: 24),
                  // Full name
                  TextFormField(
                    controller: _fullNameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      hintText: 'Jean Dupont',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'exemple@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      hintText: '+33 6 12 34 56 78',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Professional fields
                  if (_selectedRole == AppConstants.roleMedicalProfessional) ...[
                    _buildProfessionSelection(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _licenseNumberController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de licence',
                        hintText: 'LIC-12345',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (_selectedRole ==
                                AppConstants.roleMedicalProfessional &&
                            (value == null || value.isEmpty)) {
                          return 'Veuillez entrer votre numéro de licence';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Pharmacist fields
                  if (_selectedRole == AppConstants.rolePharmacist) ...[
                    TextFormField(
                      controller: _pharmacyNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la pharmacie',
                        hintText: 'Pharmacie Centrale',
                        prefixIcon: Icon(Icons.local_pharmacy),
                      ),
                      validator: (value) {
                        if (_selectedRole == AppConstants.rolePharmacist &&
                            (value == null || value.isEmpty)) {
                          return 'Veuillez entrer le nom de la pharmacie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _licenseNumberController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de licence',
                        hintText: 'LIC-12345',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (_selectedRole == AppConstants.rolePharmacist &&
                            (value == null || value.isEmpty)) {
                          return 'Veuillez entrer votre numéro de licence';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        hintText: 'Rue, Ville, Pays',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (_selectedRole == AppConstants.rolePharmacist &&
                            (value == null || value.isEmpty)) {
                          return 'Veuillez entrer l\'adresse de la pharmacie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Confirm password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onRegister(),
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Register button
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  // Login link
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Je suis',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                role: AppConstants.rolePatient,
                icon: Icons.person,
                label: 'Patient',
                color: AppTheme.patientColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleCard(
                role: AppConstants.roleMedicalProfessional,
                icon: Icons.medical_services,
                label: 'Professionnel',
                color: AppTheme.doctorColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleCard(
                role: AppConstants.rolePharmacist,
                icon: Icons.local_pharmacy,
                label: 'Pharmacien',
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profession',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildProfessionChip(
                profession: AppConstants.professionDoctor,
                label: 'Médecin',
                icon: Icons.local_hospital,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProfessionChip(
                profession: AppConstants.professionNurse,
                label: 'Infirmier(e)',
                icon: Icons.healing,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionChip({
    required String profession,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedProfession == profession;
    final color = profession == AppConstants.professionDoctor
        ? AppTheme.doctorColor
        : AppTheme.nurseColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProfession = profession;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? color : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? color : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: state.isLoading ? null : _onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor, // Orange button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'S\'inscrire',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            'Se connecter',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: AppTheme.authGradient, // Orange to Teal gradient
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            AppConstants.logoPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.medical_services_rounded,
                color: Colors.white,
                size: 50,
              );
            },
          ),
        ),
      ),
    );
  }
}

