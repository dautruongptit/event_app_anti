import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/providers/relative_provider.dart';


class EventFormScreen extends StatefulWidget {
  final bool isRelativeEvent;
  final int? eventId;

  const EventFormScreen({
    super.key,
    this.isRelativeEvent = true,
    this.eventId,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedRelativeId;
  String? _selectedRelativeName;
  int _selectedCategoryId = 1;
  String _selectedCategory = 'Sinh nhật';
  String _selectedCategoryKey = 'SINH_NHAT';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  bool _isAllDay = false;
  String _repeatMode = 'Không lặp';
  String _repeatKey = 'NONE';
  
  int _lunarDay = 1;
  int _lunarMonth = 1;

  int _customIntervalValue = 1;
  String _customIntervalUnit = 'WEEK';

  // Nhắc nhở as list of reminder objects
  final List<_ReminderItem> _reminders = [
    _ReminderItem(label: '7 ngày trước', daysBefore: 7),
    _ReminderItem(label: '3 ngày trước', daysBefore: 3),
    _ReminderItem(label: '1 ngày trước', daysBefore: 1),
    _ReminderItem(label: '1 giờ trước', hoursBefore: 1),
  ];

  // Danh mục list — from DB seed
  static const List<_CategoryItem> _categories = [
    _CategoryItem(id: 1, key: 'SINH_NHAT', label: 'Sinh nhật', icon: Icons.cake, color: Color(0xFFFF6B6B)),
    _CategoryItem(id: 2, key: 'KY_NIEM', label: 'Kỷ niệm', icon: Icons.favorite, color: Color(0xFF9B59B6)),
    _CategoryItem(id: 3, key: 'LE', label: 'Lễ/Tết', icon: Icons.card_giftcard, color: Color(0xFFF5A623)),
    _CategoryItem(id: 4, key: 'NHA_O', label: 'Nhà ở', icon: Icons.home, color: Color(0xFFF48FB1)),
    _CategoryItem(id: 5, key: 'HOA_DON', label: 'Hóa đơn', icon: Icons.bolt, color: Color(0xFFF5C518)),
    _CategoryItem(id: 6, key: 'MUA_SAM', label: 'Mua sắm', icon: Icons.shopping_bag, color: Color(0xFF1ABC9C)),
    _CategoryItem(id: 7, key: 'KHAC', label: 'Khác', icon: Icons.more_horiz, color: Color(0xFF95A5A6)),
  ];

  static const List<_RepeatOption> _repeatOptions = [
    _RepeatOption(key: 'NONE', label: 'Không lặp'),
    _RepeatOption(key: 'HOURLY', label: 'Mỗi giờ'),
    _RepeatOption(key: 'DAILY', label: 'Hàng ngày'),
    _RepeatOption(key: 'WEEKLY', label: 'Hàng tuần'),
    _RepeatOption(key: 'MONTHLY', label: 'Hàng tháng'),
    _RepeatOption(key: 'YEARLY', label: 'Hàng năm'),
    _RepeatOption(key: 'LUNAR_YEARLY', label: 'Hàng năm (Âm lịch)'),
    _RepeatOption(key: 'CUSTOM', label: 'Tùy chỉnh'),
  ];

  static const List<_CustomUnitOption> _customUnitOptions = [
    _CustomUnitOption(key: 'HOUR', label: 'Giờ'),
    _CustomUnitOption(key: 'DAY', label: 'Ngày'),
    _CustomUnitOption(key: 'WEEK', label: 'Tuần'),
    _CustomUnitOption(key: 'MONTH', label: 'Tháng'),
    _CustomUnitOption(key: 'YEAR', label: 'Năm'),
  ];

  static const List<_ReminderOption> _reminderOptions = [
    _ReminderOption(label: '7 ngày trước', daysBefore: 7),
    _ReminderOption(label: '3 ngày trước', daysBefore: 3),
    _ReminderOption(label: '1 ngày trước', daysBefore: 1),
    _ReminderOption(label: '1 giờ trước', hoursBefore: 1),
    _ReminderOption(label: '30 phút trước', hoursBefore: 0, minutesBefore: 30),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelativeProvider>().loadRelatives();
      if (widget.eventId != null) {
        _loadExistingEvent();
      }
    });
  }

