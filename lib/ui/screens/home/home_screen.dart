import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../models/event.dart';
import '../../../models/relative.dart';
import '../../widgets/nino/nino_logo.dart';
import '../../widgets/nino/initials_avatar.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/pill_tabs.dart';
import '../../widgets/nino/shake_on_change.dart';
import '../../widgets/nino/nino_toast.dart';
import '../../widgets/nino/connection_error_dialog.dart';
import '../../../core/network/api_exceptions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  static const List<List<Color>> _upcomingGradients = [
    [Color(0xFFFF8080), Color(0xFFFF5A5F)],
    [Color(0xFFFFD558), Color(0xFFFFB627)],
    [Color(0xFFBBA5FB), Color(0xFF9C81F0)],
    [Color(0xFF66DCD3), Color(0xFF3EC0B7)],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshAndNotifyOnError();
      if (!mounted) return;
      // Trước đây chỉ được gọi khi mở màn Thông báo — badge số chưa đọc ở
      // chuông trên Home luôn hiện sai/0 cho tới khi người dùng tự bấm vào
      // chuông ít nhất 1 lần trong phiên. Tải ngay khi vào Home để badge
      // đúng ngay từ đầu.
      context.read<NotificationProvider>().loadUnreadCount();
    });
  }

  /// Tải dữ liệu Home, và nếu lỗi (backend sập, mất mạng...) báo ngay cho
  /// người dùng — trước đây lỗi bị nuốt im lặng, Home chỉ hiện rỗng trông
  /// như "chưa có dữ liệu" dù thực chất là không gọi được API. Lỗi mất
  /// mạng/timeout dùng popup (có nút "Thử lại") vì nghiêm trọng, dễ bị bỏ
  /// lỡ hơn nếu chỉ là toast tự biến mất; lỗi khác vẫn dùng toast.
  Future<void> _refreshAndNotifyOnError() async {
    final homeProvider = context.read<HomeProvider>();
    await homeProvider.refresh();
    if (!mounted) return;
    final error = homeProvider.error;
    if (error == null) return;
    if (isNetworkErrorMessage(error)) {
      showConnectionErrorDialog(context, onRetry: _refreshAndNotifyOnError);
    } else {
      showNinoToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeData = homeProvider.homeData;
    final userName = homeData?.userName ?? user?.fullName ?? 'Khách';
    final avatarUrl = homeData?.avatarUrl ?? user?.avatarUrl;
    final notificationProvider = context.watch<NotificationProvider>();
    final unreadCount = notificationProvider.unreadCount;
    final newNotificationTick = notificationProvider.newNotificationTick;

    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAndNotifyOnError,
          child: homeProvider.isLoading && homeData == null
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context, userName, avatarUrl, isDark, unreadCount, newNotificationTick, txt, mut, card, line)),
                    if (homeData != null && homeData.upcomingEvents.isNotEmpty)
                      SliverToBoxAdapter(child: _buildUpcomingEventsSection(context, homeData.upcomingEvents, txt, mut, pri)),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: PillTabs(
                          labels: const ['Người thân', 'Sự kiện của tôi'],
                          selectedIndex: _selectedTab,
                          onChanged: (i) => setState(() => _selectedTab = i),
                          showIndicator: false,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 13)),
                    SliverToBoxAdapter(
                      child: _selectedTab == 0
                          ? _buildRelativesTab(context, homeData?.relatives ?? [], isDark, mut, pri, priSoft)
                          : _buildMyEventsTab(context, homeProvider.myEvents, isDark, mut, mint, mintSoft),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, String? avatarUrl, bool isDark, int unreadCount,
      int newNotificationTick, Color txt, Color mut, Color card, Color line) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: Row(
                children: [
                  InitialsAvatar(
                    name: userName,
                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    softColor: isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight,
                    radius: 21,
                    avatarUrl: avatarUrl,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const NinoLogo(size: 17, showBadge: false),
                            const SizedBox(width: 6),
                            Text('Xin chào 👋', style: TextStyle(fontSize: 12, color: mut, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text('Hi, $userName',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: txt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded, color: txt, size: 19),
                style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
              ),
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ShakeOnChange(
                    trigger: newNotificationTick,
                    child: IconButton(
                      onPressed: () => context.push('/profile/notifications'),
                      icon: Icon(Icons.notifications_none_rounded, color: mut, size: 21),
                      style: IconButton.styleFrom(backgroundColor: card, shape: CircleBorder(side: BorderSide(color: line))),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppColors.bgDark : AppColors.bgLight, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection(BuildContext context, List<EventModel> events, Color txt, Color mut, Color pri) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sự kiện sắp tới', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt)),
              GestureDetector(
                onTap: () => context.push('/events'),
                child: Text('Xem tất cả →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: pri)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 152,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(18, 2, 6, 6),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final days = event.daysUntil ?? 0;
              final big = days == 0 ? 'Hôm nay' : '$days';
              final gradient = _upcomingGradients[index % _upcomingGradients.length];
              return GestureDetector(
                onTap: () => context.push('/events/${event.id}'),
                child: Container(
                  width: 142,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.26), borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Icon(event.eventTypeIcon, color: Colors.white, size: 15),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(big, style: TextStyle(fontSize: days == 0 ? 22 : 36, fontWeight: FontWeight.w700, color: Colors.white, height: 1.05)),
                          const SizedBox(height: 6),
                          Text(event.title,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            event.relativeName ?? event.eventTypeDisplay,
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelativesTab(BuildContext context, List<RelativeModel> relatives, bool isDark, Color mut, Color pri, Color priSoft) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          if (relatives.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text('Chưa có người thân nào', style: TextStyle(color: mut)))
          else
            ...relatives.map((rel) {
              final color = isDark
                  ? (AppColors.groupTypeColorsDark[rel.groupType] ?? AppColors.primaryDark)
                  : (AppColors.groupTypeColors[rel.groupType] ?? AppColors.primaryLight);
              final softColor = isDark
                  ? (AppColors.groupTypeSoftColorsDark[rel.groupType] ?? AppColors.primarySoftDark)
                  : (AppColors.groupTypeSoftColors[rel.groupType] ?? AppColors.primarySoftLight);
              // Dòng phụ: đếm ngược sinh nhật kèm emoji 🎂 (khớp thiết kế
              // exports/Screenshot 2026-09-02 194725.png) — người thân chưa
              // có ngày sinh thì hiện quan hệ thay thế để dòng không trống.
              final days = rel.daysUntilBirthday;
              final String subtitle = days == null
                  ? rel.groupTypeDisplay
                  : days == 0
                      ? '🎂 Sinh nhật hôm nay!'
                      : days == 1
                          ? '🎂 Sinh nhật ngày mai'
                          : '🎂 Sinh nhật còn $days ngày';
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: CardRow(
                  onTap: () => context.push('/relatives/${rel.id}'),
                  centerContent: true,
                  leading: InitialsAvatar(name: rel.displayName, color: color, softColor: softColor, radius: 21, avatarUrl: rel.avatarUrl, emoji: rel.groupTypeEmoji),
                  title: rel.displayName,
                  // Chip quan hệ đứng ngay sát tên (titleSuffix), không đẩy
                  // ra rìa phải — khớp bố cục "Lan  Chị gái" trong thiết kế.
                  titleSuffix: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(6)),
                    child: Text(rel.groupTypeDisplay, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                  ),
                  meta: Text(subtitle, style: TextStyle(fontSize: 12, color: mut), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: days != null
                      ? Container(
                          width: 42,
                          height: 40,
                          decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(13)),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$days', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color, height: 1)),
                              Text('ngày', style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
                            ],
                          ),
                        )
                      : null,
                ),
              );
            }),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => context.push('/relatives/create'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(18), border: Border.all(color: pri.withValues(alpha: 0.4))),
              alignment: Alignment.center,
              child: Text('+ Thêm người thân', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: pri)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyEventsTab(BuildContext context, List<EventModel> events, bool isDark, Color mut, Color mint, Color mintSoft) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          if (events.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text('Chưa có sự kiện nào', style: TextStyle(color: mut)))
          else
            ...events.map((event) {
              final typeColor = event.categoryColorValue;
              final isNegative = event.daysUntil != null && event.daysUntil! < 0;
              final countColor = isNegative ? AppColors.error : mint;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: CardRow(
                  onTap: () => context.push('/events/${event.id}'),
                  leading: SquareIconBadge(icon: event.eventTypeIcon, color: typeColor, background: typeColor.withValues(alpha: 0.15)),
                  title: event.title,
                  meta: Row(
                    children: [
                      Text(_formatDate(event.eventDate), style: TextStyle(fontSize: 12, color: mut)),
                      if (event.isRecurring) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.neutralSoftDark : AppColors.neutralSoftLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('↻', style: TextStyle(fontSize: 11, color: mut)),
                        ),
                      ],
                    ],
                  ),
                  trailing: event.daysUntil != null
                      ? Text(event.daysUntilText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: countColor))
                      : null,
                ),
              );
            }),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => context.push('/events/new'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: mintSoft, borderRadius: BorderRadius.circular(18), border: Border.all(color: mint.withValues(alpha: 0.4))),
              alignment: Alignment.center,
              child: Text('+ Thêm sự kiện của tôi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: mint)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
