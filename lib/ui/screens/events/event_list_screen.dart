import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/core/utils/date_utils.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final List<Map<String, String>> _filters = [
    {'label': 'Tất cả', 'value': 'ALL'},
    {'label': 'Sinh nhật', 'value': 'SINH_NHAT'},
    {'label': 'Kỷ niệm', 'value': 'KY_NIEM'},
    {'label': 'Lễ', 'value': 'LE'},
    {'label': 'Nhà ở', 'value': 'NHA_O'},
    {'label': 'Hoá đơn', 'value': 'HOA_DON'},
    {'label': 'Mua sắm', 'value': 'MUA_SAM'},
  ];

  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  IconData _getIconForFilter(String value) {
    switch (value) {
      case 'ALL':
        return Icons.all_inclusive_rounded;
      case 'SINH_NHAT':
        return Icons.cake_rounded;
      case 'KY_NIEM':
        return Icons.favorite_rounded;
      case 'LE':
        return Icons.celebration_rounded;
      case 'NHA_O':
        return Icons.home_rounded;
      case 'HOA_DON':
        return Icons.receipt_long_rounded;
      case 'MUA_SAM':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  void _onFilterChanged(String value) {
    setState(() {
      _selectedFilter = value;
    });
    if (value == 'ALL') {
      context.read<EventProvider>().clearFilters();
    } else {
      context.read<EventProvider>().setFilter(type: value);
    }
  }

  Map<String, List<EventModel>> _groupEventsByMonth(List<EventModel> events) {
    final Map<String, List<EventModel>> grouped = {};
    for (var event in events) {
      final monthYear = 'Tháng ${event.eventDate.month}, ${event.eventDate.year}';
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(event);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final isLoading = provider.isLoading;
    final events = provider.events;
    final groupedEvents = _groupEventsByMonth(events);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          _buildHeader(),
          _buildMonthSlider(),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentLight,
                    ),
                  )
                : events.isEmpty
                    ? _buildEmptyState()
                    : _buildEventList(groupedEvents),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/events/create');
        },
        backgroundColor: AppColors.accentLight,
        child: const Icon(Icons.add_rounded, color: AppColors.surfaceLight),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
          decoration: const BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sự kiện',
                    style: AppTextStyles.heading1.copyWith(color: AppColors.surfaceLight),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý và theo dõi',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.surfaceLight.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: AppColors.surfaceLight,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -20,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['value'];
                return GestureDetector(
                  onTap: () => _onFilterChanged(filter['value']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceLight
                          : AppColors.surfaceLight.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.textPrimaryLight.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForFilter(filter['value']!),
                          size: 16,
                          color: isSelected
                              ? AppColors.accentLight
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filter['label']!,
                          style: AppTextStyles.label.copyWith(
                            color: isSelected
                                ? AppColors.accentLight
                                : AppColors.textSecondaryLight,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSlider() {
    final progress = DateTime.now().month / 12;
    return Container(
      margin: const EdgeInsets.only(top: 40, bottom: 16, left: 24, right: 24),
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildEventList(Map<String, List<EventModel>> groupedEvents) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        final monthKey = groupedEvents.keys.elementAt(index);
        final eventsInMonth = groupedEvents[monthKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                monthKey,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            ...eventsInMonth.map((event) => _buildEventCard(event)).toList(),
          ],
        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    final Color iconColor = AppColors.eventTypeColors[event.eventType] ?? AppColors.accentLight;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimaryLight.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              event.eventTypeIcon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (event.relativeName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.relativeName!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppDateUtils.formatDate(event.eventDate),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    if (event.eventTime != null && event.eventTime!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppDateUtils.formatTime(event.eventTime),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textSecondaryLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.pushNamed(context, '/events/edit', arguments: event.id);
              } else if (value == 'delete') {
                _confirmDelete(event);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20, color: AppColors.textPrimaryLight),
                    const SizedBox(width: 8),
                    Text('Chỉnh sửa', style: AppTextStyles.body),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_rounded, size: 20, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('Xóa', style: AppTextStyles.body.copyWith(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Không có sự kiện nào',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm sự kiện để bắt đầu theo dõi',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Future<void> _confirmDelete(EventModel event) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa sự kiện', style: AppTextStyles.heading2),
        content: Text(
          'Bạn có chắc chắn muốn xóa sự kiện "${event.title}" không?',
          style: AppTextStyles.body,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: AppTextStyles.button.copyWith(color: AppColors.textSecondaryLight),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Xóa',
              style: AppTextStyles.button.copyWith(color: AppColors.surfaceLight),
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await context.read<EventProvider>().deleteEvent(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa sự kiện', style: AppTextStyles.body.copyWith(color: AppColors.surfaceLight)),
            backgroundColor: AppColors.textPrimaryLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
