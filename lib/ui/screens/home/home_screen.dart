import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/event.dart';
import '../../../models/relative.dart';
import '../../../core/utils/date_utils.dart'; // assuming exists, maybe not, let's omit if not sure

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeProvider>().refresh(),
          child: homeProvider.isLoading && homeProvider.homeData == null
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(
                        context,
                        homeProvider.homeData?.userName ?? user?.fullName ?? 'Khách',
                        homeProvider.homeData?.avatarUrl ?? user?.avatarUrl,
                        isDark,
                      ),
                    ),
                    if (homeProvider.homeData?.upcomingEvents.isNotEmpty == true)
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('Sự kiện sắp tới', isDark),
                      ),
                    if (homeProvider.homeData?.upcomingEvents.isNotEmpty == true)
                      SliverToBoxAdapter(
                        child: _buildUpcomingEvents(
                          context,
                          homeProvider.homeData!.upcomingEvents,
                          isDark,
                        ),
                      ),
                    if (homeProvider.homeData?.relatives.isNotEmpty == true)
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('Người thân', isDark),
                      ),
                    if (homeProvider.homeData?.relatives.isNotEmpty == true)
                      SliverToBoxAdapter(
                        child: _buildRelatives(
                          context,
                          homeProvider.homeData!.relatives,
                          isDark,
                        ),
                      ),
                    if (homeProvider.myEvents.isNotEmpty == true)
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('Sự kiện của tôi', isDark),
                      ),
                    if (homeProvider.myEvents.isNotEmpty == true)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildMyEventCard(
                                context,
                                homeProvider.myEvents[index],
                                isDark,
                                index,
                              );
                            },
                            childCount: homeProvider.myEvents.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/events/create'),
        backgroundColor: AppColors.primaryLight,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Thêm sự kiện', style: AppTextStyles.button.copyWith(color: Colors.white)),
      ).animate().scale(delay: 500.ms),
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
              Text(
                'Xin chào,',
                style: AppTextStyles.subtitle.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
              const SizedBox(height: 4),
              Text(
                userName,
                style: AppTextStyles.heading2.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.2),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: AppColors.primaryLight)
                : null,
          ).animate().scale(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context, List<EventModel> events, bool isDark) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final color = AppColors.eventTypeColors[event.eventType] ?? AppColors.primaryLight;
          
          return Container(
            width: 280,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.go('/events/${event.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(event.eventTypeIcon, color: color, size: 24),
                          ),
                          const Spacer(),
                          if (event.daysUntilText.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                event.daysUntilText,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        event.title,
                        style: AppTextStyles.heading3.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondaryLight),
                          const SizedBox(width: 4),
                          Text(
                            '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          if (event.relativeName != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.person, size: 14, color: AppColors.textSecondaryLight),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.relativeName!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildRelatives(BuildContext context, List<RelativeModel> relatives, bool isDark) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: relatives.length,
        itemBuilder: (context, index) {
          final relative = relatives[index];
          final color = AppColors.groupTypeColors[relative.groupType] ?? AppColors.primaryLight;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => context.go('/relatives/${relative.id}'),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                      image: relative.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(relative.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    ),
                    child: relative.avatarUrl == null
                        ? Icon(Icons.person, color: color, size: 32)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    relative.nickname ?? relative.name.split(' ').last,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (200 + index * 50).ms).scale(),
          );
        },
      ),
    );
  }

  Widget _buildMyEventCard(BuildContext context, EventModel event, bool isDark, int index) {
    final color = AppColors.eventTypeColors[event.eventType] ?? AppColors.primaryLight;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.go('/events/${event.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(event.eventTypeIcon, color: color),
                          ),
                          const SizedBox(width: 16),
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
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (event.daysUntilText.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                event.daysUntilText,
                                style: AppTextStyles.caption.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (300 + index * 50).ms).slideY(begin: 0.1);
  }
}
