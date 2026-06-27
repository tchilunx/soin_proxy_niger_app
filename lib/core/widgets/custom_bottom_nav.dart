import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDoctor;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isDoctor = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = isDoctor
        ? [
            _NavItem(icon: Icons.home_rounded, label: 'Accueil'),
            _NavItem(icon: Icons.assignment_rounded, label: 'Demandes'),
            _NavItem(icon: Icons.history_rounded, label: 'Historique'),
            _NavItem(icon: Icons.person_rounded, label: 'Profil'),
          ]
        : [
            _NavItem(icon: Icons.home_rounded, label: 'Accueil'),
            _NavItem(icon: Icons.assignment_rounded, label: 'Demandes'),
            _NavItem(icon: Icons.history_rounded, label: 'Historique'),
            _NavItem(icon: Icons.person_rounded, label: 'Profil'),
          ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              return _buildNavItem(item, isSelected, () => onTap(index));
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textHint,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

