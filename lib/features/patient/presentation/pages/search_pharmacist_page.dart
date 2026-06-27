import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../../pharmacist/domain/entities/pharmacist.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

class SearchPharmacistPage extends StatelessWidget {
  const SearchPharmacistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientBloc>()..add(const LoadAvailablePharmacists()),
      child: const _SearchPharmacistView(),
    );
  }
}

class _SearchPharmacistView extends StatefulWidget {
  const _SearchPharmacistView();

  @override
  State<_SearchPharmacistView> createState() => _SearchPharmacistViewState();
}

class _SearchPharmacistViewState extends State<_SearchPharmacistView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Pharmacist> _applySearchFilter(List<Pharmacist> pharmacists) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return pharmacists;
    return pharmacists.where((p) {
      return (p.pharmacyName?.toLowerCase().contains(query) ?? false) ||
          (p.userFullName?.toLowerCase().contains(query) ?? false) ||
          (p.address?.toLowerCase().contains(query) ?? false);
    }).toList();
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
          'Rechercher un pharmacien',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          final pharmacists = _applySearchFilter(state.pharmacists);
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une pharmacie...',
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
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
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
                                  onPressed: () => context.read<PatientBloc>().add(const LoadAvailablePharmacists()),
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          )
                        : pharmacists.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.local_pharmacy_outlined, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchController.text.isEmpty
                                          ? 'Aucun pharmacien disponible'
                                          : 'Aucun résultat trouvé',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async =>
                                    context.read<PatientBloc>().add(const LoadAvailablePharmacists()),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: pharmacists.length,
                                  itemBuilder: (context, index) =>
                                      _buildPharmacistCard(context, pharmacists[index]),
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPharmacistCard(BuildContext context, Pharmacist pharmacist) {
    final isAvailable = pharmacist.isAvailable;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    pharmacist.userFullName?.substring(0, 1).toUpperCase() ?? 'P',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacist.pharmacyName ?? 'Pharmacie',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pharmacist.userFullName ?? 'Pharmacien',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isAvailable ? AppTheme.successColor : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAvailable ? 'Disponible' : 'Hors ligne',
                      style: TextStyle(
                        color: isAvailable ? AppTheme.successColor : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pharmacist.address != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pharmacist.address!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
          if (pharmacist.userPhone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  pharmacist.userPhone!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAvailable
                  ? () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(pharmacist);
                      } else {
                        context.push('/patient/prescription-request/${pharmacist.id}');
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                Navigator.of(context).canPop()
                    ? 'Sélectionner ce pharmacien'
                    : 'Demander une prescription',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
