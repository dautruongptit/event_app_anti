import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class BottomNavScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavScaffold({super.key, required this.navigationShell});

  static const List<(IconData, String)> _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.people_alt_rounded, 'Người thân'),
    (Icons.calendar_month_rounded, 'Sự kiện'),
    (Icons.person_rounded, 'Tôi'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navBarDark : AppColors.navBarLight,
          border: Border(top: BorderSide(color: isDark ? AppColors.lineDark : AppColors.lineLight)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final active = navigationShell.currentIndex == i;
                final (icon, label) = _items[i];
                return GestureDetector(
                  onTap: () => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 34,
                          height: 28,
                          decoration: BoxDecoration(
                            color: active ? priSoft : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(icon, size: 20, color: active ? pri : mut),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? pri : mut),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
