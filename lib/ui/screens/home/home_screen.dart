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
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeData = homeProvider.homeData;
    final userName = homeData?.userName ?? user?.fullName ?? 'Khách';

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.surfaceLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeProvider>().refresh(),
          child: homeProvider.isLoading && homeData == null
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(userName, isDark),
                    ),
                    if (homeData != null && homeData.upcomingEvents.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildUpcomingEventsSection(homeData.upcomingEvents, isDark),
                      ),
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
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_rounded, color: AppColors.surfaceLight, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, $userName 👋',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nhắc Sự Kiện',
                    style: AppTextStyles.heading3.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                size: 24,
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondaryLight,
                child: Text('😊', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection(List<EventModel> events, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔔 Sự kiện sắp tới',
                style: AppTextStyles.subtitle.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/events'),
                child: Text(
                  'Xem tất cả >',
                  style: AppTextStyles.label.copyWith(color: AppColors.primaryLight),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final days = event.daysUntil ?? 0;
              final daysText = days == 0 ? 'Hôm nay' : (days == 1 ? 'Ngày mai' : '$days ngày nữa');

              return GestureDetector(
                onTap: () => context.push('/events/${event.id}'),
                child: Container(
                  width: 190,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(event.eventTypeIcon, color: AppColors.surfaceLight, size: 16),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            daysText,
                            style: AppTextStyles.heading3.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.title,
                            style: AppTextStyles.body.copyWith(color: AppColors.surfaceLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (event.relativeName != null || event.eventTypeDisplay.isNotEmpty)
                            Text(
                              event.relativeName ?? event.eventTypeDisplay,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.surfaceLight.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1),
              );
            },
          ),
        ),
      ],
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
                  ? AppColors.primaryLight
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
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
    if (relatives.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Chưa có người thân nào',
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...relatives.asMap().entries.map((entry) {
          final index = entry.key;
          final rel = entry.value;
          final initial = rel.name.isNotEmpty ? rel.name[0].toUpperCase() : '?';
          final avatarColor = AppColors.groupTypeColors[rel.groupType] ?? AppColors.primaryLight;
          
          return GestureDetector(
            onTap: () => context.push('/relatives/${rel.id}'),
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.surfaceDark : const Color(0xFFE0E0E0),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarColor.withValues(alpha: 0.2),
                    child: Text(
                      initial,
                      style: AppTextStyles.heading3.copyWith(color: avatarColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rel.displayName,
                          style: AppTextStyles.subtitle.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primaryLight),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                rel.groupTypeDisplay,
                                style: AppTextStyles.caption.copyWith(color: AppColors.primaryLight),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (rel.daysUntilBirthday != null)
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.cake_rounded, color: AppColors.primaryLight, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Sinh nhật còn ${rel.daysUntilBirthday} ngày',
                                        style: AppTextStyles.caption.copyWith(color: AppColors.primaryLight),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (rel.daysUntilBirthday != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${rel.daysUntilBirthday}',
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.secondaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ngày',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.05),
          );
        }),
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
          ...events.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final typeColor = AppColors.eventTypeColors[event.eventType] ?? AppColors.secondaryLight;
            final isNegative = event.daysUntil != null && event.daysUntil! < 0;
            final countColor = isNegative ? AppColors.error : AppColors.secondaryLight;

            return GestureDetector(
              onTap: () => context.push('/events/${event.id}'),
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.surfaceDark : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(event.eventTypeIcon, color: typeColor),
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF9E9E9E)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  event.eventTypeDisplay,
                                  style: AppTextStyles.caption.copyWith(color: const Color(0xFF9E9E9E)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${event.eventDate.day.toString().padLeft(2, '0')}/${event.eventDate.month.toString().padLeft(2, '0')}/${event.eventDate.year}',
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
                    if (event.daysUntil != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${event.daysUntil}',
                              style: AppTextStyles.heading2.copyWith(
                                color: countColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ngày',
                              style: AppTextStyles.caption.copyWith(
                                color: countColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.05),
            );
          }),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton(
            onPressed: () => context.push('/events/new'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              side: const BorderSide(color: AppColors.primaryLight, style: BorderStyle.solid),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 20),
                const SizedBox(width: 8),
                Text('Thêm sự kiện', style: AppTextStyles.button),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
