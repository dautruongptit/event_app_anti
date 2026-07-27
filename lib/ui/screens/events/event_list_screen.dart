import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/event_provider.dart';
import '../../../models/event.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text('Sự kiện', style: AppTextStyles.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              // Show filter dialog or bottom sheet
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(context, isDark, eventProvider),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<EventProvider>().loadEvents(),
              child: eventProvider.isLoading && eventProvider.events.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : eventProvider.events.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: eventProvider.events.length,
                          itemBuilder: (context, index) {
                            final event = eventProvider.events[index];
                            return _buildEventCard(context, event, isDark, index);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/events/create'),
        backgroundColor: AppColors.primaryLight,
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(delay: 400.ms),
    );
  }

  Widget _buildFilterChips(BuildContext context, bool isDark, EventProvider provider) {
    final types = {
      'Tất cả': null,
      'Sinh nhật': 'SINH_NHAT',
      'Kỷ niệm': 'KY_NIEM',
      'Lễ': 'LE',
      'Khác': 'KHAC',
    };

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final entry = types.entries.elementAt(index);
          final isSelected = provider.filterType == entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                entry.key,
                style: AppTextStyles.body.copyWith(
                  color: isSelected 
                      ? Colors.white 
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.setFilter(type: entry.value);
                } else if (entry.value != null) {
                  provider.clearFilters();
                }
              },
              backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              selectedColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.black12),
                ),
              ),
            ),
          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, bool isDark, int index) {
    final color = AppColors.eventTypeColors[event.eventType] ?? AppColors.primaryLight;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 8, color: color),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.go('/events/${event.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(event.eventTypeIcon, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: AppTextStyles.heading3.copyWith(
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.textSecondaryLight),
                              const SizedBox(width: 6),
                              Text(
                                '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                                style: AppTextStyles.body.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              if (event.eventTime != null) ...[
                                const SizedBox(width: 16),
                                Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondaryLight),
                                const SizedBox(width: 6),
                                Text(
                                  event.eventTime!,
                                  style: AppTextStyles.body.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (event.relativeName != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person_rounded, size: 16, color: AppColors.textSecondaryLight),
                                const SizedBox(width: 6),
                                Text(
                                  event.relativeName!,
                                  style: AppTextStyles.body.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 80,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          ).animate().scale(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            'Chưa có sự kiện nào',
            style: AppTextStyles.heading3.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Hãy nhấn nút + để tạo sự kiện mới',
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
