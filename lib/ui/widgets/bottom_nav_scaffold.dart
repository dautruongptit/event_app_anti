import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/home_provider.dart';

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
                  onTap: () {
                    // StatefulShellRoute.indexedStack giữ nguyên state mỗi
                    // branch khi chuyển tab (không rebuild/initState lại) —
                    // nên sửa người thân/sự kiện ở tab khác xong quay về
                    // Home sẽ không tự refresh. Chủ động tải lại Home mỗi
                    // khi chuyển VÀO tab Home để luôn khớp dữ liệu mới nhất.
                    if (i == 0) context.read<HomeProvider>().refresh();
                    // initialLocation: true LUÔN LUÔN — trước đây chỉ true
                    // khi bấm đúng tab đang active, nên nếu push 1 màn con
                    // (VD: Home -> chi tiết người thân -> Sửa), rồi chuyển
                    // sang tab khác và quay lại, branch vẫn còn nguyên màn
                    // con cũ trên stack thay vì về màn gốc của tab. Bấm tab
                    // nào phải luôn hiện đúng màn gốc của tab đó.
                    navigationShell.goBranch(i, initialLocation: true);
                  },
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
