import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showBackButton = false,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : showLogo
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildLogo(),
                )
              : null,
      title: showLogo && !showBackButton
          ? null
          : title != null
              ? Text(
                  title!,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                )
              : _buildLogoWithText(),
      centerTitle: !showLogo,
      actions: [
        ...?actions,
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.local_hospital,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildLogoWithText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(),
        const SizedBox(width: 10),
        const Text(
          'MediNear',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

