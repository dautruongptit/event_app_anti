import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/providers/relative_provider.dart';
import 'package:event_app/core/utils/date_utils.dart';

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
  
  String _selectedEventType = 'SINH_NHAT';
  int? _selectedRelativeId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  bool _isRecurring = false;

  bool _remind7Days = true;
  bool _remind3Days = true;
  bool _remind1Day = true;
  bool _remind1Hour = false;

  List<String> get _eventTypes {
    if (widget.isRelativeEvent) {
      return ['SINH_NHAT', 'KY_NIEM', 'LE', 'KHAC'];
    } else {
      return ['HOA_DON', 'NHA_O', 'MUA_SAM', 'KHAC'];
    }
  }
  
  String _getEventTypeName(String type) {
    const map = {
      'SINH_NHAT': 'Sinh nhật',
      'KY_NIEM': 'Kỷ niệm',
      'LE': 'Ngày giỗ',
      'HOA_DON': 'Đóng tiền điện',
      'NHA_O': 'Đóng tiền phòng',
      'MUA_SAM': 'Mua sắm',
      'KHAC': 'Khác',
    };
    return map[type] ?? type;
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isRelativeEvent) {
      _selectedEventType = 'HOA_DON';
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isRelativeEvent) {
        context.read<RelativeProvider>().loadRelatives();
      }
      
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
        _notesController.text = event.notes ?? '';
        _selectedEventType = event.eventType;
        _selectedRelativeId = event.relativeId;
        _selectedDate = event.eventDate;
        if (event.eventTime != null && event.eventTime!.isNotEmpty) {
          final parts = event.eventTime!.split(':');
          _selectedTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
        _isRecurring = event.isRecurring;
        
        _remind7Days = false;
        _remind3Days = false;
        _remind1Day = false;
        _remind1Hour = false;
        
        for (var r in event.reminders) {
          if (r.remindDaysBefore == 7) _remind7Days = r.isEnabled;
          if (r.remindDaysBefore == 3) _remind3Days = r.isEnabled;
          if (r.remindDaysBefore == 1) _remind1Day = r.isEnabled;
          if (r.remindHoursBefore == 1) _remind1Hour = r.isEnabled;
        }
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
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveEvent() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề sự kiện')),
      );
      return;
    }
    
    if (widget.isRelativeEvent && _selectedRelativeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn người thân')),
      );
      return;
    }

    final reminders = <Map<String, dynamic>>[];
    if (_remind7Days) reminders.add({'remindDaysBefore': 7, 'isEnabled': true});
    if (_remind3Days) reminders.add({'remindDaysBefore': 3, 'isEnabled': true});
    if (_remind1Day) reminders.add({'remindDaysBefore': 1, 'isEnabled': true});
    if (_remind1Hour) reminders.add({'remindHoursBefore': 1, 'isEnabled': true});

    final data = {
      'title': _titleController.text.trim(),
      'eventType': _selectedEventType,
      'eventDate': _selectedDate.toIso8601String().split('T').first,
      'eventTime': _selectedTime != null 
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'isRecurring': _isRecurring,
      'notes': _notesController.text.trim(),
      'relativeId': _selectedRelativeId,
      'reminders': reminders,
    };

    final provider = context.read<EventProvider>();
    if (widget.eventId != null) {
      provider.updateEvent(widget.eventId!, data).then((success) {
        if (success) Navigator.pop(context);
      });
    } else {
      provider.createEvent(data).then((success) {
        if (success) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final fieldFill = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isRelativeEvent ? 'Sự kiện Người thân' : 'Sự kiện Bản thân',
          style: AppTextStyles.heading2.copyWith(color: onSurface),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isRelativeEvent) ...[
              Text('Chọn người thân', style: AppTextStyles.heading3.copyWith(color: onSurface)),
              const SizedBox(height: 12),
              _buildRelativeChips(),
              const SizedBox(height: 24),
            ],

            Text('Tiêu đề sự kiện', style: AppTextStyles.label.copyWith(color: AppColors.textSecondaryLight)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: fieldFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryLight),
                ),
              ),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),

            Text('Loại sự kiện', style: AppTextStyles.heading3.copyWith(color: onSurface)),
            const SizedBox(height: 12),
            _buildEventTypeChips(),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ngày (yyyy-MM-dd)', style: AppTextStyles.label.copyWith(color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: fieldFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppDateUtils.formatDate(_selectedDate),
                                style: AppTextStyles.body,
                              ),
                              const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primaryLight),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giờ (HH:mm)', style: AppTextStyles.label.copyWith(color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: fieldFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime != null 
                                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                    : 'Chọn giờ',
                                style: AppTextStyles.body.copyWith(
                                  color: _selectedTime != null ? onSurface : AppColors.textSecondaryLight,
                                ),
                              ),
                              const Icon(Icons.access_time_rounded, size: 20, color: AppColors.primaryLight),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lặp lại', style: AppTextStyles.heading3.copyWith(color: onSurface)),
                Switch(
                  value: _isRecurring,
                  onChanged: (v) => setState(() => _isRecurring = v),
                  activeColor: AppColors.primaryLight,
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text('Nhắc nhở', style: AppTextStyles.heading3.copyWith(color: onSurface)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: fieldFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildReminderToggle('7 ngày trước', _remind7Days, (v) => setState(() => _remind7Days = v)),
                  Divider(height: 1, color: borderColor),
                  _buildReminderToggle('3 ngày trước', _remind3Days, (v) => setState(() => _remind3Days = v)),
                  Divider(height: 1, color: borderColor),
                  _buildReminderToggle('1 ngày trước', _remind1Day, (v) => setState(() => _remind1Day = v)),
                  Divider(height: 1, color: borderColor),
                  _buildReminderToggle('1 giờ trước', _remind1Hour, (v) => setState(() => _remind1Hour = v)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Ghi chú (tùy chọn)', style: AppTextStyles.label.copyWith(color: AppColors.textSecondaryLight)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: fieldFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryLight),
                ),
              ),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: context.watch<EventProvider>().isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: context.watch<EventProvider>().isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: AppColors.surfaceLight, strokeWidth: 2),
                        )
                      : Text(
                          'Lưu sự kiện',
                          style: AppTextStyles.button.copyWith(color: AppColors.surfaceLight),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ].animate(interval: 50.ms).fade(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
        ),
      ),
    );
  }

  Widget _buildRelativeChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<RelativeProvider>();
    final relatives = provider.relatives;
    
    if (relatives.isEmpty) {
      return Text('Chưa có người thân nào', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight));
    }
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: relatives.length,
        itemBuilder: (context, index) {
          final relative = relatives[index];
          final isSelected = _selectedRelativeId == relative.id;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedRelativeId = relative.id),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLight
                    : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryLight : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                relative.displayName,
                style: AppTextStyles.label.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventTypeChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _eventTypes.length,
        itemBuilder: (context, index) {
          final type = _eventTypes[index];
          final isSelected = _selectedEventType == type;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedEventType = type),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLight
                    : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryLight : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _getEventTypeName(type),
                style: AppTextStyles.label.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderToggle(String label, bool value, ValueChanged<bool> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}
