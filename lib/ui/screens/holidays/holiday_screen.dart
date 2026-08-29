import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/vn_holidays.dart';
import '../../widgets/nino/card_row.dart';
import '../../widgets/nino/pill_tabs.dart';
import '../../widgets/nino/bottom_option_sheet.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  static const _prefsKey = 'holiday_reminders';

  late int _year;
  String _filter = 'Tất cả';
  String? _selectedName;
  Set<String> _reminded = {};

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? [];
    if (mounted) setState(() => _reminded = saved.toSet());
  }

  Future<void> _toggleReminder(String name) async {
    setState(() {
      if (_reminded.contains(name)) {
        _reminded.remove(name);
      } else {
        _reminded.add(name);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _reminded.toList());
  }

  void _createEventFrom(ResolvedVnHoliday h) {
    setState(() => _selectedName = null);
    context.push('/events/create', extra: {'title': h.def.name, 'date': h.solarDate});
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _daysAway(DateTime target, DateTime today) {
    final t0 = DateTime(today.year, today.month, today.day);
    final diff = DateTime(target.year, target.month, target.day).difference(t0).inDays;
    if (diff < 0) return 'Đã qua';
    if (diff == 0) return 'Hôm nay';
    return '$diff ngày';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final mint = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final mintSoft = isDark ? AppColors.secondarySoftDark : AppColors.secondarySoftLight;
    final amber = isDark ? AppColors.amberDark : AppColors.amberLight;
    final amberSoft = isDark ? AppColors.amberSoftDark : AppColors.amberSoftLight;

    final all = resolveVnHolidays(_year);
    final today = DateTime.now();
    final upcoming =
        all.where((h) => !h.solarDate.isBefore(DateTime(today.year, today.month, today.day))).toList();
    final next = upcoming.isNotEmpty ? upcoming.first : null;

    final filtered = _filter == 'Dương lịch'
        ? all.where((h) => h.def.kind == VnHolidayKind.solar).toList()
        : _filter == 'Âm lịch'
            ? all.where((h) => h.def.kind == VnHolidayKind.lunar).toList()
            : all;

    final officialCount = all.where((h) => h.def.official).length;
    final offDays = all.where((h) => h.def.official).fold<int>(0, (n, h) => n + h.def.officialDaysOff);

    ResolvedVnHoliday? selected;
    try {
      selected = _selectedName == null ? null : all.firstWhere((h) => h.def.name == _selectedName);
    } catch (_) {
      selected = null;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, color: txt),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text('Lịch nghỉ lễ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                  ),
                  GestureDetector(
                    onTap: () => showBottomOptionSheet(
                      context: context,
                      title: 'Chọn năm',
                      options: [_year - 1, _year, _year + 1].map((y) {
                        return NinoOption(
                          label: '$y',
                          icon: '📅',
                          selected: y == _year,
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _year = y;
                              _selectedName = null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                          const SizedBox(width: 5),
                          Icon(Icons.expand_more_rounded, size: 16, color: mut),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        SquareIconBadge(icon: Icons.flag_rounded, color: pri, background: priSoft, size: 36),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Lịch nghỉ lễ Việt Nam', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt)),
                              const SizedBox(height: 2),
                              Text(
                                '$officialCount dịp lễ chính · $offDays ngày nghỉ theo quy định $_year',
                                style: TextStyle(fontSize: 12, color: mut),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 11),
                  SegmentedPillTabs(
                    labels: const ['Tất cả', 'Dương lịch', 'Âm lịch'],
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                  if (next != null) ...[
                    const SizedBox(height: 15),
                    Text('NGÀY LỄ SẮP TỚI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.9, color: fnt)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedName = next.def.name),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(gradient: AppColors.holidayHeroGradient, borderRadius: BorderRadius.circular(18)),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.24), borderRadius: BorderRadius.circular(13)),
                              alignment: Alignment.center,
                              child: Text(next.def.icon, style: const TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(next.def.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_fmt(next.solarDate)} · ${next.lunarText}',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.88)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
                              child: Text(
                                _daysAway(next.solarDate, today),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                  Text(
                    _filter == 'Tất cả' ? 'Ngày lễ trong năm $_year' : '$_filter · $_year',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.9, color: fnt),
                  ),
                  const SizedBox(height: 9),
                  ...filtered.map((h) {
                    final isOn = _reminded.contains(h.def.name);
                    final isSelected = _selectedName == h.def.name;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: CardRow(
                        borderColor: isSelected ? pri : (isDark ? AppColors.lineDark : AppColors.lineLight),
                        onTap: () => setState(() => _selectedName = isSelected ? null : h.def.name),
                        leading: SquareIconBadge(
                          icon: Icons.celebration_rounded,
                          color: h.def.official ? pri : amber,
                          background: h.def.official ? priSoft : amberSoft,
                          size: 40,
                        ),
                        title: h.def.name,
                        meta: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_fmt(h.solarDate), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                            Text(h.lunarText, style: TextStyle(fontSize: 12, color: mut)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: h.def.official ? priSoft : amberSoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                h.def.official ? 'Ngày nghỉ chính thức' : 'Lễ truyền thống',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: h.def.official ? pri : amber),
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_daysAway(h.solarDate, today), style: TextStyle(fontSize: 12, color: mut)),
                            const SizedBox(height: 7),
                            GestureDetector(
                              onTap: () => _toggleReminder(h.def.name),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isOn ? mintSoft : Colors.transparent,
                                  border: Border.all(color: isOn ? Colors.transparent : (isDark ? AppColors.line2Dark : AppColors.line2Light)),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  isOn ? '🔔 Đã bật' : '🔔 Nhắc tôi',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isOn ? mint : mut),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  Text(
                    'Ngày nghỉ thực tế có thể khác do trùng cuối tuần hoặc ngày nghỉ bù — theo thông báo chính thức hằng năm.',
                    style: TextStyle(fontSize: 12, color: fnt, height: 1.5),
                  ),
                ],
              ),
            ),
            if (selected != null)
              Container(
                padding: EdgeInsets.fromLTRB(16, 11, 16, 11 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.navBarDark : AppColors.navBarLight,
                  border: Border(top: BorderSide(color: line)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(selected.def.icon, style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            '${selected.def.name} · ${_fmt(selected.solarDate)}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: txt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _selectedName = null),
                          child: Text('Bỏ chọn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _toggleReminder(selected!.def.name),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            side: BorderSide(color: isDark ? AppColors.line2Dark : AppColors.line2Light),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('🔔', style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _createEventFrom(selected!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pri,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('+ Tạo sự kiện', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