  Future<void> _loadExistingEvent() async {
    final provider = context.read<EventProvider>();
    await provider.loadEventById(widget.eventId!);
    final event = provider.selectedEvent;
    if (event != null) {
      setState(() {
        _titleController.text = event.title;
        _selectedRelativeId = event.relativeId;
        _selectedDate = event.eventDate;
        if (event.eventTime != null && event.eventTime!.isNotEmpty) {
          final parts = event.eventTime!.split(':');
          _selectedTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
        if (event.isRecurring) {
          _repeatMode = 'Hàng năm';
          _repeatKey = 'YEARLY'; // TODO: match correct type from event
        }
        
        // Match category from list if possible
        if (event.categoryId != null) {
          try {
            final cat = _categories.firstWhere((c) => c.id == event.categoryId);
            _selectedCategoryId = cat.id;
            _selectedCategory = cat.label;
            _selectedCategoryKey = cat.key;
          } catch (_) {}
        }

        _reminders.clear();
        for (var r in event.reminders) {
          if (r.remindDaysBefore == 7 && r.isEnabled) {
            _reminders.add(_ReminderItem(label: '7 ngày trước', daysBefore: 7));
          }
          if (r.remindDaysBefore == 3 && r.isEnabled) {
            _reminders.add(_ReminderItem(label: '3 ngày trước', daysBefore: 3));
          }
          if (r.remindDaysBefore == 1 && r.isEnabled) {
            _reminders.add(_ReminderItem(label: '1 ngày trước', daysBefore: 1));
          }
          if (r.remindHoursBefore == 1 && r.isEnabled) {
            _reminders.add(_ReminderItem(label: '1 giờ trước', hoursBefore: 1));
          }
        }
        
        _notesController.text = event.notes ?? '';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryLight),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryLight),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _showRepeatSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lặp lại',
                      style: AppTextStyles.heading3.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              ..._repeatOptions.map((option) {
                final isSelected = _repeatKey == option.key;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(
                    option.label,
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primaryLight, size: 22)
                      : null,
                  onTap: () {
                    setState(() {
                      _repeatKey = option.key;
                      _repeatMode = option.label;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showRelativePicker() async {
    final relatives = context.read<RelativeProvider>().relatives;
    if (relatives.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có người thân nào. Hãy thêm người thân trước.')),
      );
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                child: Text(
                  'Chọn người thân',
                  style: AppTextStyles.heading3.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...relatives.map((r) {
                final isSelected = _selectedRelativeId == r.id;
                final initial = r.displayName.isNotEmpty ? r.displayName[0].toUpperCase() : '?';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                    child: Text(initial, style: AppTextStyles.subtitle.copyWith(color: AppColors.primaryLight)),
                  ),
                  title: Text(
                    r.displayName,
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primaryLight, size: 22)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedRelativeId = r.id;
                      _selectedRelativeName = r.displayName;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryPicker() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await Navigator.push<_CategoryItem>(
      context,
      MaterialPageRoute(
        builder: (_) => _CategoryPickerScreen(
          categories: _categories,
          selectedKey: _selectedCategoryKey,
          isDark: isDark,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategoryId = result.id;
        _selectedCategory = result.label;
        _selectedCategoryKey = result.key;
      });
    }
  }

  void _showAddReminderSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Filter out already-added reminders
    final existingLabels = _reminders.map((r) => r.label).toSet();
    final available = _reminderOptions.where((o) => !existingLabels.contains(o.label)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm tất cả nhắc nhở')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                child: Text(
                  'Thêm nhắc nhở',
                  style: AppTextStyles.heading3.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...available.map((option) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.notifications_none, color: AppColors.primaryLight),
                  title: Text(
                    option.label,
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _reminders.add(_ReminderItem(
                        label: option.label,
                        daysBefore: option.daysBefore,
                        hoursBefore: option.hoursBefore,
                      ));
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _saveEvent() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên sự kiện')),
      );
      return;
    }

    final reminders = <Map<String, dynamic>>[];
    for (var r in _reminders) {
      if (r.daysBefore != null && r.daysBefore! > 0) {
        reminders.add({'remindDaysBefore': r.daysBefore, 'isEnabled': true});
      }
      if (r.hoursBefore != null && r.hoursBefore! > 0) {
        reminders.add({'remindHoursBefore': r.hoursBefore, 'isEnabled': true});
      }
    }

    final data = {
      'title': _titleController.text.trim(),
      'categoryId': _selectedCategoryId,
      'eventDate': _selectedDate.toIso8601String().split('T').first,
      'eventTime': (!_isAllDay && _selectedTime != null)
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'isRecurring': _repeatKey != 'NONE',
      if (_repeatKey != 'NONE') 'recurrenceType': _repeatKey,
      if (_repeatKey == 'LUNAR_YEARLY') 'lunarDay': _lunarDay,
      if (_repeatKey == 'LUNAR_YEARLY') 'lunarMonth': _lunarMonth,
      if (_repeatKey == 'CUSTOM') 'customIntervalValue': _customIntervalValue,
      if (_repeatKey == 'CUSTOM') 'customIntervalUnit': _customIntervalUnit,
      'notes': _notesController.text.trim(),
      'relativeId': _selectedRelativeId,
      'reminders': reminders,
    };

    final provider = context.read<EventProvider>();
    if (widget.eventId != null) {
      provider.updateEvent(widget.eventId!, data).then((success) {
        if (success && mounted) Navigator.pop(context);
      });
    } else {
      provider.createEvent(data).then((success) {
        if (success && mounted) Navigator.pop(context);
      });
    }
  }

  // ─── Format Helpers ──────────────────────

  String _formatDate(DateTime d) {
    const months = ['', 'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5', 'tháng 6',
      'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12'];
    return '${d.day} ${months[d.month]},\n${d.year}';
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  // ─── BUILD ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    final onSurface = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryLight, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 72,
        title: Text(
          'Thêm sự kiện',
          style: AppTextStyles.heading3.copyWith(color: onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: context.watch<EventProvider>().isLoading ? null : _saveEvent,
            child: Text(
              'Lưu',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title Field ──
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Nhập tên sự kiện',
                        hintStyle: AppTextStyles.body.copyWith(color: subText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      style: AppTextStyles.body.copyWith(color: onSurface),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
                  const SizedBox(height: 16),

                  // ── Người liên quan + Danh mục Card ──
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        // Người liên quan
                        InkWell(
                          onTap: _showRelativePicker,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, color: AppColors.primaryLight, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  'Người liên quan',
                                  style: AppTextStyles.body.copyWith(color: onSurface, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedRelativeName ?? 'Chọn người thân',
                                    style: AppTextStyles.bodySmall.copyWith(color: subText),
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: subText, size: 20),
                              ],
                            ),
                          ),
                        ),
                        Divider(height: 1, color: borderColor),
                        // Danh mục
                        InkWell(
                          onTap: _showCategoryPicker,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.label_outline, color: AppColors.primaryLight, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  'Danh mục',
                                  style: AppTextStyles.body.copyWith(color: onSurface, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedCategory,
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight),
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: subText, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.05),
                  const SizedBox(height: 16),

                  // ── Date / Time + All Day Card ──
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        // Date + Time row
                        Row(
                          children: [
                            // Date
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: _selectDate,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.iconBgTeal,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.secondaryLight),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Ngày', style: AppTextStyles.caption.copyWith(color: subText)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatDate(_selectedDate),
                                          style: AppTextStyles.body.copyWith(
                                            color: onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Time
                            if (!_isAllDay)
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: _selectTime,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.iconBgPink,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryLight),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Giờ', style: AppTextStyles.caption.copyWith(color: subText)),
                                          const SizedBox(height: 2),
                                          Text(
                                            _selectedTime != null ? _formatTime(_selectedTime!) : '--:--',
                                            style: AppTextStyles.body.copyWith(
                                              color: onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: borderColor),
                        const SizedBox(height: 8),
                        // Cả ngày toggle
                        Row(
                          children: [
                            Icon(Icons.wb_sunny_outlined, size: 20, color: subText),
                            const SizedBox(width: 12),
                            Text(
                              'Cả ngày',
                              style: AppTextStyles.body.copyWith(color: onSurface),
                            ),
                            const Spacer(),
                            Switch(
                              value: _isAllDay,
                              onChanged: (v) => setState(() => _isAllDay = v),
                              activeColor: AppColors.primaryLight,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.05),
                  const SizedBox(height: 16),

                  // ── Lặp lại Row ──
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: InkWell(
                      onTap: _showRepeatSheet,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(Icons.repeat_rounded, size: 22, color: subText),
                            const SizedBox(width: 12),
                            Text(
                              'Lặp lại',
                              style: AppTextStyles.body.copyWith(color: onSurface, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Flexible(
                              child: Text(
                                _repeatMode,
                                style: AppTextStyles.bodySmall.copyWith(color: subText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, color: subText, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideY(begin: 0.05),
                  const SizedBox(height: 16),

                  if (_repeatKey == 'LUNAR_YEARLY') ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _lunarDay,
                            decoration: InputDecoration(
                              labelText: 'Ngày âm',
                              labelStyle: AppTextStyles.bodySmall.copyWith(color: subText),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                            style: AppTextStyles.body.copyWith(color: onSurface),
                            dropdownColor: cardColor,
                            items: List.generate(30, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                            onChanged: (v) => setState(() => _lunarDay = v ?? 1),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _lunarMonth,
                            decoration: InputDecoration(
                              labelText: 'Tháng âm',
                              labelStyle: AppTextStyles.bodySmall.copyWith(color: subText),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                            style: AppTextStyles.body.copyWith(color: onSurface),
                            dropdownColor: cardColor,
                            items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                            onChanged: (v) => setState(() => _lunarMonth = v ?? 1),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
                    const SizedBox(height: 16),
                  ],

                  if (_repeatKey == 'CUSTOM') ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _customIntervalValue,
                            decoration: InputDecoration(
                              labelText: 'Số lần',
                              labelStyle: AppTextStyles.bodySmall.copyWith(color: subText),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                            style: AppTextStyles.body.copyWith(color: onSurface),
                            dropdownColor: cardColor,
                            items: List.generate(30, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                            onChanged: (v) => setState(() => _customIntervalValue = v ?? 1),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _customIntervalUnit,
                            decoration: InputDecoration(
                              labelText: 'Đơn vị',
                              labelStyle: AppTextStyles.bodySmall.copyWith(color: subText),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                            style: AppTextStyles.body.copyWith(color: onSurface),
                            dropdownColor: cardColor,
                            items: _customUnitOptions
                                .map((u) => DropdownMenuItem(value: u.key, child: Text(u.label)))
                                .toList(),
                            onChanged: (v) => setState(() => _customIntervalUnit = v ?? 'WEEK'),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
                    const SizedBox(height: 16),
                  ],

                  // ── Nhắc nhở Section ──
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notifications_none, size: 22, color: onSurface),
                            const SizedBox(width: 12),
                            Text(
                              'Nhắc nhở',
                              style: AppTextStyles.body.copyWith(color: onSurface, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Reminder chips (coral bg, with X button)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._reminders.asMap().entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.value.label,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => setState(() => _reminders.removeAt(entry.key)),
                                      child: Icon(Icons.close, size: 14, color: AppColors.primaryLight),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // "+ Thêm nhắc nhở" button
                        GestureDetector(
                          onTap: _showAddReminderSheet,
                          child: Row(
                            children: [
                              Icon(Icons.add_circle_outline, size: 18, color: subText),
                              const SizedBox(width: 8),
                              Text(
                                'Thêm nhắc nhở',
                                style: AppTextStyles.bodySmall.copyWith(color: subText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.05),
                  const SizedBox(height: 16),
                  
                  // ── Ghi chú Section ──
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notes_outlined, size: 22, color: onSurface),
                            const SizedBox(width: 12),
                            Text(
                              'Ghi chú',
                              style: AppTextStyles.body.copyWith(color: onSurface, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Thêm ghi chú...',
                            hintStyle: AppTextStyles.bodySmall.copyWith(color: subText),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primaryLight),
                            ),
                            filled: true,
                            fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          style: AppTextStyles.body.copyWith(color: onSurface),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 450.ms, duration: 300.ms).slideY(begin: 0.05),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Bottom Save Button ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: context.watch<EventProvider>().isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: context.watch<EventProvider>().isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Lưu sự kiện',
                          style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Picker Screen (Figma: Danh mục) ──────────

class _CategoryPickerScreen extends StatelessWidget {
  final List<_CategoryItem> categories;
  final String selectedKey;
  final bool isDark;

  const _CategoryPickerScreen({
    required this.categories,
    required this.selectedKey,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final onSurface = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Danh mục',
          style: AppTextStyles.heading3.copyWith(color: onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.key == selectedKey;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withValues(alpha: 0.12)
                  : cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              title: Text(
                cat.label,
                style: AppTextStyles.body.copyWith(
                  color: onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: cat.color, size: 22)
                  : null,
              onTap: () => Navigator.pop(context, cat),
            ),
          );
        },
      ),
    );
  }
}

// ─── Data Classes ──────────────────────────

class _CategoryItem {
  final int id;
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryItem({required this.id, required this.key, required this.label, required this.icon, required this.color});
}

class _RepeatOption {
  final String key;
  final String label;
  const _RepeatOption({required this.key, required this.label});
}

class _CustomUnitOption {
  final String key;
  final String label;
  const _CustomUnitOption({required this.key, required this.label});
}

class _ReminderOption {
  final String label;
  final int daysBefore;
  final int hoursBefore;
  final int minutesBefore;
  const _ReminderOption({required this.label, this.daysBefore = 0, this.hoursBefore = 0, this.minutesBefore = 0});
}

class _ReminderItem {
  final String label;
  final int? daysBefore;
  final int? hoursBefore;
  _ReminderItem({required this.label, this.daysBefore, this.hoursBefore});
}
