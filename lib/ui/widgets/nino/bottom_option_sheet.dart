import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NinoOption {
  final String label;
  final String? sublabel;
  final String icon; // emoji glyph, matches the design source
  final bool selected;
  final VoidCallback onTap;

  const NinoOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.sublabel,
  });
}

/// Bottom sheet with a title bar and a scrollable list of [NinoOption]s —
/// used for every "pick one of many" picker (quan hệ, danh mục, lặp lại,
/// nhắc nhở, năm, người thân).
Future<void> showBottomOptionSheet({
  required BuildContext context,
  required String title,
  required List<NinoOption> options,
  String doneLabel = 'Đóng',
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    isScrollControlled: true,
    builder: (ctx) {
      final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
      final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
      final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.74),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: line2, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 8, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(doneLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: mut)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 22),
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final o = options[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Material(
                        color: o.selected ? priSoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: o.onTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 26,
                                  child: Text(o.icon, style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        o.label,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: o.selected ? FontWeight.w700 : FontWeight.w500,
                                          color: o.selected ? pri : txt,
                                        ),
                                      ),
                                      if (o.sublabel != null && o.sublabel!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 1),
                                          child: Text(
                                            o.sublabel!,
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: mut),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (o.selected) Icon(Icons.check_rounded, size: 18, color: pri),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
