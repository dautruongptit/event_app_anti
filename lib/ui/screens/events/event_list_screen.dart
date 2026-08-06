import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/core/utils/date_utils.dart';
import 'package:event_app/ui/screens/events/event_form_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  void _onMonthSelected(int? month) {
    setState(() {
      _selectedMonth = month;
    });
    context.read<EventProvider>().setFilter(month: month);
  }

  void _deleteEvent(BuildContext context, int eventId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xóa', style: AppTextStyles.heading3),
        content: Text('Bạn có chắc chắn muốn xóa sự kiện này không?',
            style: AppTextStyles.body),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: AppTextStyles.button.copyWith(color: AppColors.textSecondaryLight)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<EventProvider>().deleteEvent(eventId);
            },
            child: Text('Xóa', style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final allEvents = provider.events;
    
    // Extract months for the filter chips
    final availableMonths = allEvents
        .map((e) => e.eventDate.month)
        .toSet()
        .toList()
      ..sort();

    // Group events by month/year for display
    final groupedEvents = <String, List<EventModel>>{};
    for (var event in allEvents) {
      final key = 'Tháng ${event.eventDate.month}, ${event.eventDate.year}';
      if (groupedEvents.containsKey(key)) {
        groupedEvents[key]!.add(event);
      } else {
        groupedEvents[key] = [event];
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          // Gradient Header
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                        color: AppColors.surfaceLight.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Filter Chips
          if (availableMonths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    _buildFilterChip(
                      label: 'Tất cả',
                      isSelected: _selectedMonth == null,
                      onTap: () => _onMonthSelected(null),
                    ),
                    ...availableMonths.map((month) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: _buildFilterChip(
                          label: 'Tháng $month',
                          isSelected: _selectedMonth == month,
                          onTap: () => _onMonthSelected(month),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // Events List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
                : allEvents.isEmpty
                    ? Center(
                        child: Text(
                          'Không có sự kiện nào',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondaryLight),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        itemCount: groupedEvents.keys.length,
                        itemBuilder: (context, index) {
                          final key = groupedEvents.keys.elementAt(index);
                          final monthEvents = groupedEvents[key]!;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  key,
                                  style: AppTextStyles.heading3.copyWith(
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                              ...monthEvents.map((event) {
                                return _buildEventCard(context, event)
                                    .animate()
                                    .fade(duration: 300.ms)
                                    .slideY(begin: 0.1, end: 0, duration: 300.ms);
                              }),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.textSecondaryLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? AppColors.surfaceLight : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    Color iconBg;
    switch (event.eventType) {
      case 'SINH_NHAT':
      case 'KY_NIEM':
        iconBg = AppColors.iconBgPink;
        break;
      case 'NHA_O':
      case 'MUA_SAM':
        iconBg = AppColors.iconBgTeal;
        break;
      case 'HOA_DON':
        iconBg = AppColors.iconBgYellow;
        break;
      default:
        iconBg = AppColors.bgLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              event.eventTypeIcon,
              color: AppColors.eventTypeColors[event.eventType] ?? AppColors.textSecondaryLight,
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                if (event.relativeName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.relativeName!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(
                      AppDateUtils.formatDate(event.eventDate),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight),
                    ),
                    if (event.eventTime != null && event.eventTime!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text(
                        AppDateUtils.formatTime(event.eventTime),
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondaryLight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppColors.surfaceLight,
            elevation: 4,
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventFormScreen(
                      isRelativeEvent: event.relativeId != null,
                      eventId: event.id,
                    ),
                  ),
                );
              } else if (value == 'delete') {
                _deleteEvent(context, event.id);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 12),
                    Text('Chỉnh sửa', style: AppTextStyles.body),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                    const SizedBox(width: 12),
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
}
