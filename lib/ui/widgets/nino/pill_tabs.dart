import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Underlined text tabs (Home's "Người thân" / "Sự kiện của tôi").
class PillTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const PillTabs({super.key, required this.labels, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Row(
      children: List.generate(labels.length, (i) {
        final selected = i == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 24),
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? pri : mut,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2.5,
                  width: 28,
                  decoration: BoxDecoration(
                    color: selected ? pri : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Row of standalone pill filter chips (Sự kiện's 4 filters).
class FilterChipsRow extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const FilterChipsRow({super.key, required this.labels, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final label = labels[i];
          final isOn = label == selected;
          return GestureDetector(
            onTap: () => onChanged(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: isOn ? txt : card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: isOn ? txt : line2),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOn ? (isDark ? AppColors.bgDark : Colors.white) : mut,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 3-way segmented control (Lịch nghỉ lễ's Tất cả/Dương lịch/Âm lịch).
class SegmentedPillTabs extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const SegmentedPillTabs({super.key, required this.labels, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.cardDark : Colors.white;
    final track = isDark ? AppColors.neutralSoftDark : AppColors.neutralSoftLight;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: labels.map((label) {
          final isOn = label == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(label),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isOn ? card : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isOn
                      ? [BoxShadow(color: isDark ? AppColors.shadowDark : AppColors.shadowLight, blurRadius: 4)]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                    color: isOn ? txt : mut,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
