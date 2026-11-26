import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rounded chip for filters and role selection.
/// filled: true  -> selected chip is solid coral (filters)
/// filled: false -> selected chip is light coral with coral text (roles)
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool filled;
  final IconData? icon;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.filled = false,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color fg = AppColors.text;
    if (selected) {
      bg = filled ? AppColors.coral : AppColors.coralLight;
      fg = filled ? Colors.white : AppColors.coral;
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: selected && !filled ? AppColors.coral : Colors.transparent),
          boxShadow: selected && filled ? null : AppShadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                    color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
