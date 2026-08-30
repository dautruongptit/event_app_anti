import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/event_provider.dart';
import '../../../providers/relative_provider.dart';
import '../../../models/event.dart';
import '../../widgets/nino/bottom_option_sheet.dart';
import '../../widgets/nino/soft_toggle.dart';
import '../../widgets/nino/sticky_action_bars.dart';
import '../../widgets/nino/nino_toast.dart';

class EventFormScreen extends StatefulWidget {
  final bool isRelativeEvent;
  final int? eventId;
  final String? prefillTitle;
  final DateTime? prefillDate;

  const EventFormScreen({
    super.key,
    this.isRelativeEvent = true,
    this.eventId,
    this.prefillTitle,
    this.prefillDate,
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

  final List<_ReminderItem> _reminders = [
    _ReminderItem(label: '7 ngày trước', daysBefore: 7),
    _ReminderItem(label: '3 ngày trước', daysBefore: 3),
    _ReminderItem(label: '1 ngày trước', daysBefore: 1),
    _ReminderItem(label: '1 giờ trước', hoursBefore: 1),
  ];

  static const List<_CategoryItem> _categories = [
    _CategoryItem(id: 1, key: 'SINH_NHAT', label: 'Sinh nhật', icon: Icons.cake, color: Color(0xFFFF5A5F)),
    _CategoryItem(id: 2, key: 'KY_NIEM', label: 'Kỷ niệm', icon: Icons.favorite, color: Color(0xFF8B6BE0)),
    _CategoryItem(id: 3, key: 'LE', label: 'Lễ/Tết', icon: Icons.card_giftcard, color: Color(0xFFD69C13)),
    _CategoryItem(id: 4, key: 'NHA_O', label: 'Nhà ở', icon: Icons.home, color: Color(0xFF2F9E97)),
    _CategoryItem(id: 5, key: 'HOA_DON', label: 'Hóa đơn', icon: Icons.bolt, color: Color(0xFFD69C13)),
    _CategoryItem(id: 6, key: 'MUA_SAM', label: 'Mua sắm', icon: Icons.shopping_bag, color: Color(0xFF2F9E97)),
    _CategoryItem(id: 7, key: 'KHAC', label: 'Khác', icon: Icons.more_horiz, color: Color(0xFF8A94A6)),
  ];

  static const List<_RepeatOption> _repeatOptions = [
    _RepeatOption(key: 'NONE', label: 'Không lặp', icon: '🚫'),
    _RepeatOption(key: 'DAILY', label: 'Hàng ngày', icon: '🔁'),
    _RepeatOption(key: 'WEEKLY', label: 'Hàng tuần', icon: '🔁'),
    _RepeatOption(key: 'MONTHLY', label: 'Hàng tháng', icon: '🔁'),
    _RepeatOption(key: 'YEARLY', label: 'Hàng năm', icon: '🔁'),
    _RepeatOption(key: 'LUNAR_YEARLY', label: 'Hàng năm (Âm lịch)', icon: '🧧'),
    _RepeatOption(key: 'CUSTOM', label: 'Tùy chỉnh', icon: '⚙️'),
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
    if (widget.eventId == null && widget.prefillTitle != null) {
      _titleController.text = widget.prefillTitle!;
      if (widget.prefillDate != null) _selectedDate = widget.prefillDate!;
    }
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
    if (event == null) return;
    setState(() {
      _titleController.text = event.title;
      _selectedRelativeId = event.relativeId;
      _selectedDate = event.eventDate;
      if (event.eventTime != null && event.eventTime!.isNotEmpty) {
        final parts = event.eventTime!.split(':');
        _selectedTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
      }
      if (event.isRecurring) {
        _repeatMode = 'Hàng năm';
        _repeatKey = 'YEARLY';
      }
      try {
        final cat = _categories.firstWhere((c) => c.id == event.categoryId);
        _selectedCategoryId = cat.id;
        _selectedCategory = cat.label;
        _selectedCategoryKey = cat.key;
      } catch (_) {}

      // Giữ lại MỌI reminder đang bật, kể cả loại không khớp 1 trong 5
      // preset chuẩn (VD: "lặp mỗi N phút cho tới khi đọc" — nhắc uống
      // thuốc). Bản cũ chỉ nhận diện đúng 4 tổ hợp cố định, mọi reminder
      // khác bị BỎ QUA hoàn toàn khi tải để sửa — dẫn tới lưu lại là xoá
      // sạch reminder gốc dù người dùng không đụng vào mục Nhắc nhở.
      _reminders.clear();
      for (final r in event.reminders) {
        if (!r.isEnabled) continue;
        _reminders.add(_ReminderItem(
          label: _reminderLabel(r),
          daysBefore: r.remindDaysBefore,
          hoursBefore: r.remindHoursBefore,
          repeatIntervalMinutes: r.repeatIntervalMinutes,
        ));
      }
      _notesController.text = event.notes ?? '';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2101));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _showRepeatSheet() {
    showBottomOptionSheet(
      context: context,
      title: 'Lặp lại',
      options: _repeatOptions
          .map((o) => NinoOption(
                label: o.label,
                icon: o.icon,
                selected: _repeatKey == o.key,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _repeatKey = o.key;
                    _repeatMode = o.label;
                  });
                },
              ))
          .toList(),
    );
  }

