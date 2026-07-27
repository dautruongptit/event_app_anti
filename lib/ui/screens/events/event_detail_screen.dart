import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/core/utils/date_utils.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/models/event.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEventById(widget.eventId);
    });
  }

  void _confirmDelete(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await context.read<EventProvider>().deleteEvent(event.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xoá sự kiện')),
                );
                context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final event = eventProvider.selectedEvent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (eventProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Không tìm thấy sự kiện', style: AppTextStyles.body),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<EventProvider>().loadEventById(widget.eventId),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final eventColor = AppColors.eventTypeColors[event.eventType] ?? Colors.grey;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => context.push('/events/${event.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded),
                onPressed: () => _confirmDelete(context, event),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [eventColor, eventColor.withValues(alpha: 0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(event.eventTypeIcon, size: 64, color: Colors.white)
                          .animate()
                          .scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 8),
                      Text(
                        event.eventTypeDisplay,
                        style: AppTextStyles.subtitle.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title
                Text(event.title, style: AppTextStyles.heading1)
                    .animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
                const SizedBox(height: 20),

                // Date, Time & Countdown Row
                _buildInfoRow(event, eventColor, isDark),
                const SizedBox(height: 20),

                // Recurring badge
                if (event.isRecurring)
                  _buildRecurringBadge(event).animate().fadeIn(delay: 150.ms),
                if (event.isRecurring) const SizedBox(height: 20),

                // Relative info
                if (event.relativeName != null) ...[
                  Text('Liên quan đến', style: AppTextStyles.heading3)
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  _buildRelativeCard(event, isDark)
                      .animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                ],

                // Reminders
                if (event.reminders.isNotEmpty) ...[
                  Text('Lời nhắc', style: AppTextStyles.heading3)
                      .animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 8),
                  _buildReminders(event, eventColor)
                      .animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                ],

                // Notes
                if (event.notes != null && event.notes!.isNotEmpty) ...[
                  Text('Ghi chú', style: AppTextStyles.heading3)
                      .animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 8),
                  _buildNotesCard(event, isDark)
                      .animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(EventModel event, Color eventColor, bool isDark) {
    return Row(
      children: [
        // Date chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: eventColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded, color: eventColor, size: 18),
              const SizedBox(width: 6),
              Text(
                AppDateUtils.formatDate(event.eventDate),
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: eventColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Time chip
        if (event.eventTime != null && event.eventTime!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, size: 18,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                const SizedBox(width: 6),
                Text(AppDateUtils.formatTime(event.eventTime), style: AppTextStyles.label),
              ],
            ),
          ),
        const Spacer(),
        // Countdown badge
        if (event.daysUntilText.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: event.daysUntil == 0
                  ? AppColors.accentGradient
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event.daysUntilText,
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
          ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildRecurringBadge(EventModel event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.repeat_rounded, color: AppColors.secondaryLight, size: 18),
          const SizedBox(width: 8),
          Text(
            'Lặp lại: ${event.recurrenceType ?? "Định kỳ"}',
            style: AppTextStyles.label.copyWith(color: AppColors.secondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildRelativeCard(EventModel event, bool isDark) {
    final groupColor = AppColors.groupTypeColors[event.relativeGroupType] ?? AppColors.primaryLight;
    return Card(
      elevation: 0,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: groupColor,
          child: Text(
            (event.relativeName ?? '?')[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(event.relativeName ?? '', style: AppTextStyles.subtitle),
        subtitle: event.relativeGroupType != null
            ? Text(event.relativeGroupType!, style: AppTextStyles.bodySmall)
            : null,
        trailing: Icon(Icons.chevron_right_rounded,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      ),
    );
  }

  Widget _buildReminders(EventModel event, Color eventColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: event.reminders.map((reminder) {
        return Chip(
          avatar: Icon(Icons.notifications_active_rounded, size: 16, color: eventColor),
          label: Text(reminder.displayText),
          backgroundColor: eventColor.withValues(alpha: 0.1),
          side: BorderSide(color: eventColor.withValues(alpha: 0.2)),
        );
      }).toList(),
    );
  }

  Widget _buildNotesCard(EventModel event, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Text(event.notes!, style: AppTextStyles.body),
    );
  }
}
