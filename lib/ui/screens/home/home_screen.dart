import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/home_provider.dart';
import 'package:event_app/providers/auth_provider.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/models/relative.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final user = context.read<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeData = homeProvider.homeData;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeProvider>().refresh(),
          child: homeProvider.isLoading && homeData == null
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(
                        context,
                        homeData?.userName ?? user?.fullName ?? 'Khách',
                        homeData?.avatarUrl ?? user?.avatarUrl,
                        isDark,
                      ),
                    ),
                    if (homeData != null && homeData.googleCalendarConnected != true)
                      SliverToBoxAdapter(
                        child: _buildGoogleCalendarBanner(isDark),
                      ),
                    if (homeData != null && homeData.upcomingEvents.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _buildUpcomingSectionHeader(isDark),
                      ),
                      SliverToBoxAdapter(
                        child: _buildUpcomingEvents(homeData.upcomingEvents, isDark),
                      ),
                    ],
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                    SliverToBoxAdapter(
                      child: _buildTabs(isDark),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),
                    SliverToBoxAdapter(
                      child: _selectedTab == 0
                          ? _buildRelativesTab(homeData?.relatives ?? [], isDark)
                          : _buildMyEventsTab(homeProvider.myEvents, isDark),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, String? avatarUrl, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Xin chào, $userName 👋',
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Nhắc Sự Kiện',
                style: AppTextStyles.heading1.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                onPressed: () {},
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: AppColors.primaryLight)
                    : null,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGoogleCalendarBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppColors.primaryLight, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kết nối Google Calendar',
                  style: AppTextStyles.subtitle.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Đồng bộ sự kiện tự động',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Text('Kết nối', style: AppTextStyles.label.copyWith(color: Colors.white)),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildUpcomingSectionHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '🔥 Sự kiện sắp tới',
            style: AppTextStyles.heading2.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Xem tất cả >',
              style: AppTextStyles.label.copyWith(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(List<EventModel> events, bool isDark) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final baseColor = AppColors.eventTypeColors[event.eventType] ?? AppColors.primaryLight;
          final gradient = LinearGradient(
            colors: [baseColor, baseColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          
          return GestureDetector(
            onTap: () => context.go('/events/${event.id}'),
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.daysUntilText.isEmpty ? 'Sắp tới' : event.daysUntilText,
                          style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(event.eventTypeIcon, color: Colors.white, size: 20),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    event.title,
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (event.relativeName != null)
                    Text(
                      event.relativeName!,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1),
          );
        },
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabItem('Người thân', 0, isDark),
          const SizedBox(width: 24),
          _buildTabItem('Sự kiện của tôi', 1, isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.subtitle.copyWith(
              color: isSelected
                  ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 32,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelativesTab(List<RelativeModel> relatives, bool isDark) {
    return Column(
      children: [
        if (relatives.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Chưa có người thân nào',
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          )
        else
          ...relatives.map((rel) {
            final color = AppColors.groupTypeColors[rel.groupType] ?? AppColors.primaryLight;
            return GestureDetector(
              onTap: () => context.go('/relatives/${rel.id}'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color.withValues(alpha: 0.2),
                      backgroundImage: rel.avatarUrl != null ? NetworkImage(rel.avatarUrl!) : null,
                      child: rel.avatarUrl == null ? Icon(Icons.person, color: color) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  rel.displayName,
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  rel.groupTypeDisplay,
                                  style: AppTextStyles.caption.copyWith(color: color),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rel.birthdayText,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (rel.daysUntilBirthday != null && rel.daysUntilBirthday! >= 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              rel.daysUntilBirthday.toString(),
                              style: AppTextStyles.subtitle.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ngày',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryLight,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
            );
          }),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => context.go('/relatives/create'),
          icon: const Icon(Icons.add, color: AppColors.primaryLight),
          label: Text('Thêm người thân', style: AppTextStyles.button.copyWith(color: AppColors.primaryLight)),
        ),
      ],
    );
  }

  Widget _buildMyEventsTab(List<EventModel> events, bool isDark) {
    return Column(
      children: [
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Chưa có sự kiện nào',
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          )
        else
          ...events.map((event) {
            final color = AppColors.eventTypeColors[event.eventType] ?? AppColors.primaryLight;
            return GestureDetector(
              onTap: () => context.go('/events/${event.id}'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.1),
                      ),
                      child: Icon(event.eventTypeIcon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: AppTextStyles.subtitle.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.eventTypeDisplay,
                                  style: AppTextStyles.caption.copyWith(color: color),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (event.daysUntil != null && event.daysUntil! >= 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              event.daysUntil.toString(),
                              style: AppTextStyles.subtitle.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ngày',
                              style: AppTextStyles.caption.copyWith(
                                color: color,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
            );
          }),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => context.go('/events/create'),
          icon: const Icon(Icons.add, color: AppColors.primaryLight),
          label: Text('Thêm sự kiện', style: AppTextStyles.button.copyWith(color: AppColors.primaryLight)),
        ),
      ],
    );
  }
}