  void _showRelativePicker() {
    final relatives = context.read<RelativeProvider>().relatives;
    if (relatives.isEmpty) {
      showNinoToast(context, 'Chưa có người thân nào. Hãy thêm người thân trước.');
      return;
    }
    showBottomOptionSheet(
      context: context,
      title: 'Chọn người thân',
      options: relatives
          .map((r) => NinoOption(
                label: r.displayName,
                icon: '👤',
                selected: _selectedRelativeId == r.id,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedRelativeId = r.id;
                    _selectedRelativeName = r.displayName;
                  });
                },
              ))
          .toList(),
    );
  }

  void _showCategoryPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) {
        final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.74),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  child: Align(alignment: Alignment.centerLeft, child: Text('Danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt))),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 22),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSelected = cat.key == _selectedCategoryKey;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Material(
                          color: isSelected ? cat.color.withValues(alpha: 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = cat.id;
                                _selectedCategory = cat.label;
                                _selectedCategoryKey = cat.key;
                              });
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                                    child: Icon(cat.icon, color: cat.color, size: 19),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cat.label,
                                      style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? cat.color : txt),
                                    ),
                                  ),
                                  if (isSelected) Icon(Icons.check_rounded, size: 18, color: cat.color),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddReminderSheet() {
    final existingLabels = _reminders.map((r) => r.label).toSet();
    final available = _reminderOptions.where((o) => !existingLabels.contains(o.label)).toList();
    if (available.isEmpty) {
      showNinoToast(context, 'Đã thêm tất cả nhắc nhở');
      return;
    }
    showBottomOptionSheet(
      context: context,
      title: 'Thêm nhắc nhở',
      options: available
          .map((o) => NinoOption(
                label: o.label,
                icon: '⏰',
                selected: false,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _reminders.add(_ReminderItem(label: o.label, daysBefore: o.daysBefore, hoursBefore: o.hoursBefore)));
                },
              ))
          .toList(),
    );
  }

  void _saveEvent() {
    if (_titleController.text.trim().isEmpty) {
      showNinoToast(context, 'Vui lòng nhập tên sự kiện');
      return;
    }
    // Gộp mỗi _ReminderItem thành ĐÚNG 1 reminder (khớp shape 1 EventReminder
    // bên backend) thay vì tách daysBefore/hoursBefore thành 2 dòng riêng —
    // trước đây "> 0" còn vô tình loại bỏ hoursBefore=0 (giá trị hợp lệ,
    // dùng cho reminder "lặp mỗi N phút" như nhắc uống thuốc), khiến nó
    // không bao giờ thực sự được lưu dù vẫn hiện đúng dạng chip trên UI.
    final reminders = <Map<String, dynamic>>[];
    for (final r in _reminders) {
      if (r.daysBefore == null && r.hoursBefore == null && r.repeatIntervalMinutes == null) continue;
      reminders.add({
        'isEnabled': true,
        if (r.daysBefore != null) 'remindDaysBefore': r.daysBefore,
        if (r.hoursBefore != null) 'remindHoursBefore': r.hoursBefore,
        if (r.repeatIntervalMinutes != null) 'repeatIntervalMinutes': r.repeatIntervalMinutes,
      });
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
      'notes': _notesController.text.trim(),
      'relativeId': _selectedRelativeId,
      'reminders': reminders,
    };
    final provider = context.read<EventProvider>();
    final future = widget.eventId != null ? provider.updateEvent(widget.eventId!, data) : provider.createEvent(data);
    future.then((success) {
      // Luôn thoát thẳng về màn Sự kiện khi lưu thành công — dù được mở từ
      // đâu (chọn loại sự kiện, chi tiết người thân, Lịch nghỉ lễ, hay sửa
      // từ màn chi tiết sự kiện), không dừng lại ở màn trung gian đã push
      // qua như context.pop() từng làm.
      if (success && mounted) context.go('/events');
    });
  }

  String _formatDate(DateTime d) {
    const months = ['', 'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5', 'tháng 6', 'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12'];
    return '${d.day} ${months[d.month]}, ${d.year}';
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Nhãn hiển thị khi tải 1 reminder có sẵn từ sự kiện đang sửa. Ưu tiên
  /// đúng nhãn của 5 preset chuẩn (khớp _reminderOptions) để hiển thị nhất
  /// quán với sheet "Thêm nhắc nhở"; các tổ hợp khác (VD: lặp lại mỗi N
  /// phút cho tới khi đọc — nhắc uống thuốc) hiện nhãn mô tả chung thay vì
  /// bị bỏ qua.
  String _reminderLabel(ReminderModel r) {
    if (r.repeatIntervalMinutes != null) return 'Mỗi ${r.repeatIntervalMinutes} phút';
    if (r.remindDaysBefore == 7) return '7 ngày trước';
    if (r.remindDaysBefore == 3) return '3 ngày trước';
    if (r.remindDaysBefore == 1) return '1 ngày trước';
    if (r.remindHoursBefore == 1) return '1 giờ trước';
    if (r.remindHoursBefore == 0) return '30 phút trước';
    if (r.remindDaysBefore != null) return '${r.remindDaysBefore} ngày trước';
    if (r.remindHoursBefore != null) return '${r.remindHoursBefore} giờ trước';
    return 'Nhắc nhở';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;
    final amberSoft = isDark ? AppColors.amberSoftDark : AppColors.amberSoftLight;
    final violetSoft = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final isLoading = context.watch<EventProvider>().isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 18, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => context.pop(), icon: Icon(Icons.chevron_left_rounded, color: txt)),
                  Text('Thêm sự kiện', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                  TextButton(onPressed: isLoading ? null : _saveEvent, child: Text('Lưu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pri))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt),
                      decoration: InputDecoration(
                        hintText: 'Tên sự kiện *',
                        filled: true,
                        fillColor: card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: line2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: line2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: pri, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: Column(
                        children: [
                          _pickerRow(
                            icon: '👤',
                            iconBg: priSoft,
                            label: 'Người thân',
                            value: _selectedRelativeName ?? 'Không có',
                            valueColor: _selectedRelativeName != null ? txt : mut,
                            onTap: _showRelativePicker,
                            border: Border(bottom: BorderSide(color: line)),
                            txt: txt,
                          ),
                          _pickerRow(
                            icon: '🏷',
                            iconBg: mintSoft,
                            label: 'Danh mục',
                            value: _selectedCategory,
                            valueColor: pri,
                            onTap: _showCategoryPicker,
                            border: const Border(),
                            txt: txt,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _selectDate,
                                  child: _dateTimeTile(icon: Icons.calendar_today_rounded, iconBg: mintSoft, label: 'Ngày', value: _formatDate(_selectedDate), txt: txt, mut: mut),
                                ),
                              ),
                              if (!_isAllDay)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _selectTime,
                                    child: _dateTimeTile(icon: Icons.access_time_rounded, iconBg: priSoft, label: 'Giờ', value: _selectedTime != null ? _formatTime(_selectedTime!) : '--:--', txt: txt, mut: mut),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Divider(height: 1, color: line),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              const Text('🌤', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 11),
                              Expanded(child: Text('Cả ngày', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt))),
                              SoftToggle(value: _isAllDay, onChanged: (v) => setState(() => _isAllDay = v)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: Column(
                        children: [
                          _pickerRow(
                            icon: '🔁',
                            iconBg: violetSoft,
                            label: 'Lặp lại',
                            value: _repeatMode,
                            valueColor: _repeatKey != 'NONE' ? txt : mut,
                            onTap: _showRepeatSheet,
                            border: const Border(),
                            txt: txt,
                          ),
                          if (_repeatKey == 'LUNAR_YEARLY')
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 14),
                              child: Row(
                                children: [
                                  Expanded(child: _numberDropdown('Ngày âm', _lunarDay, 30, (v) => setState(() => _lunarDay = v), card, line2, txt, mut)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _numberDropdown('Tháng âm', _lunarMonth, 12, (v) => setState(() => _lunarMonth = v), card, line2, txt, mut)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 30, height: 30, decoration: BoxDecoration(color: amberSoft, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: const Text('⏰', style: TextStyle(fontSize: 14))),
                              const SizedBox(width: 11),
                              Text('Nhắc nhở *', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt)),
                            ],
                          ),
                          const SizedBox(height: 11),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              ..._reminders.asMap().entries.map((e) => Container(
                                    padding: const EdgeInsets.only(left: 12, right: 8, top: 7, bottom: 7),
                                    decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(999)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(e.value.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: pri)),
                                        const SizedBox(width: 6),
                                        GestureDetector(onTap: () => setState(() => _reminders.removeAt(e.key)), child: Icon(Icons.close_rounded, size: 14, color: pri)),
                                      ],
                                    ),
                                  )),
                              GestureDetector(
                                onTap: _showAddReminderSheet,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: line2)),
                                  child: Text('＋ Thêm nhắc nhở', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(15, 14, 15, 11),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: line2)),
                      child: TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        style: TextStyle(fontSize: 14, color: txt),
                        decoration: InputDecoration(hintText: 'Thêm ghi chú (không bắt buộc)', hintStyle: TextStyle(color: fnt), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StickySaveBar(label: 'Lưu sự kiện', onPressed: isLoading ? null : _saveEvent, loading: isLoading),
          ],
        ),
      ),
    );
  }

  Widget _pickerRow({
    required String icon,
    required Color iconBg,
    required String label,
    required String value,
    required Color valueColor,
    required VoidCallback onTap,
    required Border border,
    required Color txt,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(border: border),
        child: Row(
          children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text(icon, style: const TextStyle(fontSize: 14))),
            const SizedBox(width: 11),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt)),
            const Spacer(),
            Flexible(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: valueColor),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeTile({required IconData icon, required Color iconBg, required String label, required String value, required Color txt, required Color mut}) {
    return Row(
      children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Icon(icon, size: 15, color: txt)),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: mut)),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt)),
          ],
        ),
      ],
    );
  }

  Widget _numberDropdown(String label, int value, int max, ValueChanged<int> onChanged, Color card, Color line2, Color txt, Color mut) {
    return GestureDetector(
      onTap: () => showBottomOptionSheet(
        context: context,
        title: label,
        options: List.generate(max, (i) => i + 1)
            .map((v) => NinoOption(label: '$v', icon: '', selected: v == value, onTap: () { Navigator.of(context).pop(); onChanged(v); }))
            .toList(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12), border: Border.all(color: line2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(label, style: TextStyle(fontSize: 11, color: mut)), Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt))],
            ),
            Icon(Icons.expand_more_rounded, size: 14, color: mut),
          ],
        ),
      ),
    );
  }
}

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
  final String icon;
  const _RepeatOption({required this.key, required this.label, required this.icon});
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
  /// Nếu có giá trị: reminder kiểu "lặp lại mỗi N phút cho tới khi đọc"
  /// (VD: nhắc uống thuốc) — không có ô chọn riêng trong sheet "Thêm nhắc
  /// nhở" (chỉ 5 preset chuẩn), nhưng vẫn phải giữ nguyên khi sửa sự kiện
  /// đã có sẵn loại này, không được để trống khi lưu.
  final int? repeatIntervalMinutes;
  _ReminderItem({required this.label, this.daysBefore, this.hoursBefore, this.repeatIntervalMinutes});
}
