import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/relative_provider.dart';
import '../../widgets/nino/bottom_option_sheet.dart';
import '../../widgets/nino/nino_toast.dart';

class RelativeFormScreen extends StatefulWidget {
  final int? relativeId;
  const RelativeFormScreen({super.key, this.relativeId});

  @override
  State<RelativeFormScreen> createState() => _RelativeFormScreenState();
}

class _RelativeFormScreenState extends State<RelativeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _hobbyController = TextEditingController();

  String _groupType = 'GIA_DINH';
  String _gender = 'MALE';
  int? _dobDay;
  int? _dobMonth;
  int? _dobYear;
  List<String> _hobbies = [];
  bool _isInit = false;
  bool _touched = false;

  static const Map<String, (String, String)> _groupTypes = {
    'GIA_DINH': ('Gia đình', '👨‍👩‍👧'),
    'VO_CHONG': ('Vợ/Chồng', '💍'),
    'CON_CAI': ('Con cái', '👶'),
    'BAN_BE': ('Bạn bè', '👤'),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit && widget.relativeId != null) {
      _loadRelativeData();
      _isInit = true;
    }
  }

  void _loadRelativeData() {
    final relative = context.read<RelativeProvider>().selectedRelative;
    if (relative != null && relative.id == widget.relativeId) {
      _nameController.text = relative.name;
      _nicknameController.text = relative.nickname ?? '';
      _groupType = relative.groupType;
      _gender = relative.gender ?? 'MALE';
      _dobDay = relative.dateOfBirth?.day;
      _dobMonth = relative.dateOfBirth?.month;
      _dobYear = relative.dateOfBirth?.year;
      _locationController.text = relative.location ?? '';
      _heightController.text = relative.heightCm?.toString() ?? '';
      _weightController.text = relative.weightKg?.toString() ?? '';
      _hobbies = List.from(relative.hobbies ?? []);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _locationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _hobbyController.dispose();
    super.dispose();
  }

  void _addHobby() {
    final text = _hobbyController.text.trim();
    if (text.isNotEmpty && !_hobbies.contains(text)) {
      setState(() {
        _hobbies.add(text);
        _hobbyController.clear();
      });
    }
  }

  void _removeHobby(String hobby) => setState(() => _hobbies.remove(hobby));

  Future<void> _pickDatePart(String part) async {
    final now = DateTime.now();
    late final List<int> range;
    late final String title;
    late final int? current;
    if (part == 'day') {
      range = List.generate(31, (i) => i + 1);
      title = 'Chọn ngày sinh';
      current = _dobDay;
    } else if (part == 'month') {
      range = List.generate(12, (i) => i + 1);
      title = 'Chọn tháng sinh';
      current = _dobMonth;
    } else {
      range = List.generate(90, (i) => now.year - i);
      title = 'Chọn năm sinh';
      current = _dobYear;
    }
    await showBottomOptionSheet(
      context: context,
      title: title,
      options: range
          .map((v) => NinoOption(
                label: '$v',
                icon: '',
                selected: v == current,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    if (part == 'day') _dobDay = v;
                    if (part == 'month') _dobMonth = v;
                    if (part == 'year') _dobYear = v;
                  });
                },
              ))
          .toList(),
    );
  }

  Future<void> _submit() async {
    setState(() => _touched = true);
    if (!_formKey.currentState!.validate() || _dobDay == null || _dobMonth == null || _dobYear == null) {
      showNinoToast(context, 'Còn thông tin bắt buộc chưa nhập');
      return;
    }
    FocusScope.of(context).unfocus();

    final data = {
      'name': _nameController.text.trim(),
      'nickname': _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
      'groupType': _groupType,
      'gender': _gender,
      'dateOfBirth': DateTime(_dobYear!, _dobMonth!, _dobDay!).toIso8601String().split('T').first,
      'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      'heightCm': _heightController.text.trim().isEmpty ? null : double.tryParse(_heightController.text.trim()),
      'weightKg': _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
      'hobbies': _hobbies,
    };

    final provider = context.read<RelativeProvider>();
    final success = widget.relativeId == null
        ? await provider.createRelative(data)
        : await provider.updateRelative(widget.relativeId!, data);

    if (success && mounted) {
      showNinoToast(context, widget.relativeId == null ? 'Đã thêm người thân' : 'Đã lưu thay đổi');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.relativeId != null;
    final isLoading = context.watch<RelativeProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mut = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final fnt = isDark ? AppColors.textFaintDark : AppColors.textFaintLight;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final line = isDark ? AppColors.lineDark : AppColors.lineLight;
    final line2 = isDark ? AppColors.line2Dark : AppColors.line2Light;
    final pri = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final priSoft = isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final danger = isDark ? AppColors.errorDark : AppColors.error;
    final nameError = _touched && _nameController.text.trim().isEmpty;
    final dobError = _touched && (_dobDay == null || _dobMonth == null || _dobYear == null);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 14, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () => context.pop(), icon: Icon(Icons.chevron_left_rounded, color: txt)),
                      Text(isEditing ? 'Sửa người thân' : 'Thêm người thân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                      TextButton(
                        onPressed: isLoading ? null : _submit,
                        child: Text('Lưu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pri)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 41,
                            backgroundColor: priSoft,
                            child: Text(
                              _nameController.text.trim().isNotEmpty ? _nameController.text.trim()[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: pri),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text('Họ và tên *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        if (isEditing)
                          GestureDetector(
                            onTap: () => showNinoToast(context, 'Tên đã lưu không sửa được'),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.neutralSoftDark : AppColors.neutralSoftLight,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: line),
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(_nameController.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txt))),
                                  Icon(Icons.lock_outline_rounded, size: 15, color: fnt),
                                ],
                              ),
                            ),
                          )
                        else
                          TextFormField(
                            controller: _nameController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Nguyễn Thị Lan',
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: pri, width: 1.5)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: nameError ? danger : line2)),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                          ),
                        if (nameError)
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text('⚠ Vui lòng nhập họ và tên', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: danger)),
                          ),
                        const SizedBox(height: 18),
                        Text('Quan hệ *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        GestureDetector(
                          onTap: () => showBottomOptionSheet(
                            context: context,
                            title: 'Quan hệ',
                            options: _groupTypes.entries
                                .map((e) => NinoOption(
                                      label: e.value.$1,
                                      icon: e.value.$2,
                                      selected: _groupType == e.key,
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        setState(() => _groupType = e.key);
                                      },
                                    ))
                                .toList(),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(15), border: Border.all(color: line2)),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(color: priSoft, borderRadius: BorderRadius.circular(10)),
                                  alignment: Alignment.center,
                                  child: Text(_groupTypes[_groupType]!.$2, style: const TextStyle(fontSize: 15)),
                                ),
                                const SizedBox(width: 11),
                                Expanded(child: Text(_groupTypes[_groupType]!.$1, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt))),
                                Icon(Icons.chevron_right_rounded, color: fnt),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('Giới tính', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            _genderChip('MALE', 'Nam', mut, pri, priSoft, line2),
                            const SizedBox(width: 8),
                            _genderChip('FEMALE', 'Nữ', mut, pri, priSoft, line2),
                            const SizedBox(width: 8),
                            _genderChip('OTHER', 'Khác', mut, pri, priSoft, line2),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('Ngày sinh *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(child: _dobPart('Ngày', _dobDay, () => _pickDatePart('day'), txt, mut, card, dobError ? danger : line2)),
                            const SizedBox(width: 8),
                            Expanded(child: _dobPart('Tháng', _dobMonth, () => _pickDatePart('month'), txt, mut, card, dobError ? danger : line2)),
                            const SizedBox(width: 8),
                            Expanded(child: _dobPart('Năm', _dobYear, () => _pickDatePart('year'), txt, mut, card, dobError ? danger : line2)),
                          ],
                        ),
                        if (dobError)
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text('⚠ Chọn đầy đủ ngày / tháng / năm sinh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: danger)),
                          ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Chiều cao (cm) · tuỳ chọn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                                  const SizedBox(height: 7),
                                  TextFormField(controller: _heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '160')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cân nặng (kg) · tuỳ chọn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                                  const SizedBox(height: 7),
                                  TextFormField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '52')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('Địa chỉ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        TextFormField(controller: _locationController, decoration: const InputDecoration(hintText: 'Hà Nội')),
                        const SizedBox(height: 18),
                        Text('Sở thích', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mut)),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _hobbyController,
                                decoration: const InputDecoration(hintText: 'Thêm sở thích'),
                                onFieldSubmitted: (_) => _addHobby(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(onPressed: _addHobby, icon: Icon(Icons.add_circle_rounded, color: pri, size: 30)),
                          ],
                        ),
                        if (_hobbies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _hobbies
                                  .map((h) => Chip(
                                        label: Text(h),
                                        onDeleted: () => _removeHobby(h),
                                        backgroundColor: priSoft,
                                        deleteIconColor: pri,
                                        labelStyle: TextStyle(color: pri, fontWeight: FontWeight.w600),
                                        side: BorderSide.none,
                                      ))
                                  .toList(),
                            ),
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pri,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(isEditing ? 'Lưu thay đổi' : 'Lưu người thân', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading) Container(color: Colors.black.withValues(alpha: 0.2), child: const Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  Widget _genderChip(String value, String label, Color mut, Color pri, Color priSoft, Color line2) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? priSoft : Colors.transparent,
            border: Border.all(color: isSelected ? pri : line2, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? pri : mut)),
        ),
      ),
    );
  }

  Widget _dobPart(String label, int? value, VoidCallback onTap, Color txt, Color mut, Color card, Color border) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(15), border: Border.all(color: border, width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: mut)),
                const SizedBox(height: 1),
                Text(value?.toString() ?? '—', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
              ],
            ),
            Icon(Icons.expand_more_rounded, size: 14, color: mut),
          ],
        ),
      ),
    );
  }
}
