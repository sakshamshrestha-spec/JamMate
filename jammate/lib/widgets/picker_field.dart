import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A field that opens a bottom sheet list (used for Instrument / Genre / Skill).
class PickerField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final Color fill;

  const PickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.fill = Colors.white,
  });

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (final o in options)
              ListTile(
                title: Text(o,
                    style: TextStyle(
                        fontWeight:
                            o == value ? FontWeight.w800 : FontWeight.w500,
                        color: o == value ? AppColors.coral : AppColors.text)),
                trailing: o == value
                    ? const Icon(Icons.check, color: AppColors.coral)
                    : null,
                onTap: () => Navigator.pop(ctx, o),
              ),
          ],
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
        boxShadow: fill == Colors.white ? AppShadows.card : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(value ?? hint,
                style: TextStyle(
                    fontSize: 14,
                    color: value == null ? AppColors.muted : AppColors.text)),
          ),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        GestureDetector(onTap: () => _open(context), child: box),
      ],
    );
  }
}
