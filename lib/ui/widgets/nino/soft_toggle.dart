import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Self-drawn track/knob switch matching the design (Material [Switch]
/// has different proportions). 46×27, knob slides 3px↔22px.
class SoftToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const SoftToggle({super.key, required this.value, required this.onChanged, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final on = activeColor ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);
    final off = isDark ? AppColors.line2Dark : AppColors.line2Light;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 27,
        decoration: BoxDecoration(color: value ? on : off, borderRadius: BorderRadius.circular(999)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 21,
            height: 21,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 5, offset: Offset(0, 2))],
            ),
          ),
        ),
      ),
    );
  }
}
