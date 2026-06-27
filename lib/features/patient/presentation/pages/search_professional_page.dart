import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/professional_card.dart';
import '../../../../injection/injection.dart';
import '../../../professional/domain/entities/medical_professional.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class SearchProfessionalPage extends StatelessWidget {
  const SearchProfessionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientBloc>()..add(const LoadAvailableProfessionals()),
      child: const _SearchProfessionalView(),
    );
  }
}

class _SearchProfessionalView extends StatefulWidget {
  const _SearchProfessionalView();

  @override
  State<_SearchProfessionalView> createState() => _SearchProfessionalViewState();
}

class _SearchProfessionalViewState extends State<_SearchProfessionalView> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MedicalProfessional> _applySearchFilter(List<MedicalProfessional> professionals) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return professionals;
    return professionals.where((p) {
      final name = (p.userFullName ?? '').toLowerCase();
      final specialties = p.specialties?.join(' ').toLowerCase() ?? '';
      return name.contains(query) || specialties.contains(query);
    }).toList();
  }

  void _applyFilter(BuildContext context, String value) {
    setState(() => _selectedFilter = value);
    final profession = value == 'all' ? null : value;
    context.read<PatientBloc>().add(FilterProfessionals(profession: profession));
  }

  @override
  Widget build(BuildContext context) {
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
          'Rechercher',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          final professionals = _applySearchFilter(state.filteredProfessionals);
          return Column(
            children: [
              // Search Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rechercher\nun médecin ou infirmier',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un spécialiste',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppTheme.textHint),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildFilterChip(context, 'all', 'Tous'),
                        const SizedBox(width: 10),
                        _buildFilterChip(context, 'doctor', 'Médecins'),
                        const SizedBox(width: 10),
                        _buildFilterChip(context, 'nurse', 'Infirmiers'),
                      ],
                    ),
                  ],
                ),
              ),
              // Count
              if (state.status != PatientStatus.loading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${professionals.length} résultat${professionals.length != 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: Colors.grey[500],
                        onPressed: () => context.read<PatientBloc>().add(const LoadAvailableProfessionals()),
                      ),
                    ],
                  ),
                ),
              // List
              Expanded(
                child: state.status == PatientStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.status == PatientStatus.failure
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  state.error ?? 'Erreur de chargement',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<PatientBloc>().add(const LoadAvailableProfessionals()),
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          )
                        : professionals.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Aucun professionnel disponible',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async => context.read<PatientBloc>().add(const LoadAvailableProfessionals()),
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: professionals.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final pro = professionals[index];
                                    final profLabel = pro.profession == Profession.doctor ? 'Médecin' : 'Infirmier(ère)';
                                    final specialtyStr = pro.specialties?.join(', ');
                                    return ProfessionalCard(
                                      name: pro.userFullName ?? profLabel,
                                      profession: profLabel,
                                      specialty: specialtyStr,
                                      distance: null,
                                      rating: null,
                                      isAvailable: pro.isAvailable,
                                      onTap: () => _showProfessionalDetails(context, pro),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => _applyFilter(context, value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showProfessionalDetails(BuildContext context, MedicalProfessional pro) {
    final profLabel = pro.profession == Profession.doctor ? 'Médecin' : 'Infirmier(ère)';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: pro.profession == Profession.doctor
                            ? AppTheme.doctorGradient
                            : AppTheme.nurseGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          (pro.userFullName ?? profLabel).substring(0, 1),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pro.userFullName ?? profLabel,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(profLabel, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStat(
                          Icons.circle,
                          pro.isAvailable ? 'Disponible' : 'Indisponible',
                          color: pro.isAvailable ? AppTheme.successColor : AppTheme.textHint,
                        ),
                      ],
                    ),
                    if (pro.specialties != null && pro.specialties!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.medical_services_outlined, color: AppTheme.primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                pro.specialties!.join(', '),
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (pro.isAvailable)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/patient/request-doctor');
                          },
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Demander une consultation'),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Ce professionnel n\'est pas disponible',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textHint, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? AppTheme.textHint),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
