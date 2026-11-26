import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Big rounded button. `outlined: true` gives the white style.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Text(label),
      ],
    );
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: outlined ? null : AppGradients.brand,
        color: outlined ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        border: outlined ? Border.all(color: AppColors.line) : null,
        boxShadow: outlined
            ? null
            : const [
                BoxShadow(
                    color: Color(0x40E84C5C),
                    blurRadius: 16,
                    offset: Offset(0, 6))
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: outlined ? AppColors.text : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        child: child,
      ),
    );
  }
}
