import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection.dart';
import '../../../care_request/presentation/bloc/care_request_bloc.dart';
import '../../../care_request/presentation/bloc/care_request_event.dart';
import '../../../care_request/presentation/bloc/care_request_state.dart';
import '../../../care_request/domain/entities/care_request.dart';

class ConsultationRatingPage extends StatefulWidget {
  final String requestId;

  const ConsultationRatingPage({super.key, required this.requestId});

  @override
  State<ConsultationRatingPage> createState() => _ConsultationRatingPageState();
}

class _ConsultationRatingPageState extends State<ConsultationRatingPage> {
  int _rating = 0;
  final _commentController = TextEditingController();
  String _selectedBadge = '';

  final List<String> _badges = [
    'Professionnel',
    'Ponctuel',
    'À l\'écoute',
    'Bonne communication',
    'Efficace',
    'Empathique',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  CareRequest? _getRequest(CareRequestState state) {
    if (state.requests.isEmpty) {
      return null;
    }
    try {
      return state.requests.firstWhere(
        (r) => r.id.toString() == widget.requestId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CareRequestBloc>()
        ..add(const CareRequestListRequested()),
      child: BlocBuilder<CareRequestBloc, CareRequestState>(
        builder: (context, state) {
          if (state.status == CareRequestStateStatus.loading) {
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
                  icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                  onPressed: () => context.pop(),
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
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Cette consultation n\'existe pas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              ),
            );
          }

          final professionalName = request.professionalName ?? 'Professionnel';
          final professionalInitial = professionalName.isNotEmpty
              ? professionalName[0].toUpperCase()
              : 'P';

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                'Évaluer la consultation',
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
                  // Professional info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppTheme.doctorGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              professionalInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          professionalName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request?.notes ?? 'Consultation',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Rating stars
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Comment s\'est passée\ncette consultation ?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => setState(() => _rating = index + 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppTheme.warningColor,
                                  size: 44,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getRatingText(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Badges
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
                          'Ce qui vous a plu (optionnel)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _badges.map((badge) {
                            final isSelected = _selectedBadge == badge;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedBadge = isSelected ? '' : badge;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Comment
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
                          'Commentaire (optionnel)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Laissez un commentaire sur cette consultation...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _rating > 0 ? () => _submitRating(context) : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.accentColor,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Envoyer l\'évaluation',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Passer cette étape',
                      style: TextStyle(color: AppTheme.textHint),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Très insatisfait';
      case 2:
        return 'Insatisfait';
      case 3:
        return 'Correct';
      case 4:
        return 'Satisfait';
      case 5:
        return 'Très satisfait';
      default:
        return 'Sélectionnez une note';
    }
  }

  void _submitRating(BuildContext context) {
    // TODO: Implement API call to submit rating
    context.read<CareRequestBloc>().add(
          CareRequestRatingSubmitted(
            requestId: int.parse(widget.requestId),
            rating: _rating,
            comment: _commentController.text.isNotEmpty
                ? _commentController.text
                : null,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Merci pour votre évaluation !'),
        backgroundColor: AppTheme.successColor,
      ),
    );
    context.pop();
  }
}

