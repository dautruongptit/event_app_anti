import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_app/core/constants/app_colors.dart';
import 'package:event_app/core/constants/app_text_styles.dart';
import 'package:event_app/core/utils/date_utils.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/providers/relative_provider.dart';
import 'package:event_app/models/event.dart';

class EventFormScreen extends StatefulWidget {
  final int? eventId;

  const EventFormScreen({super.key, this.eventId});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInit = true;

  late TextEditingController _titleController;
  late TextEditingController _notesController;
  
  String _selectedEventType = 'KHAC';
  DateTime _selectedDate = DateTime.now();
  int? _selectedRelativeId;
  bool _isRecurring = false;
  String _recurrenceType = 'YEARLY';
  
  List<ReminderModel> _reminders = [];

  final List<String> _eventTypes = [
    'SINH_NHAT', 'KY_NIEM', 'LE', 'NHA_O', 'HOA_DON', 'MUA_SAM', 'KHAC'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    
    // Default reminder
    _reminders.add(const ReminderModel(remindDaysBefore: 1));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      context.read<RelativeProvider>().loadRelatives();
      if (widget.eventId != null) {
        _loadEventData();
      }
    }
  }

  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);
    try {
      await context.read<EventProvider>().loadEventById(widget.eventId!);
      final event = context.read<EventProvider>().selectedEvent;
      if (event != null) {
        _titleController.text = event.title;
        _notesController.text = event.notes ?? '';
        _selectedEventType = event.eventType;
        _selectedDate = event.eventDate;
        _selectedRelativeId = event.relativeId;
        _isRecurring = event.isRecurring;
        if (event.recurrenceType != null) {
          _recurrenceType = event.recurrenceType!;
        }
        if (event.reminders.isNotEmpty) {
          _reminders = List.from(event.reminders);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final data = {
        'title': _titleController.text.trim(),
        'eventType': _selectedEventType,
        'eventDate': _selectedDate.toIso8601String().split('T').first,
        'isRecurring': _isRecurring,
        'recurrenceType': _isRecurring ? _recurrenceType : null,
        'relativeId': _selectedRelativeId,
        'notes': _notesController.text.trim(),
        'reminders': _reminders.map((r) => r.toJson()).toList(),
      };

      if (widget.eventId == null) {
        await context.read<EventProvider>().createEvent(data);
      } else {
        await context.read<EventProvider>().updateEvent(widget.eventId!, data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.eventId == null ? 'Đã tạo sự kiện' : 'Đã cập nhật sự kiện')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final relatives = context.watch<RelativeProvider>().relatives;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? 'Tạo sự kiện mới' : 'Chỉnh sửa sự kiện'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tên sự kiện',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 200,
                        validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên sự kiện' : null,
                      ).animate().fadeIn().slideY(),
                      const SizedBox(height: 16),
                      
                      Text('Loại sự kiện', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _eventTypes.map((type) {
                          return ChoiceChip(
                            label: Text(type),
                            selected: _selectedEventType == type,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedEventType = type);
                              }
                            },
                          );
                        }).toList(),
                      ).animate().fadeIn(delay: 100.ms).slideY(),
                      const SizedBox(height: 24),
                      
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        leading: Icon(Icons.calendar_today, color: AppColors.primaryLight),
                        title: const Text('Ngày diễn ra'),
                        subtitle: Text(AppDateUtils.formatDate(_selectedDate)),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                      ).animate().fadeIn(delay: 200.ms).slideY(),
                      const SizedBox(height: 16),
                      
                      if (relatives.isNotEmpty)
                        DropdownButtonFormField<int>(
                          value: _selectedRelativeId,
                          decoration: const InputDecoration(
                            labelText: 'Người liên quan (Tuỳ chọn)',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<int>(value: null, child: Text('Không có')),
                            ...relatives.map((r) => DropdownMenuItem<int>(
                              value: r.id,
                              child: Text(r.name),
                            )),
                          ],
                          onChanged: (val) => setState(() => _selectedRelativeId = val),
                        ).animate().fadeIn(delay: 300.ms).slideY(),
                      const SizedBox(height: 16),

                      SwitchListTile(
                        title: const Text('Lặp lại định kỳ'),
                        value: _isRecurring,
                        onChanged: (val) => setState(() => _isRecurring = val),
                      ).animate().fadeIn(delay: 400.ms).slideY(),
                      
                      if (_isRecurring)
                        DropdownButtonFormField<String>(
                          value: _recurrenceType,
                          decoration: const InputDecoration(
                            labelText: 'Chu kỳ lặp',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'YEARLY', child: Text('Hàng năm')),
                            DropdownMenuItem(value: 'MONTHLY', child: Text('Hàng tháng')),
                            DropdownMenuItem(value: 'WEEKLY', child: Text('Hàng tuần')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _recurrenceType = val);
                            }
                          },
                        ).animate().fadeIn(delay: 450.ms).slideY(),
                      const SizedBox(height: 16),

                      Text('Lời nhắc', style: AppTextStyles.heading3),
                      ..._reminders.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final reminder = entry.value;
                        final isDays = reminder.remindDaysBefore != null;
                        final val = isDays ? reminder.remindDaysBefore : reminder.remindHoursBefore ?? 1;
                        final unit = isDays ? 'DAYS' : 'HOURS';

                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: val.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Trước (số lượng)'),
                                onChanged: (newVal) {
                                  final parsed = int.tryParse(newVal) ?? 1;
                                  setState(() {
                                    _reminders[idx] = ReminderModel(
                                      remindDaysBefore: unit == 'DAYS' ? parsed : null,
                                      remindHoursBefore: unit == 'HOURS' ? parsed : null,
                                    );
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: unit,
                                items: const [
                                  DropdownMenuItem(value: 'MINUTES', child: Text('Phút')),
                                  DropdownMenuItem(value: 'HOURS', child: Text('Giờ')),
                                  DropdownMenuItem(value: 'DAYS', child: Text('Ngày')),
                                ],
                                onChanged: (newUnit) {
                                  if (newUnit != null) {
                                    setState(() {
                                      _reminders[idx] = ReminderModel(
                                        remindDaysBefore: newUnit == 'DAYS' ? val : null,
                                        remindHoursBefore: newUnit == 'HOURS' ? val : null,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() => _reminders.removeAt(idx));
                              },
                            )
                          ],
                        );
                      }),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm lời nhắc'),
                        onPressed: () {
                          setState(() => _reminders.add(const ReminderModel(remindDaysBefore: 1)));
                        },
                      ).animate().fadeIn(delay: 500.ms).slideY(),
                      
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        maxLength: 2000,
                      ).animate().fadeIn(delay: 600.ms).slideY(),
                      const SizedBox(height: 100), // spacing for bottom button
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.secondaryLight]),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(
                      'Lưu sự kiện',
                      style: AppTextStyles.heading3.copyWith(color: Colors.white),
                    ),
                  ),
                ).animate().slideY(begin: 1, delay: 700.ms),
              ),
            ],
          ),
    );
  }
}
